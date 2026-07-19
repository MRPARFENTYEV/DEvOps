# diploma-devops

Дипломный проект: облачная инфраструктура, Kubernetes и CI/CD в Яндекс.Облаке.
**Монорепозиторий** — четыре подпроекта в одном репозитории.

## Структура

| Папка | Назначение |
|---|---|
| [`diploma-infra/`](diploma-infra/) | Terraform: `bootstrap/` (сервисные аккаунты, S3-бакет под state, registry) + `infra/` (VPC, 3 ВМ, security groups, статический IP) |
| [`diploma-ansible/`](diploma-ansible/) | Kubespray-инвентарь и настройки для установки Kubernetes на ВМ |
| [`diploma-app/`](diploma-app/) | Тестовое приложение (FastAPI): код, тесты, Dockerfile |
| [`diploma-k8s/`](diploma-k8s/) | Манифесты кластера: ingress-nginx, kube-prometheus-stack, приложение |

## CI/CD (GitHub Actions)

Воркфлоу лежат в корневом [`.github/workflows/`](.github/workflows/) (в монорепо GitHub читает только корень):

| Workflow | Триггер | Что делает |
|---|---|---|
| `terraform.yml` | изменения в `diploma-infra/infra/**` | PR → `terraform plan` (комментарий в PR); push в main → `terraform apply` |
| `app-ci-cd.yml` | push в main / тег `vX.Y.Z` | тесты → сборка образа → push в YCR; по тегу — деплой в кластер |

## Документация

- **[DIPLOMA.md](DIPLOMA.md)** — сводный документ для сдачи (соответствие правилам приёма).
- **[RUN.md](RUN.md)** — пошаговый запуск полного деплоя с нуля.
- README в каждой подпапке — детали по конкретному компоненту.

## Быстрый старт

См. [RUN.md](RUN.md). Кратко: `bootstrap` → `infra` → Kubespray → манифесты → проверка.
