# Один статический публичный IP — на master-ноду, где будет жить ingress-nginx.
# Остальные ноды публичных адресов не получают (экономия купона).
resource "yandex_vpc_address" "ingress" {
  name = "diploma-ingress-ip"

  external_ipv4_address {
    zone_id = var.zones[0]
  }
}
