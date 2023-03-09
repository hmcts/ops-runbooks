#!/bin/bash
DOT_REMOVER(){
    echo $(echo $1 | tr -d ".")
}

CHECK_CHART(){
    VERSION=$(echo $1 | tr -d "phelm.sh/chart=:$3.- ")
    # Check version is at least the recommended one
    [[ "$(( $VERSION - $2 ))" -ge 0 ]]
}

MINIMUM_JAVA="4.0.1"
MINIMUM_NODE="2.4.5"
MINIMUM_BASE="0.2.2"
MINIMUM_NODE=$(DOT_REMOVER ${MINIMUM_NODE})
MINIMUM_JAVA=$(DOT_REMOVER ${MINIMUM_JAVA})
MINIMUM_BASE=$(DOT_REMOVER ${MINIMUM_BASE})

RELEASES=$(helm list -a -A -o json | jq -c '.[]')
TO_CHECK=()
IFS=$'\n' read -rd '' -a RELEASE_LIST <<<"$RELEASES"
for RELEASE in "${RELEASE_LIST[@]}"
do
    NAME=$(echo ${RELEASE} | jq .name | tr -d '"')
    NAMESPACE=$(echo ${RELEASE} | jq .namespace | tr -d '"')
    echo -e "Looking at ${NAME} release in ${NAMESPACE}.."
    # Filter out errors and get release value
    CHART_LINE=$(helm get all ${NAME} -n ${NAMESPACE} 2> /dev/null | grep helm.sh/chart | head -1)
    # Remove helm.sh/chart: from test input
    CHART_VERSION=$(echo ${CHART_LINE} | sed -r 's/.{15}//')
    if [[ "${CHART_VERSION}" == *"java"* ]]; then
        if ! CHECK_CHART $CHART_VERSION $MINIMUM_JAVA "java"; then
            TO_CHECK+="${NAME} -- Current version: ${CHART_VERSION}\n"
        fi
    fi
    if [[ "${CHART_VERSION}" == *"node"* ]]; then
        if ! CHECK_CHART $CHART_VERSION $MINIMUM_NODE "nodejs"; then
            TO_CHECK+="${NAME} -- Current version: ${CHART_VERSION}\n"
        fi
    fi
    if [[ "${CHART_VERSION}" == *"base"* ]]; then
        if ! CHECK_CHART $CHART_VERSION $MINIMUM_BASE "base"; then
            TO_CHECK+="${NAME} -- Current version: ${CHART_VERSION}\n"
        fi
    fi
done

echo -e "\n\nCompleted checks. Please look into the following releases:"
for RELEASE in "${TO_CHECK[@]}"
do
    echo -e "$RELEASE\n"
done