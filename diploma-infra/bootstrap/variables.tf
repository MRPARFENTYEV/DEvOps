variable "yc_token" {
  description = "OAuth-токен пользователя Яндекс.Облака (получить на https://oauth.yandex.ru)"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "ID облака (yc resource-manager cloud list)"
  type        = string
}

variable "folder_id" {
  description = "ID каталога/folder (yc resource-manager folder list)"
  type        = string
}

variable "default_zone" {
  description = "Зона по умолчанию"
  type        = string
  default     = "ru-central1-a"
}

variable "tf_sa_name" {
  description = "Имя сервисного аккаунта для Terraform (управление инфраструктурой)"
  type        = string
  default     = "sa-terraform"
}

variable "ci_sa_name" {
  description = "Имя сервисного аккаунта для CI (push образов в registry)"
  type        = string
  default     = "sa-ci"
}

variable "state_bucket_name" {
  description = "Глобально уникальное имя S3-бакета под Terraform state"
  type        = string
}

variable "registry_name" {
  description = "Имя реестра Yandex Container Registry"
  type        = string
  default     = "diploma-registry"
}
