output "state_bucket_name" {
  description = "Имя бакета — вписать в infra/backend.tf (или -backend-config)"
  value       = yandex_storage_bucket.tf_state.bucket
}

output "registry_id" {
  description = "ID реестра YCR — секрет YC_REGISTRY_ID в GitHub Actions"
  value       = yandex_container_registry.this.id
}

output "terraform_sa_id" {
  description = "ID сервисного аккаунта Terraform"
  value       = yandex_iam_service_account.terraform.id
}

output "ci_sa_id" {
  description = "ID сервисного аккаунта CI (для него создать authorized key -> секрет YC_SA_KEY)"
  value       = yandex_iam_service_account.ci.id
}

# Ключи доступа к Object Storage. Нужны для backend infra и для terraform-пайплайна.
# Выводятся как sensitive: смотреть через `terraform output -raw <name>`.
output "access_key" {
  description = "AWS_ACCESS_KEY_ID для S3-backend"
  value       = yandex_iam_service_account_static_access_key.terraform.access_key
  sensitive   = true
}

output "secret_key" {
  description = "AWS_SECRET_ACCESS_KEY для S3-backend"
  value       = yandex_iam_service_account_static_access_key.terraform.secret_key
  sensitive   = true
}
