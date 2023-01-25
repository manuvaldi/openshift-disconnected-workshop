rm -Rf custom-catalog; mkdir -p custom-catalog/configs
opm render registry.redhat.io/redhat/redhat-operator-index:v4.11 > custom-catalog/redhat-operator-index.json

operators="elasticsearch-operator cluster-logging cincinnati-operator"
for operator in $operators; do
  cat redhat-operator-index.json | jq --arg operator "$operator" 'select( .package == $operator or .name == $operator)' >> custom-catalog/configs/index.json
done

opm generate dockerfile custom-catalog/configs
```
cd custom-catalog
podman build -t registry.dsal:8443/mirror/redhat/custom-redhat-operator-index:v1 -f configs.Dockerfile
cd ..

podman push --tls-verify=false --authfile ~/pull-secret-all.json registry.dsal:8443/mirror/redhat/custom-redhat-operator-index:v1
