# Login in the right tenant
az login
# Register Azure AD application
APP_NAME="argocd"
az ad app create \
--display-name $APP_NAME \
--reply-urls https://localhost:8080/auth/callback \
--required-resource-accesses @required-resource-accesses.json \
--optional-claims @optional-claims.json 



# Edit argocd-secret with the value of the client secret in base 64
PASSWORD=$(az ad app credential reset \
--id $(az ad app list --query "[?displayName=='$APP_NAME'].appId" --all -o tsv) \
--query "password" -o tsv)
echo $PASSWORD | base64

# Use VS code to edit the files
export KUBE_EDITOR="code --wait"

kubectl edit secret argocd-secret -n argocd

# Restart deployment
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout restart deployment argocd-dex-server -n argocd