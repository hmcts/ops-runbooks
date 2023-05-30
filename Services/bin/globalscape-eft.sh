#!/bin/bash 

# Set subscription to where VMs live
az account set --subscription HMCTS-HUB-PROD-INTSVC

# Check jq installation
if ! command -v jq &> /dev/null
then
    echo "jq not installed"
    exit
fi

# Required vars that are easier to alter here if they change in future
EFT_RG="RDO-HUB-SFTP-PROD"
LOCAL_PORT=5555
VM_RDP_PORT=3389
BASTION_HOSTNAME="bastion-prod.platform.hmcts.net"
BASTION_VM_NAME="bastion-prod"
BASTION_RG_NAME="bastion-prod-rg"
BASTION_SUBSCRIPTION="DTS-MANAGEMENT-PROD-INTSVC"

# Select VM
read -p "Enter one of the VMs -> rdo-sftp-eft-0 or rdo-sftp-eft-1:" SELECTED_VM
echo $SELECTED_VM
if [[ ${SELECTED_VM} != "rdo-sftp-eft-1" && ${SELECTED_VM} != "rdo-sftp-eft-0" ]]; then
    echo "Please provide a valid VM."
    exit 1
fi

# Add bastion host to config file
echo "If hanging for too long, check your bastion JIT - https://tools.hmcts.net/confluence/pages/viewpage.action?pageId=1411089455"
az ssh config --ip \*.platform.hmcts.net --file ~/.ssh/config

# Port forward to Windows VM via bastion
echo "If hanging for too long, check connected to F5 VPN... - https://portal.platform.hmcts.net"
# Pull private IP from selected VM
IP=$(az vm show -g ${EFT_RG} -n ${SELECTED_VM} -d | jq -r '.privateIps')
echo "Establishing forward to IP: ${IP}..."
if [[ ${SELECTED_VM} != "" ]]; then
    echo "Ready to connect. Open RDP software and RDP to localhost:${LOCAL_PORT}. You can get user credentials from Connecting to the VM step in ops-runbooks."
    ssh -L ${LOCAL_PORT}:${IP}:${VM_RDP_PORT} ${BASTION_HOSTNAME}
else
    echo "Problem getting VM IP."
    exit 1
fi
