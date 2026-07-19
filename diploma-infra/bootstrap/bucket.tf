# S3-бакет в Object Storage под хранение Terraform state основной конфигурации.
resource "yandex_storage_bucket" "tf_state" {
  access_key = yandex_iam_service_account_static_access_key.terraform.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform.secret_key
  bucket     = var.state_bucket_name

  # Версионирование state — чтобы можно было откатиться на прошлую версию.
  versioning {
    enabled = true
  }

  anonymous_access_flags {
    read = false
    list = false
  }
}
