variable "yc_token" {
  description = "OAuth-токен пользователя Яндекс.Облака"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "ID облака"
  type        = string
}

variable "folder_id" {
  description = "ID каталога/folder"
  type        = string
}

variable "zones" {
  description = "Три зоны доступности для подсетей и нод"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "subnet_cidrs" {
  description = "CIDR подсетей по зонам (в том же порядке, что zones)"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ (содержимое ~/.ssh/id_ed25519.pub)"
  type        = string
}

variable "vm_user" {
  description = "Имя пользователя на ВМ (под него кладётся ssh-ключ)"
  type        = string
  default     = "ubuntu"
}

variable "image_family" {
  description = "Семейство образа ОС"
  type        = string
  default     = "ubuntu-2204-lts"
}

# --- Экономия купона: минимальные ресурсы ВМ ---

variable "master_resources" {
  description = "Ресурсы master-ноды (control plane)"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
}

variable "worker_resources" {
  description = "Ресурсы worker-нод"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
}

variable "worker_count" {
  description = "Количество worker-нод (prerыvаemые)"
  type        = number
  default     = 2
}

variable "boot_disk_size" {
  description = "Размер загрузочного диска ноды, ГБ"
  type        = number
  default     = 30
}
