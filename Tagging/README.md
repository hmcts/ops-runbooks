# Tagging resources manually

This script was created for DTSPO-7971 to tag un-tagged resources on a per resource group level in a more automated way, following the tagging requirements [here](https://tools.hmcts.net/confluence/display/DCO/Tagging+v0.4). It tags all resources within the resource group and the resource group itself, whilst retaining all existing tags.

## Pre-requisites

Please ensure that you have jq installed in order for tagger.sh to be run. This can be installed by running the command `brew install jq`

## Description

To run the script, clone this repository and switch into the `Tagging` directory, then run `./tagger.sh`. You may need to give executable permissions first with `chmod +x tagger.sh` and make sure you've ran `az login` too. The script should guide you through what you need to accomplish the tagging, and validates that the tagging values you've entered fit HMCTS requirements. 