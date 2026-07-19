terraform {
  required_version = ">= 1.6"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.120"
    }
  }
}

provider "yandex" {
  # Локально: IAM-токен через -var="yc_token=$(yc iam create-token)".
  # В CI: token пустой → провайдер берёт ключ SA из env YC_SERVICE_ACCOUNT_KEY_FILE.
  token     = var.yc_token != "" ? var.yc_token : null
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zones[0]
}
