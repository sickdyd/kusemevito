# README

### Get started

## System packages

Install graphviz, which is used to generate `.png` files of the graph:

```sh
brew install graphviz
```

## Cluster config

Create a service account on your cluster:

```sh
kubectl create sa kumevito
```

<!-- TODO: create specific permissions to avoid using cluster-admin -->

Give it cluster admin privileges:

```sh
kubectl create clusterrolebinding kumevito-cluster-admin --clusterrole=cluster-admin --serviceaccount=default:kumevito
```

Create the secret for the service account:

```sh
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: kumevito-secret
  annotations:
    kubernetes.io/service-account.name: kumevito
type: kubernetes.io/service-account-token
EOF
```

Get the token:

```sh
kubectl get secret kumevito-secret -o jsonpath="{.data.token}" | base64 --decode
```

Create a `.env` file follwing the `.env.example` and add the `CLUSTER_SERVICE_ACCOUNT_TOKEN` with the value you got from the previous command.

```sh
CLUSTER_SERVICE_ACCOUNT_TOKEN=< add here token >
CLUSTER_HOST=
CLUSTER_PORT=
```

Create a deployment, a service and an ingress:

```sh
cat<<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-pod
  template:
    metadata:
      labels:
        app: nginx-pod
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx-pod
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
EOF
```
