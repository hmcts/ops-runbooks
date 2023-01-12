#!/bin/bash

ENV=("ptl" "nonprod")
LOCATION=("-private-" "-")
RG="aks-infra-cftptl-intsvc-rg"
az account set --subscription DTS-CFTPTL-INTSVC

for env in ${ENV[@]}
do
    for location in ${LOCATION[@]}
    do
        echo "Private IPS of VM instances in activegate$location$env-vmss scale set:"
        az vmss nic list -g $RG --vmss-name activegate$location$env-vmss  | jq -r '.[].ipConfigurations[].privateIpAddress'
    done
done