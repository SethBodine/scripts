#!/bin/bash

set -e

if [[ -z "${4}" ]] ; then
    printf 'resource group: ' && read RESOURCE_GROUP
    printf 'nic name: ' && read NSGNAME
    printf 'log analytics resource group: ' && read LAW_RG
    printf 'log analytics workspace: ' && read LAW_NAME
else
    RESOURCE_GROUP="${1}"
    NSGNAME="${2}"
    LAW_RG="${3}"
    LAW_NAME="${4}"
fi

VNET_ID=`az network nsg show \
--name ${NSGNAME} \
--resource-group ${RESOURCE_GROUP} \
--query id --output tsv`

LOGANALYTICS_ID=`az monitor log-analytics workspace show \
--resource-group ${LAW_RG} \
--workspace-name ${LAW_NAME} \
--query id --output tsv`

az monitor diagnostic-settings create \
--resource ${VNET_ID} --name "loganalytics" \
--workspace ${LOGANALYTICS_ID} --logs \
'[
  {
    "category": "NetworkSecurityGroupEvent",
    "enabled": true,
    "retentionPolicy": {
      "days": 0,
      "enabled": false
    }
  },
  {
    "category": "NetworkSecurityGroupRuleCounter",
    "enabled": true,
    "retentionPolicy": {
      "days": 0,
      "enabled": false
    }
  }
]' | jq
