cat <<EOF | tee /etc/motd
.--- k8s lab ---.
|  Master Node  |
'---------------'
EOF
exit 0

#echo "::: INSTALL HELM SCRIPT WAY :::"
#curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
#chmod 700 /tmp/get_helm.sh
#/tmp/get_helm.sh
#exit 0
