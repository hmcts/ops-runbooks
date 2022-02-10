# How to Sync Elasticsearch

Occasionally, records in Elasticsearch may become out-of-sync with the records in the underlying database. When this happens, PlatOps will need to manually trigger a re-sync of the affected records.

1. Obtain bastion access to the desired environment.

Details on how to obtain bastion access can be found [in this guide](https://tools.hmcts.net/confluence/pages/viewpage.action?pageId=1411089455).

2. Connect to the corresponding database.

Consult the [database runbook](https://github.com/hmcts/ops-runbooks/tree/master/database) for a more detailed guide on this step.

3. Note the `last_modified` fields of the affected records.

Many postgres databases used by the project such as CCD data store maintain a field called `last modified` in several of their tables. This is a field managed by postgres itself and like the name would suggest, it stores a timestamp showing when the record was last updated. We are going to compare this timestamp to the timestamp of the same record in Elasticsearch to verify that this is indeed a sync issue between the database and Elasticsearch. If the timestamps match on the records, this may hint to the actual problem lying elsewhere.

To get the timestamp of the affected record, you'll need to query the database. Here's an example of such a query for a table in CCD:

```
select reference, created_date, last_modified, jurisdiction, case_type_id, marked_by_logstash from case_data where reference in (1234567890,9876543210);
```

Here we also fetch the `marked_by_logstash` field for the records. This field will be marked true if Elasticsearched has indexed this particular record. If the field is false for any of these, it would imply that Elasticsearch isn't able to index these records correctly. That should be investigated further as it may not be a sync issue at fault here.

4. SSH into the Elasticsearch VM.

Connection strings for the virtual machine can be found in the 'Connect' tab in the Azure Portal.

5. Check the `last_modified` values in the database against those in Elasticsearch

To check the `last_modified` values of the records stored in Elasticsearch, you'll need to curl for the record you're comparing. Elasticsearch is normally exposed through port 9200 on the host machine. Here is an example for the same CCD database as earlier:

```
curl -X GET "localhost:9200/_search?pretty" -H 'Content-Type: application/json' -d'
{
"query":{
   "bool":{
      "filter":{
         "term":{
            "reference.keyword":"1234567890"
         }
      }
   }
}
}' 
```

Once we've verified the timestemp values differ between the database and Elasticsearch, we can go on and manually trigger a sync of the affected records.

6. Trigger a re-sync for the affected records.

If the IDs of all affected records are known, we can simply trigger a sync by setting the `marked_by_logstash` value to `false` for those records:

```
UPDATE case_data SET marked_by_logstash = false WHERE reference IN (1234567890, 9876543210);
```

**Care must be taken when syncing a large set of records. Always make sure you know how many records a query will affect before you run it. Triggering a sync of a large number of records will be very slow and may lead to downtime if not accounted for prior. As a rule of thumb, never sync more than 1,000 records at once without notifying the team in charge or scheduling downtime**

