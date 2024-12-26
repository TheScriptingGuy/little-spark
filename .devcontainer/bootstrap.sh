#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export KUBE_DNS_IP=$(cat "${SCRIPT_DIR}/kube-dns-ip.env")

# Add the kube-dns IP to the resolv.conf
{
    echo "nameserver $KUBE_DNS_IP"
    cat /etc/resolv.conf
} | sudo tee /etc/resolv.conf > /dev/null

echo "Added kube-dns IP ($KUBE_DNS_IP) to /etc/resolv.conf"

# Define the kubeconfig file path
KUBECONFIG='/usr/local/share/kube-localhost/config'
# Define output directory for certificates and keys
OUTPUT_DIR="/usr/local/share/ca-certificates/kube-certs"
sudo mkdir -p $OUTPUT_DIR

# Extract client certificate
CLIENT_CERT=$(yq '.users[0].user."client-certificate-data"' $KUBECONFIG | sed 's/"//g')
echo $CLIENT_CERT | base64 --decode > $OUTPUT_DIR/client.crt

# Extract client key
CLIENT_KEY=$(yq '.users[0].user."client-key-data"' $KUBECONFIG | sed 's/"//g')
echo $CLIENT_KEY | base64 --decode > $OUTPUT_DIR/client.key

# Extract cluster CA certificate
CLUSTER_CA=$(yq '.clusters[0].cluster."certificate-authority-data"' $KUBECONFIG | sed 's/"//g')
echo $CLUSTER_CA | base64 --decode > $OUTPUT_DIR/ca.crt

echo "Certificates and keys have been extracted to $OUTPUT_DIR"

# Update the CA certificates
sudo update-ca-certificates

sleep infinity