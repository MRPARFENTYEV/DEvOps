# diploma-infra

Инфраструктура дипломного проекта в Яндекс.Облаке как код (Terraform).

Две независимые конфигурации:

| Папка | Что создаёт | State |
|---|---|---|
| `bootstrap/` | Сервисные аккаунты (Terraform + CI) со scoped-ролями, S3-бакет под state, Container Registry | локальный |
| `infra/` | VPC + 3 подсети (зоны a/b/d), security group, 1 master + 2 preemptible worker, статический IP | S3-бакет из bootstrap |

## Порядок применения

### 1. Bootstrap (первым, со своего OAuth-токена)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # впиши yc_token, cloud_id, folder_id, имя бакета
terraform init
terraform apply

# сохрани значения для следующего шага:
terraform output state_bucket_name
terraform output registry_id
terraform output -raw access_key      # AWS_ACCESS_KEY_ID для backend
terraform output -raw secret_key      # AWS_SECRET_ACCESS_KEY для backend
```

### 2. Основная инфраструктура (state уже в бакете)

```bash
cd ../infra
cp terraform.tfvars.example terraform.tfvars   # впиши yc_token, cloud_id, folder_id, ssh_public_key
cp backend.hcl.example backend.hcl             # впиши bucket/access_key/secret_key из шага 1

terraform init -backend-config=backend.hcl
terraform apply

terraform output ansible_hosts        # IP-адреса → в inventory diploma-ansible
```

### 3. Уничтожение (чтобы не жечь купон)

```bash
cd infra && terraform destroy
```

## Данные, которые ты подставляешь (всё — переменные)

Ничего не захардкожено. Секреты не коммитятся (см. `.gitignore` — в git идут только `*.example`).

| Где | Что |
|---|---|
| `bootstrap/terraform.tfvars` | `yc_token`, `cloud_id`, `folder_id`, `state_bucket_name` |
| `infra/terraform.tfvars` | `yc_token`, `cloud_id`, `folder_id`, `ssh_public_key` |
| `infra/backend.hcl` | `bucket`, `access_key`, `secret_key` (из output bootstrap) |

## GitHub Actions (terraform-пайплайн)

`.github/workflows/terraform.yml`: на **pull request** — `terraform plan` с комментарием в PR;
на **push в main** — `terraform apply`.

Секреты репозитория (**Settings → Secrets and variables → Actions**):

| Секрет | Значение |
|---|---|
| `YC_TOKEN` | OAuth-токен |
| `YC_CLOUD_ID` / `YC_FOLDER_ID` | ID облака и каталога |
| `SSH_PUBLIC_KEY` | публичный ssh-ключ |
| `TF_STATE_BUCKET` | имя бакета (output `state_bucket_name`) |
| `YC_STORAGE_ACCESS_KEY` / `YC_STORAGE_SECRET_KEY` | ключи из output bootstrap |
