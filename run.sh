# Sample script for testing locally

devopsrg='mediawiki-devops-rg'
location='eastus'
stname='mediawikidevopsst'

ARM_ACCESS_KEY=$(az storage account keys list --resource-group $devopsrg --account-name $stname --query [0].value -o tsv)

#packer commands to test locally
packer fmt mediawiki.pkr.hcl
packer validate -var-file="mediawiki.auto.pkrvars.hcl" mediawiki.pkr.hcl
packer build -var-file="mediawiki.auto.pkrvars.hcl" mediawiki.pkr.hcl


#terraform commands to test locally
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve