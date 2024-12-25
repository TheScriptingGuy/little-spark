
kubectl get svc kube-dns -n kube-system -o jsonpath="{.spec.clusterIP}" > kube-dns-ip.env
