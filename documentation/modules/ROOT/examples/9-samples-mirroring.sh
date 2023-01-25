pullsecret=$1
dstregistry=registry.dsal:8443/mirror/samples/
json="$(oc get cm -n openshift-cluster-samples-operator imagestreamtag-to-image -o json )"

echo "" > mapping.txt.tmp
echo "" > samples-configmap-data.txt
for key in `echo $json | jq --raw-output '.data | keys[]'`; do
  image="$(echo $json | jq --arg key $key -r '.data | .[$key]')"
  urlpath="$(echo $image | cut -d/ -f2-)"
  urlpathwithouttag="$(echo $urlpath | cut -d: -f1)"
  echo "IS: $key"
  echo "Image: $image"
  echo "Path: $urlpath"
  echo "$key: '${dstregistry}${urlpath}'`" >> samples-configmap-data.txt
  if echo $urlpath | grep -q -v ":"; then
    continue
  fi
  echo $image=${dstregistry}${urlpath} >> mapping.txt.tmp
  echo "---"
done

sort mapping.txt.tmp | uniq > mapping.txt
rm -Rf mapping.txt.tmp