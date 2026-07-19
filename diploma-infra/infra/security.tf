# Security group для нод кластера.
resource "yandex_vpc_security_group" "k8s" {
  name       = "diploma-k8s-sg"
  network_id = yandex_vpc_network.this.id

  # SSH (Ansible/Kubespray).
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Kubernetes API server.
  ingress {
    protocol       = "TCP"
    description    = "kube-apiserver"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  # HTTP/HTTPS через ingress-nginx (Grafana и приложение).
  ingress {
    protocol       = "TCP"
    description    = "HTTP ingress"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS ingress"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # NodePort-диапазон Kubernetes.
  ingress {
    protocol       = "TCP"
    description    = "NodePort range"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  # Внутрикластерный трафик между нодами (все порты внутри подсетей).
  ingress {
    protocol       = "ANY"
    description    = "Внутрикластерный трафик"
    v4_cidr_blocks = var.subnet_cidrs
    from_port      = 0
    to_port        = 65535
  }

  # ICMP (ping/диагностика).
  ingress {
    protocol       = "ICMP"
    description    = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Исходящий трафик — куда угодно.
  egress {
    protocol       = "ANY"
    description    = "Любой исходящий"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
