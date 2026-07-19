#!/usr/bin/env bash
# Генерирует inventory/mycluster/hosts.yml из `terraform output` конфигурации infra.
# Использование:  ./scripts/gen-inventory.sh [путь_к_diploma-infra/infra]
set -euo pipefail

INFRA_DIR="${1:-../diploma-infra/infra}"
OUT="inventory/mycluster/hosts.yml"

command -v jq >/dev/null || { echo "Нужен jq"; exit 1; }

echo "Читаю terraform output из $INFRA_DIR ..."
JSON="$(terraform -chdir="$INFRA_DIR" output -json)"

MASTER_PUB=$(echo "$JSON"  | jq -r '.master_public_ip.value')
MASTER_PRIV=$(echo "$JSON" | jq -r '.master_private_ip.value')
W_PUB=$(echo "$JSON"  | jq -r '.worker_public_ips.value')
W_PRIV=$(echo "$JSON" | jq -r '.worker_private_ips.value')

W1_PUB=$(echo "$W_PUB"  | jq -r '.[0]'); W1_PRIV=$(echo "$W_PRIV" | jq -r '.[0]')
W2_PUB=$(echo "$W_PUB"  | jq -r '.[1]'); W2_PRIV=$(echo "$W_PRIV" | jq -r '.[1]')

sed -e "s/MASTER_PUBLIC_IP/$MASTER_PUB/"   -e "s/MASTER_PRIVATE_IP/$MASTER_PRIV/" \
    -e "s/WORKER1_PUBLIC_IP/$W1_PUB/"      -e "s/WORKER1_PRIVATE_IP/$W1_PRIV/" \
    -e "s/WORKER2_PUBLIC_IP/$W2_PUB/"      -e "s/WORKER2_PRIVATE_IP/$W2_PRIV/" \
    inventory/mycluster/hosts.yml.example > "$OUT"

echo "Готово: $OUT"
