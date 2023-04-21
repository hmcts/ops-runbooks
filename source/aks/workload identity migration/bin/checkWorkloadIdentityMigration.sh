#!/bin/bash

# temp workaround for external.metrics.k8s.io/v1beta1 error
# https://github.com/kubernetes-sigs/custom-metrics-apiserver/issues/146
exec 2>/dev/null

# positional arguments
# view_migrated
if [ "$1" = "view_labelled" ]; then
    cat has_label.csv | sed 's/,/ ,/g' | column -t -s, | less -S
fi

# view_not_migrated
if [ "$1" = "view_not_labelled" ]; then
    cat no_label.csv | sed 's/,/ ,/g' | column -t -s, | less -S
fi

# view_azureidentities
if [ "$1" = "view_azureidentities" ]; then
    cat azureidentities.csv | sed 's/,/ ,/g' | column -t -s, | less -S
fi


# check for azure.workload.identity/use
if [ $# -eq 0 ]; then
    # setup files
    > migrated.csv
    > not_migrated.csv
    > azureidentities.csv
    echo "namespace, deployment" >> has_label.csv
    echo "namespace, deployment" >> no_label.csv
    echo "namespace, identity, binding, resource" >> azureidentities.csv

    # get cluster name
    cluster_name=$(kubectl config current-context)

    # print info before execution
    echo cluster context: $cluster_name
    sleep 3
    echo progressing...

    # get namespaces in the cluster
    namespaces=($(kubectl get namespaces -o json | jq -r '.items[].metadata.name'))

    # get deployments in iterated namespace
    for namespace in "${namespaces[@]}"; do
        deployments=($(kubectl get deployments -n $namespace -o json | jq -r '.items[].metadata.name'))

        # check for label 'azure.workload.identity/use' - returns null if not defined. Should be true
        for deployment in "${deployments[@]}"; do
            label_check=$(kubectl get deployment $deployment -n $namespace -o json | jq -r '.metadata.labels."azure.workload.identity/use"')

            #logic on label_check contents
            if [ $label_check = "null" ];
            then
                echo $deployment: needs migrating.
                echo $namespace, $deployment >> no_label.csv

            else
                echo $deployment: is migrated.
                echo $namespace, $deployment >> has_label.csv
            fi
        done

        # get identities in namespace
        identity_bindings=($(kubectl get azureidentitybinding -n $namespace -o json | jq -r '.items[].metadata.name' ))

            for binding in "${identity_bindings[@]}"; do
                # get json block of the identity
                binding_block=$(kubectl get azureidentitybinding $binding -n $namespace -o json | jq .)

                # get binding name, bound identity and resource associated with the bound identity
                binding_name=$(kubectl get azureidentitybinding $binding -n $namespace -o json | jq -r '.metadata.name')
                bound_identity_name=$(echo $binding_block | jq -r '.spec.azureIdentity')
                bound_resource_name=$(kubectl get azureidentity $bound_identity_name -n $namespace -o json | jq -r '.spec.resourceID' | awk -F / '{print $NF}')

                echo $namespace, $bound_identity_name, $binding_name, $bound_resource_name >> azureidentities.csv
            done
    done

    echo
    echo script has finished executing
    echo \'workload_identity_checker.sh view_migrated\' to view the migrated deployments
    echo \'workload_identity_checker.sh view_not_migrated\' to view not migrated deployments
    echo \'workload_identity_checker.sh view_azureidentities\' to view remaining old azure identities and bindings
fi