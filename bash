NAMESPACE=airflow
EMAIL=test@gmail.com
DOMAIN=airflow.example.com


if [ "$1" = issuer ]; then

cat << EOF >> staging-issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
  namespace: $NAMESPACE
spec:
  acme:
    # Staging API
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: account-key-staging
    solvers:
    - http01:
       ingress:
         class: nginx
EOF

kubectl create -f staging-issuer.yaml -n $NAMESPACE

rm -f staging-issuer.yaml

cat << EOF >> production-issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-production
  namespace: $NAMESPACE
spec:
  acme:
    # Staging API
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: account-key-production
    solvers:
    - http01:
       ingress:
         class: nginx
EOF

kubectl create -f production-issuer.yaml -n $NAMESPACE

rm -f production-issuer.yaml

fi


if [ "$1" = staging ]; then
cat << EOF >> staging-certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: $NAMESPACE-staging
  namespace: $NAMESPACE
spec:
  secretName: $NAMESPACE-staging-certificate
  issuerRef:
    name: letsencrypt-staging
  dnsNames:
  - $DOMAIN

EOF
kubectl create -f staging-certificate.yaml -n $NAMESPACE
rm -f  staging-certificate.yaml
fi

if [ "$1" = production ]; then
cat << EOF >> production-certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: $NAMESPACE-production
  namespace: $NAMESPACE
spec:
  secretName: $NAMESPACE-production-certificate
  issuerRef:
    name: letsencrypt-production
  dnsNames:
  - $DOMAIN
    
EOF
kubectl create -f production-certificate.yaml -n $NAMESPACE
rm -f  production-certificate.yaml
fi


#metadata:
#  annotations:
#    cert-manager.io/issuer: letsencrypt-staging
#spec:
#  rules:
#  tls:
#  - hosts:
#    - invoiceninja.optimusconsortium.com
#    secretName: invoiceninja-staging-certificate
    
#metadata:
#  annotations:
#    cert-manager.io/issuer: letsencrypt-production
#spec:
#  rules:
#  tls:
#  - hosts:
#    - invoiceninja.optimusconsortium.com
#    secretName: invoiceninja-production-certificate
