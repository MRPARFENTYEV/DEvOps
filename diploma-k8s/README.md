# diploma-k8s

Манифесты и настройки для наполнения Kubernetes-кластера: ingress-контроллер,
система мониторинга и тестовое приложение.

## Что внутри

| Каталог | Назначение |
|---|---|
| `namespace.yaml` | namespace `diploma` для приложения |
| `ingress-nginx/values.yaml` | ingress-nginx как DaemonSet с hostNetwork на master-ноде (:80/:443) |
| `monitoring/values.yaml` | values для kube-prometheus-stack (Prometheus/Grafana/Alertmanager/node-exporter) |
| `monitoring/servicemonitor.yaml` | Prometheus скрейпит `/metrics` приложения |
| `monitoring/grafana-ingress.yaml` | доступ к Grafana на :80 (`grafana.<IP>.nip.io`) |
| `monitoring/app-dashboard-configmap.yaml` | кастомный дашборд Grafana по метрикам приложения |
| `app/` | Deployment / Service / Ingress приложения (`app.<IP>.nip.io`) |

## Порядок деплоя

Предполагается рабочий `kubectl` (kubeconfig из diploma-ansible) и `helm`.

### 1. Ingress-контроллер

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace \
  -f ingress-nginx/values.yaml
```

### 2. Мониторинг (kube-prometheus-stack)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/values.yaml

kubectl apply -f monitoring/app-dashboard-configmap.yaml
kubectl apply -f monitoring/grafana-ingress.yaml   # ПОСЛЕ замены <MASTER_IP>
```

### 3. Приложение

```bash
kubectl apply -f namespace.yaml

# Секрет доступа к приватному YCR (ключ CI-сервисного аккаунта из bootstrap):
kubectl create secret docker-registry ycr-secret \
  -n diploma \
  --docker-server=cr.yandex \
  --docker-username=json_key \
  --docker-password="$(cat ci-sa-key.json)"

# В app/deployment.yaml и *ingress.yaml заменить <YC_REGISTRY_ID> и <MASTER_IP>, затем:
kubectl apply -f app/
```

## Проверка

```bash
kubectl -n diploma get pods
curl http://app.<MASTER_IP>.nip.io/           # страница приложения
curl http://app.<MASTER_IP>.nip.io/health     # {"status":"ok"}
# Grafana: http://grafana.<MASTER_IP>.nip.io  (admin / admin — сменить!)
```

В Grafana должны быть: готовые дашборды Kubernetes (из kube-prometheus-stack)
и кастомный дашборд **Diploma App** с метриками приложения.

## Placeholder'ы, которые ты подставляешь

| Где | Что заменить |
|---|---|
| `app/deployment.yaml` | `<YC_REGISTRY_ID>` → ID реестра (output `registry_id`) |
| `app/ingress.yaml`, `monitoring/grafana-ingress.yaml` | `<MASTER_IP>` → публичный IP master-ноды |
| `monitoring/values.yaml` | `grafana.adminPassword` → свой пароль |

Секреты (`ycr-secret`, ключ SA) создаются командами и в git не попадают.
