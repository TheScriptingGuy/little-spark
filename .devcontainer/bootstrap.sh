#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export KUBE_DNS_IP=$(cat "${SCRIPT_DIR}/kube-dns-ip.env")

# Add the kube-dns IP to the resolv.conf
{
    echo "nameserver $KUBE_DNS_IP"
    cat /etc/resolv.conf
} | sudo tee /etc/resolv.conf > /dev/null

echo "Added kube-dns IP ($KUBE_DNS_IP) to /etc/resolv.conf"

sleep infinity