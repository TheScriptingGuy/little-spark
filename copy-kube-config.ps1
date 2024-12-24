# Define the path to your kubeconfig file
$kubeConfigPath = "$HOME\.kube\config"

Copy-Item -Path $kubeConfigPath -Destination $PSScriptRoot -Force