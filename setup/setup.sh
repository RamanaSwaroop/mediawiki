# Sample script for initial set up
devopsrg='mediawiki-devops-rg'
location='eastus'
stname='mediawikidevopsst'
container='tfstate'

# RG for DevOps
az group create -n $devopsrg -l $location

az storage account create -n $stname -l $location -g $devopsrg --sku Standard_LRS --allow-blob-public-access false

key=$(az storage account keys list --resource-group $devopsrg --account-name $stname --query [0].value -o tsv)

# Create blob container
az storage container create --name $container --account-name $stname --account-key $key

rand=$RANDOM
name=devopskv$rand
echo $name 
az keyvault create -n $name -g $devopsrg -l $location

# az sig create -g mediawiki-image-rg --gallery-name mediawikisig

