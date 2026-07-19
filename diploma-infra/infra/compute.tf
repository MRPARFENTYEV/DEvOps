data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

locals {
  ssh_metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }
}

# --- Master-нода (control plane). Не prerываемая, со статическим public IP. ---
resource "yandex_compute_instance" "master" {
  name        = "k8s-master"
  hostname    = "k8s-master"
  zone        = var.zones[0]
  platform_id = "standard-v3"

  resources {
    cores         = var.master_resources.cores
    memory        = var.master_resources.memory
    core_fraction = var.master_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.boot_disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.this[0].id
    nat                = true
    nat_ip_address     = yandex_vpc_address.ingress.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.k8s.id]
  }

  metadata = local.ssh_metadata
}

# --- Worker-ноды. Prerываемые (preemptible) ради экономии купона. ---
resource "yandex_compute_instance" "worker" {
  count = var.worker_count

  name        = "k8s-worker-${count.index + 1}"
  hostname    = "k8s-worker-${count.index + 1}"
  zone        = var.zones[(count.index + 1) % length(var.zones)]
  platform_id = "standard-v3"

  resources {
    cores         = var.worker_resources.cores
    memory        = var.worker_resources.memory
    core_fraction = var.worker_resources.core_fraction
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.boot_disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.this[(count.index + 1) % length(var.zones)].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s.id]
  }

  metadata = local.ssh_metadata
}
