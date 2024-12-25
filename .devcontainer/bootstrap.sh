#!/usr/bin/env bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or run as root."
    exit 1
fi

# Get the ClusterIP of the kube-dns service
KUBE_DNS_IP=$(kubectl get svc kube-dns -n kube-system -o jsonpath='{.spec.clusterIP}')

# Check if the IP was retrieved successfully
if [ -z "$KUBE_DNS_IP" ]; then
    echo "Failed to retrieve the ClusterIP of the kube-dns service."
    exit 1
fi

# Backup the current resolv.conf
cp /etc/resolv.conf /etc/resolv.conf.backup

# Add the kube-dns IP to the resolv.conf
echo "nameserver $KUBE_DNS_IP" >> /etc/resolv.conf

echo "Added kube-dns IP ($KUBE_DNS_IP) to /etc/resolv.conf"

sleep infinity