output "master_public_ip" {
  description = "Публичный IP master-ноды (kube API + ingress)"
  value       = yandex_compute_instance.master.network_interface[0].nat_ip_address
}

output "master_private_ip" {
  description = "Внутренний IP master-ноды"
  value       = yandex_compute_instance.master.network_interface[0].ip_address
}

output "worker_public_ips" {
  description = "Публичные IP worker-нод"
  value       = [for w in yandex_compute_instance.worker : w.network_interface[0].nat_ip_address]
}

output "worker_private_ips" {
  description = "Внутренние IP worker-нод"
  value       = [for w in yandex_compute_instance.worker : w.network_interface[0].ip_address]
}

# Готовый блок для inventory Ansible/Kubespray.
output "ansible_hosts" {
  description = "IP-адреса для inventory (master + workers)"
  value = {
    master  = yandex_compute_instance.master.network_interface[0].nat_ip_address
    workers = [for w in yandex_compute_instance.worker : w.network_interface[0].nat_ip_address]
  }
}
# trigger ci
