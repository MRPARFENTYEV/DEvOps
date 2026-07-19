# diploma-app

Тестовое приложение дипломного проекта — минимальный FastAPI-сервис, который упаковывается
в Docker-образ, публикуется в Yandex Container Registry и разворачивается в Kubernetes.

## Эндпоинты

| Путь | Назначение |
|---|---|
| `/` | HTML-страница: версия приложения и имя пода |
| `/health` | Проверка живости (liveness/readiness пробы Kubernetes) |
| `/metrics` | Метрики в формате Prometheus (`app_requests_total`, `app_request_duration_seconds`) |

## Локальный запуск

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt

uvicorn app.main:app --reload      # http://127.0.0.1:8000
pytest -v                          # тесты
```

## Сборка образа

```bash
docker build --build-arg APP_VERSION=v1.0.0 -t diploma-app:v1.0.0 .
docker run --rm -p 8000:8000 diploma-app:v1.0.0
```

## CI/CD (GitHub Actions)

Пайплайн `.github/workflows/ci-cd.yml`:

- **любой коммит / PR** → `pytest`;
- **push в `main`** → тесты, сборка образа, push в YCR с тегами `:latest` и `:<sha>`;
- **push тега `vX.Y.Z`** → тесты, сборка, push с тегом `:vX.Y.Z`, затем деплой этой версии в кластер
  (`kubectl set image` + ожидание `rollout status`).

### Секреты, которые нужно завести в репозитории

**Settings → Secrets and variables → Actions → New repository secret**

| Секрет | Что это | Откуда взять |
|---|---|---|
| `YC_SA_KEY` | JSON-ключ сервисного аккаунта CI (целиком, одной строкой) | `yc iam key create --service-account-name <sa-ci> -o key.json` |
| `YC_REGISTRY_ID` | ID реестра в YCR | `terraform output registry_id` в `diploma-infra/bootstrap` |
| `KUBE_CONFIG` | kubeconfig кластера **в base64** | `base64 -w0 ~/.kube/config` |

> Ни один из этих секретов не хранится в коде — только в GitHub Secrets.
