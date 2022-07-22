#!/bin/bash
MINIMUM_JAVA="4.0.1"
MINIMUM_NODE="2.4.5"
MINIMUM_BASE="0.2.2"
RELEASES=$(helm list -A -o json | jq -c '.[]')
TO_CHECK=()
IFS=$'\n' read -rd '' -a y <<<"$RELEASES"


for RELEASE in "${y[@]}"
do
    NAME=$(echo ${RELEASE} | jq .name | tr -d '"')
    NAMESPACE=$(echo ${RELEASE} | jq .namespace | tr -d '"')
    CHART_LINE=$(helm get all ${NAME} -n ${NAMESPACE} | grep helm.sh/chart: | head -1)
    # Remove helm.sh/chart: from test input
    CHART_VERSION=$(echo ${CHART_LINE} | sed -r 's/.{15}//')

    if [[ (${CHART_VERSION} == *"java"* || ${CHART_VERSION} == *"node"* || ${CHART_VERSION} == *"base"*) ]];
    then
        if [[ ${CHART_VERSION} == *"${MINIMUM_JAVA}"* || ${CHART_VERSION} == *"${MINIMUM_NODE}"* || ${CHART_VERSION} == *"${MINIMUM_BASE}"* ]];
        then
            echo -e "${NAME} release in ${NAMESPACE} namespace OK."
        else
            echo -e "${NAME} release in ${NAMESPACE} namespace doesn't have the latest chart!"
            TO_CHECK+="${NAME} -- Current version: ${CHART_VERSION}\n"
        fi
    fi
done

echo -e "\n\nCompleted checks. Please look into the following releases:"
for RELEASE in "${TO_CHECK[@]}"
do
    echo -e "$RELEASE\n"
done
