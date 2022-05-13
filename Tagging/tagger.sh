#!/bin/bash

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

echo -e "${YELLOW}   --------------------------------------------------------------------"
echo -e " /                                                                      \\"
echo -e "||                   Manual Resource Tagging Script                     ||"
echo -e "||                                                                      ||"
echo -e "||       Used to tag un-tagged resources at a resource-group level      ||"
echo -e "||                                                                      ||"
echo -e " ------------------------------------------------------------------------${PLAIN}"

# Check jq installation
if ! command -v jq &> /dev/null
then
    echo "jq not installed"
    exit
fi
# Allowed tagging values to be used in tagging key-pairs
ALLOWED_APPLICATION_VALUES=("probate" "template-management" "c100" "cloud-video-platform" "bulk-print" "bais" "divorce"
                    "financial-remedy" "bulk-scan" "employment-case-management" "find-a-court-or-tribunal" "caps"
                    "mcol" "pcol" "application-performance-management" "evidence-documentation-management" "caseman" 
                    "heritage-secure-data-transfer" "family-public-law" "cft-idam" "access-management" "core" "juror-digital" 
                    "security" "pre-recorded-evidence" "help-with-fees" "residential-property-tribunals" "tax-tribunals" "darts-idam" 
                    "strategic-data-platform" "ce-file" "protected-characteristics-questionnaire" "fees-and-payments" "hearings-recording-storage" 
                    "retention-and-disposal" "log-and-audit" "no-fault-divorce" "publishing-information-service" "video-hearings-service" 
                    "core-case-data" "hearings-management-component" "hearings-management-interface" "special-tribunals" "expert-ui" 
                    "task-management" "common-platform" "social-service-child-support" "reference-data" "resource-management" "immigration" 
                    "schedule-and-listing" "adoption" "employment-tribunals" "high-value-bulk-claims" "family-private-law" "civil-money-claims" 
                    "damages" "civil-enforcement" "civil-housing-possession" "family-integration-systems" "	courts-tribunals-service-centre" 
                    "applications-register" "glimr" "ifas" "crime-portal" "martha" "crest-legacy-functions" "am-dashboard" "libra-gob" "heritage-small-systems") 
ALLOWED_ENV_VALUES=("sandbox" "development" "testing" "demo" "ithc" "staging" "production" "development" "system-integration-testing" 
                    "non-functional-testing" "pre-production" "production" "non-live-management" "live-management")
ALLOWED_BUSSINESS_AREAS=("CFT" "crime" "cross-cutting")


# Function to check if a given value exists in an array
Allowance_Checker () {
    # Check application contains an allowed value
    ref=$1[@]
    # Expand passed array
    arr=("${!ref}")
    # If any array value matches the given value
    if [[ " ${arr[*]} " =~ " $2 " ]]; then
        local result=1
        echo $result
    else
        local result=0
        echo $result
    fi
}

Found_NotFound () {
    if [[ ${result} == 1 ]]; then
        echo -e "${GREEN}Tag value in accepted range.${PLAIN}"
    else
        echo -e "${RED}Tag value was not found, please refer to the tagging dictionary, if you can't find your team here please contact #platops-help. https://tools.hmcts.net/confluence/pages/viewpage.action?pageId=1007945237#Taggingv0.4-TaggingDictionary."
        exit 1
    fi
}


# Collect target resource group and subscription
read -p "Input Resource Group you wish to tag: " SELECTED_RG
read -p "Enter the Subscription this Resource Group exists in: " RG_SUBSCRIPTION

# Check Subscription exists
az account show --subscription ${RG_SUBSCRIPTION} &> /dev/null
if [[ $? -eq 0 ]]; then
   echo -e "${GREEN}Subscription found! Continuing...${PLAIN}"
   az account set --subscription ${RG_SUBSCRIPTION}
else
   echo -e "${RED}Failed to find subscription."
   exit 1
fi

# Check RG exists
RG_EXISTS=$(az group exists -n ${SELECTED_RG})
if [[ ${RG_EXISTS} == "false" ]]; then
    echo "${RED} RG not found."
    exit 1
else
    echo -e "${GREEN}RG in Subscription found! Continuing...${PLAIN}"
fi

echo -e "\n${YELLOW}For full tagging documentation, naming standards, and to understand the following questions in depth, please visit: \nhttps://tools.hmcts.net/confluence/display/DCO/Tagging+v0.4.\n ${PLAIN}"
# Collect tagging details
read -p "Application name: " APPLICATION
result=$(Allowance_Checker ALLOWED_APPLICATION_VALUES ${APPLICATION})
Found_NotFound ${result}
read -p "Input the environment this Resource Group exists in: " ENV
result=$(Allowance_Checker ALLOWED_ENV_VALUES ${ENV})
Found_NotFound ${result}
read -p "Input business Area: " BUSINESS_AREA
result=$(Allowance_Checker ALLOWED_BUSSINESS_AREAS ${BUSINESS_AREA})
Found_NotFound ${result}
# No restrictions for this tag just needs including
read -p "Input builtfrom tag: (Git repository these resources are built from)" BUILT_FROM
# Check tag is not empty
if [ -z "${BUILT_FROM}" ]
then
    echo -e "${RED}Please enter a value for this tag."
    exit 1
fi
echo -e "${GREEN}Tags all accepted, proceeding to tag resources.${PLAIN}"

# Fetch all resources in given Resource Group 
RESOURCES=$(az resource list -g ${SELECTED_RG} | jq -c -r '.[]' | jq -r '.id')

# Split resource IDs by spaces into array 
RESOURCE_LIST=(`echo $RESOURCES | tr ' ' ' '`)
# Tag all Resources in the Resource Group adhering to Phase 01 tagging, uses `--operation merge` to keep any existing tags and apply new ones
echo -e  "Iterating through resources and applying tags..."
for resource in "${RESOURCE_LIST[@]}"
do
    az tag update --resource-id ${resource} --operation merge --tags application=${APPLICATION} environment=${ENV} businessArea=${BUSINESS_AREA} builtfrom=${BUILT_FROM} --subscription ${RG_SUBSCRIPTION}
done

# Tag Resource Group
RESOURCE_GROUP_ID=$(az group show -n ${SELECTED_RG} | jq -r '.id')
az tag update --resource-id ${RESOURCE_GROUP_ID} --operation merge --tags application=${APPLICATION} environment=${ENV} businessArea=${BUSINESS_AREA} builtfrom=${BUILT_FROM} --subscription ${RG_SUBSCRIPTION}
echo -e "\n${GREEN}Tagging complete!${PLAIN}"