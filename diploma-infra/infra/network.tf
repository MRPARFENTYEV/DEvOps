# VPC-сеть и по одной подсети в каждой из трёх зон доступности.
resource "yandex_vpc_network" "this" {
  name = "diploma-net"
}

resource "yandex_vpc_subnet" "this" {
  count = length(var.zones)

  name           = "diploma-subnet-${var.zones[count.index]}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.subnet_cidrs[count.index]]
}
