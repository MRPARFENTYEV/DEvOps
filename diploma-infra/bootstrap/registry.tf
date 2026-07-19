# Реестр образов Yandex Container Registry — сюда CI пушит образ приложения.
resource "yandex_container_registry" "this" {
  name      = var.registry_name
  folder_id = var.folder_id
}
