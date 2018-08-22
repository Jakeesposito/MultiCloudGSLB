#! /bin/bash

# Color Variables
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

#Install AWS CLI, Jq for json, and pwgen
sudo apt-get update > /dev/null
echo ${mag}Installing Amazon Web Services CLI...${end}
sudo apt-get -y install awscli > /dev/null
sleep 3
echo ${grn}[COMPLETE]${end}
sleep 3
echo ${mag}Installing jq...${end}
sudo apt-get -y install jq > /dev/null
echo ${grn}[COMPLETE]${end}
sleep 3
echo ${mag}Installing Password Generator...${end}
sudo apt-get install pwgen > /dev/null
echo ${grn}[COMPLETE]${end}
sleep 3

# Install Azure CLI
AZ_REPO=$(lsb_release -cs)
echo ${mag}Installing Azure CLI 2.0 For Ubuntu ${AZ_REPO}...${end}
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list > /dev/null 2>&1
curl -L -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - > /dev/null 2>&1
sudo apt-get install apt-transport-https > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install azure-cli > /dev/null
sleep 3
echo ${grn}[COMPLETE]${end}
sleep 3

# Authenticate into Azure
echo ${mag}Authenticating into Azure...${end}
sleep 3
ten_id=$(az login | jq .[] | jq '.tenantId' | tr -d '"')
echo ${mag}Signed in with Tenant ID ${grn}${ten_id}${end}
sleep 3
echo ${mag}Creating Service Principal Account...${end}
sleep 3
az group create -n 'AnsibleResourceGroup' -l 'eastus' > /dev/null
az provider register -n Microsoft.KeyVault &> /dev/null
echo ${grn}[COMPLETE]${end}

echo ${mag}Registering...${end}
reg_state=$(az provider show -n Microsoft.KeyVault | jq '.registrationState' | tr -d '"')
# Wait for Registration
while [ "$reg_state" != "Registered" ]
do
sleep 6
echo ${red}$reg_state${end}
reg_state=$(az provider show -n Microsoft.KeyVault | jq '.registrationState' | tr -d '"')
done
echo ${grn}Registered${end}
sleep 3
echo ${mag}Creating Unique Key Vault...${end}
vault_name=$(pwgen -n -B 12 1)
az keyvault create --resource-group AnsibleResourceGroup --name ${vault_name} --location 'eastus' > /dev/null
echo ${mag}Key Vault ${grn}${vault_name}${mag} Created${end}
sleep 3


az ad sp create-for-rbac --name AnsibleServiceAccount --password AnsibleAccount1 --create-cert --cert AnsibleCert --keyvault ${vault_name} | jq


# Authenticate into AWS
echo ${mag}Enter Access Keys Below...${red}
aws configure
echo ${mag}Testing AWS Connection...${end}
sleep 3
aws sts get-caller-identity | jq
sleep 3


echo ${mag}...........................................................${end}
echo ${mag}...........................................................${end}
echo ${mag}............${grn}Amazon Web Services Setup Complete${mag}.............${end}
echo ${mag}...........................................................${end}
echo ${mag}...........................................................${end}
sleep 1
