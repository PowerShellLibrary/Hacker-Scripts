# Azure VM Creation Script - Debian 11
# This script creates a Debian 11 VM in Azure with a predefined network security group allowing SSH access.
# Prerequisites:
# - Azure CLI installed and logged in (`az login`)
# - A resource group named "Playground" with a network security group "ssh-common-ngs" allowing SSH on port 22.

$SUBSCRIPTION_ID = '7f796072-6602-418a-8ba9-92ebc9a4797d'
$VM_NAME = 'vmDebian12'
$USER = 'alan'
$PASSWORD = 'F897cab3c9f1475d8a7ff96d549358f2.#1A'
$LOC = 'polandcentral' # `az account list-locations -o table`
$NGS = "/subscriptions/$SUBSCRIPTION_ID/resourcegroups/Playground/providers/Microsoft.Network/networkSecurityGroups/ssh-common-ngs" # Pre-created NSG with SSH allowed on port 22.
$RG = "playground-azure-vm-rg-001"

az account set --subscription $SUBSCRIPTION_ID

Write-Host "Deleting old resource group" -ForegroundColor Magenta
Start-Job -ScriptBlock {
    az group delete -n "playground-azure-vm-rg-000" -y
} | Out-Null

Write-Host "Creating resource group: $RG" -ForegroundColor Green
az group create -n $RG -l $LOC | Out-Null

Write-Host "Creating VNet and Public IP in parallel" -ForegroundColor Green
$vnetJob = Start-Job {
    az network vnet create `
        -g $using:RG `
        -n "$using:VM_NAME-vnet" `
        --address-prefix 10.0.0.0/16 `
        --subnet-name "$using:VM_NAME-subnet" `
        --subnet-prefix 10.0.0.0/24 | Out-Null
}

$ipJob = Start-Job {
    az network public-ip create `
        -g $using:RG `
        -n "$using:VM_NAME-pip" `
        --sku Standard `
        --allocation-method Static | Out-Null
}

Wait-Job $vnetJob, $ipJob | Receive-Job

Write-Host "Creating NIC" -ForegroundColor Green
az network nic create `
    -g $RG `
    -n "$VM_NAME-nic" `
    --vnet-name "$VM_NAME-vnet" `
    --subnet "$VM_NAME-subnet" `
    --public-ip-address "$VM_NAME-pip" `
    --network-security-group $NGS | Out-Null

Write-Host "Creating VM" -ForegroundColor Green
az vm create `
    -g $RG `
    -n $VM_NAME `
    --nics "$VM_NAME-nic" `
    --image "Debian:debian-12:12-gen2:latest" `
    --admin-username $USER `
    --admin-password $PASSWORD `
    --size Standard_B1ms | Out-Null

Write-Host "Done. You can connect to the VM using:" -ForegroundColor Green
$publicIP = az network public-ip show `
    -g $RG `
    -n "$VM_NAME-pip" `
    --query "ipAddress" `
    -o tsv

"ssh -o StrictHostKeyChecking=no $USER@$publicIP"