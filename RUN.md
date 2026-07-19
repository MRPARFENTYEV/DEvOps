# RUN — запуск полного деплоя с нуля

Пошаговый запуск всего проекта в Яндекс.Облаке. Идти сверху вниз.

> **Главное про «данные ВМ».** Ты **не вводишь IP виртуалок вручную** — их создаёт Terraform на шаге 2,
> и адреса появляются как `terraform output`. Скрипт на шаге 3 сам подставит эти IP в инвентарь Ansible.
> Вручную ты вписываешь только 4 значения Яндекса (токен, cloud_id, folder_id, ssh-ключ) и ключи бакета.

## Карта: какое значение и в какой файл

| Значение | Откуда взять | В какой файл вписать | Секрет? |
|---|---|---|---|
| `yc_token` (OAuth) | https://oauth.yandex.ru | `diploma-infra/bootstrap/terraform.tfvars` и `infra/terraform.tfvars` | **да** |
| `cloud_id` | `yc resource-manager cloud list` или консоль | оба `terraform.tfvars` | нет |
| `folder_id` | `yc resource-manager folder list` или консоль | оба `terraform.tfvars` | нет |
| `state_bucket_name` | придумать (глобально уникальное) | `bootstrap/terraform.tfvars` | нет |
| `ssh_public_key` | `cat ~/.ssh/id_ed25519.pub` | `infra/terraform.tfvars` | нет |
| `bucket` / `access_key` / `secret_key` | output шага 1 (bootstrap) | `infra/backend.hcl` | ключи — **да** |
| `<YC_REGISTRY_ID>` | output `registry_id` (шаг 1) | `diploma-k8s/app/deployment.yaml` | нет |
| `<MASTER_IP>` | output шага 2 | `diploma-k8s/app/ingress.yaml`, `monitoring/grafana-ingress.yaml` | нет |

IP виртуалок вручную никуда не вписываются — см. врезку выше.

---

## Шаг 0. Установить инструменты и получить доступы

```bash
# инструменты (Ubuntu): yc, terraform, ansible, kubectl, helm, docker
# yc:
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash && exec -l $SHELL
yc init                       # авторизация, выбор облака и каталога

# узнать идентификаторы:
yc resource-manager cloud list
yc resource-manager folder list

# ssh-ключ (если ещё нет):
ssh-keygen -t ed25519 -C diploma
cat ~/.ssh/id_ed25519.pub     # это значение пойдёт в infra/terraform.tfvars
```

Также убедись, что **купон/грант активен** (Billing в консоли).

---

## Шаг 1. Bootstrap — сервисные аккаунты, бакет, registry

```bash
cd diploma-infra/bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Открой `terraform.tfvars` и впиши: `yc_token`, `cloud_id`, `folder_id`, `state_bucket_name`.

```bash
terraform init
terraform apply            # подтвердить: yes
```

📸 *(скрин 01 для DIPLOMA.md — итог apply)*

Забери значения для следующего шага (не вставляй их в чат/git):

```bash
terraform output state_bucket_name
terraform output registry_id          # → пригодится для diploma-k8s
terraform output -raw access_key      # → backend.hcl
terraform output -raw secret_key      # → backend.hcl
```

---

## Шаг 2. Infra — VPC, подсети, 3 ВМ, статический IP

```bash
cd ../infra
cp terraform.tfvars.example terraform.tfvars   # yc_token, cloud_id, folder_id, ssh_public_key
cp backend.hcl.example backend.hcl             # bucket, access_key, secret_key из шага 1

terraform init -backend-config=backend.hcl
terraform apply            # создаёт ВМ и всё остальное; подтвердить: yes
```

📸 *(скрин 04 — ресурсы в консоли ЯО)*

Посмотри IP-адреса созданных ВМ (это и есть «данные ВМ», но их даёт Terraform):

```bash
terraform output ansible_hosts
terraform output master_public_ip     # → это <MASTER_IP> для манифестов k8s
```

---

## Шаг 3. Kubernetes через Kubespray

```bash
cd ../../diploma-ansible

# инвентарь заполнится IP-адресами автоматически из terraform output:
./scripts/gen-inventory.sh ../diploma-infra/infra

# поставить Kubespray и зависимости:
git clone --branch release-2.26 https://github.com/kubernetes-sigs/kubespray.git
pip install -r kubespray/requirements.txt

# установить кластер:
ansible-playbook -i inventory/mycluster/hosts.yml -u ubuntu --become kubespray/cluster.yml

# забрать kubeconfig:
export KUBECONFIG=$PWD/inventory/mycluster/artifacts/admin.conf
kubectl get nodes          # ожидаем 3 узла Ready
```

📸 *(скрин 05 — kubectl get nodes / get pods -A)*

---

## Шаг 4. Наполнение кластера (ingress + мониторинг + приложение)

```bash
cd ../diploma-k8s

# 4.1 ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace -f ingress-nginx/values.yaml

# 4.2 мониторинг
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace -f monitoring/values.yaml
kubectl apply -f monitoring/app-dashboard-configmap.yaml

# 4.3 приложение
kubectl apply -f namespace.yaml

# секрет доступа к приватному registry (ключ CI-аккаунта из bootstrap):
# ВАЖНО: сначала выдать SA роль puller — иначе поды упадут в ImagePullBackOff.
REG=$(cd ../diploma-infra/bootstrap && terraform output -raw registry_id)
yc container registry add-access-binding --id "$REG" \
  --role container-registry.images.puller --service-account-name sa-ci
yc iam key create --service-account-name sa-ci -o ci-sa-key.json
kubectl create secret docker-registry ycr-secret -n diploma \
  --docker-server=cr.yandex --docker-username=json_key \
  --docker-password="$(cat ci-sa-key.json)"
```

**Перед `kubectl apply -f app/` замени placeholder'ы:**
- в `app/deployment.yaml` — `<YC_REGISTRY_ID>` на `registry_id` (шаг 1);
- в `app/ingress.yaml` и `monitoring/grafana-ingress.yaml` — `<MASTER_IP>` на `master_public_ip` (шаг 2).

```bash
kubectl apply -f app/
kubectl apply -f monitoring/grafana-ingress.yaml
```

> Первый образ приложения в registry появится после первого прогона CI в `diploma-app` (push в main).
> Для ручной проверки можно собрать и запушить образ локально — см. `diploma-app/README.md`.

---

## Шаг 5. Проверка работы

```bash
MASTER_IP=<master_public_ip>

kubectl get nodes                        # 3 Ready
kubectl -n diploma get pods              # приложение Running
curl http://app.$MASTER_IP.nip.io/       # страница приложения
curl http://app.$MASTER_IP.nip.io/health # {"status":"ok"}
# Grafana:  http://grafana.$MASTER_IP.nip.io  (admin / пароль из monitoring/values.yaml)
```

Если всё открывается — деплой рабочий. Данные доступа занеси в `DIPLOMA.md` (раздел 7).

---

## Выключение (чтобы не жечь купон)

```bash
cd diploma-infra/infra && terraform destroy
```

Object Storage и registry можно оставить (стоят копейки); при желании — `terraform destroy` и в `bootstrap`.
