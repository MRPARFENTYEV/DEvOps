# State хранится в S3-бакете Object Storage, созданном в bootstrap.
#
# Значения bucket / access_key / secret_key НЕ хардкодятся, а передаются при init:
#
#   terraform init \
#     -backend-config="bucket=<имя_бакета_из_bootstrap>" \
#     -backend-config="access_key=<access_key_из_bootstrap>" \
#     -backend-config="secret_key=<secret_key_из_bootstrap>"
#
# Либо через переменные окружения AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
# и файл backend.hcl (см. backend.hcl.example).
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1"
    key    = "infra/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
