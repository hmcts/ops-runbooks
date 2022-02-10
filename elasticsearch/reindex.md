# How to Re-Index Elasticsearch

If the definition of an Elasticsearch index changes, it will need to be re-indexed by PlatOps. This document explains how to perform a re-index on Elasticsearch.

1. Obtain bastion access to the desired environment.

Details on how to obtain bastion access can be found [in this guide](https://tools.hmcts.net/confluence/pages/viewpage.action?pageId=1411089455).

2. SSH into the Elasticsearch VM.

Connection strings for the virtual machine can be found in the 'Connect' tab in the Azure Portal. In the event that Elasticsearch is mirrored across multiple VMs as is the case in CCD, changes made to one Elasticsearch instance are mirrored across the other VMs automatically, so a connection only need to be made to one.

3. Verify the index you want to re-index is present.

Elasticsearch is normally exposed through port 9200 on the host machine. A list of indices can be obtained by curling `localhost` and then grepping for the index you want. For example:

```
curl -s localhost:9200/_cat/indices?v | grep grantofrepresentation_cases-000001
```

4. Delete the index.

This can again be done by curling the index, this time by sending a delete request:

```
curl -XDELETE localhost:9200/grantofrepresentation_cases-000001;
```

Do this for every index that needs re-indexing.

5. Re-upload the definition file.

This step is normally handled by the team responsible for the Elasticsearch index and many have their own process. Tell the ticket reporter to "Re-upload their definition file" and they should know what to do.

The re-index itself may take a few minutes. You can verify if the index has come back up by once again curling for the index. Alternatively, a watch can be set up for a particular index:

```
watch "curl -s localhost:9200/_cat/indices?v | grep grantofrepresentation_cases-000001"
```

If you see the index appear, this normally means the definition file has been uploaded successfully. Populating the index can take anywhere from a few minutes to a few hours depending on the amount of traffic passing through Elasticsearch. This is normal.

