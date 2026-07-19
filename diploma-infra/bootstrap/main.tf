# Сервисный аккаунт, от имени которого Terraform управляет инфраструктурой.
# Ему выдаются точечные (scoped) роли на каталог — НЕ права суперпользователя.
resource "yandex_iam_service_account" "terraform" {
  name        = var.tf_sa_name
  description = "SA для управления инфраструктурой из Terraform"
  folder_id   = var.folder_id
}

# Необходимый и достаточный набор ролей на каталог.
locals {
  terraform_sa_roles = [
    "compute.editor",           # ВМ и диски
    "vpc.admin",                # сети, подсети, адреса, security groups
    "storage.admin",            # Object Storage (бакет под state)
    "container-registry.admin", # реестр образов
    "iam.serviceAccounts.user", # использовать SA при создании ВМ
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "terraform" {
  for_each = toset(local.terraform_sa_roles)

  folder_id = var.folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

# Статический ключ доступа: используется как access_key/secret_key
# для S3-совместимого Object Storage (backend Terraform).
resource "yandex_iam_service_account_static_access_key" "terraform" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Static key для доступа к Object Storage (state) и бакету"
}

# Отдельный SA для CI: умеет только пушить образы в registry.
resource "yandex_iam_service_account" "ci" {
  name        = var.ci_sa_name
  description = "SA для CI: сборка и push образов в YCR"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "ci_pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.ci.id}"
}

# Роль puller — чтобы кластер мог ТЯНУТЬ приватный образ (imagePullSecret).
# Без неё поды падают в ImagePullBackOff.
resource "yandex_resourcemanager_folder_iam_member" "ci_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.ci.id}"
}
