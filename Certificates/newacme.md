# How to add the ACME Function App to a new subscription

1. Add the subscrption to these two blocks in the ops-bootstrap repo:
https://github.com/hmcts/ops-bootstrap/blob/master/pipeline-scripts/sub-bootstrap.ps1#L184-L204
https://github.com/hmcts/ops-bootstrap/blob/master/pipeline-scripts/sub-bootstrap.ps1#L207-L255 

2. Add a new product entry (if not present already) in the common tags file:
https://github.com/hmcts/terraform-module-common-tags/blob/master/team-config.yml

3. Then run the [ops-bootstrap pipeline](https://dev.azure.com/hmcts/Operations/_build?definitionId=435) in the right supscription.
