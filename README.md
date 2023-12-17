# README

### Get started

Create a service account on your cluster:

```sh
kubectsl create sa kumevito
```

<!-- TODO: create specific permissions to avoid using cluster-admin -->

Give it cluster admin privileges:

```sh
kubectsl create clusterrolebinding kumevito-cluster-admin --clusterrole=admin --serviceaccount=default:kumevito
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
