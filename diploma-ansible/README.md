# diploma-ansible

Развёртывание Kubernetes-кластера на подготовленные Terraform'ом ВМ — через
[Kubespray](https://github.com/kubernetes-sigs/kubespray).

Этот репозиторий хранит **только инвентарь и оверрайды** (`inventory/mycluster/`).
Сам Kubespray подтягивается отдельно (он большой и обновляется).

## Шаги

### 1. Подготовить инвентарь

```bash
# автоматически из terraform output:
./scripts/gen-inventory.sh ../diploma-infra/infra

# либо вручную:
cp inventory/mycluster/hosts.yml.example inventory/mycluster/hosts.yml
# и вписать IP из `terraform -chdir=../diploma-infra/infra output ansible_hosts`
```

### 2. Поставить Kubespray и зависимости

```bash
git clone --branch release-2.26 https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
pip install -r requirements.txt
cd ..
```

### 3. Прогнать плейбук установки кластера

```bash
ansible-playbook -i inventory/mycluster/hosts.yml \
  -u ubuntu --become --become-user=root \
  kubespray/cluster.yml
```

> Наш `ansible.cfg` и `group_vars/` подхватятся автоматически, т.к. лежат рядом с инвентарём.

### 4. Забрать kubeconfig

При `kubeconfig_localhost: true` Kubespray положит конфиг в
`inventory/mycluster/artifacts/admin.conf`:

```bash
export KUBECONFIG=$PWD/inventory/mycluster/artifacts/admin.conf
# заменить внутренний адрес API на публичный IP master-ноды, затем:
kubectl get nodes
kubectl get pods --all-namespaces
```

## Что настроено (group_vars)

- CNI: **Calico**, container runtime: **containerd**, kube-proxy: **ipvs**;
- в SSL-сертификат API добавлен публичный IP master-ноды (`supplementary_addresses_in_ssl_keys`)
  — чтобы `kubectl` работал с локальной машины;
- дашборд Kubernetes выключен, Helm включён (нужен для kube-prometheus и ingress-nginx);
- CoreDNS в одну реплику — нод мало, экономим ресурсы.

## Данные, которые ты подставляешь

Только **IP-адреса ВМ** в `inventory/mycluster/hosts.yml` — берутся из `terraform output`.
Секретов здесь нет; реальный `hosts.yml` и `artifacts/` в git не коммитятся.
