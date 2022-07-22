# Deleting a case from CCD Datastore Database

This is a 2-stage process that requires you delete the case from the database first and then ssh to the Elastic Search VM to delete the same. Please ensure you have a valid ServiceNow Change Request to do so.

## 1. Identify case in CCD Data Store Database [ccd-data-store-api-postgres-db-v11-prod.postgres.database.azure.com] and delete

DB_HOST=ccd-data-store-api-postgres-db-v11-prod.postgres.database.azure.com
DB_USER="DTS\ Platform\ Operations\ SC@ccd-data-store-api-postgres-db-v11-prod"
DB_NAME=ccd_data_store

a) Hop on to the bastion and run the script below. The script calls an external .txt file which contains a list of valid CCD Data Store 16-digit unique reference numbers that need deleting. Each case needs deleting from a number of tables in DataStore. The first two tables may be empty, but the bottom two will most certainly contain data.

```bash
#!/bin/bash

## BULK Deletes in CCD Data Store DB

#vARS
DB_HOST=ccd-data-store-api-postgres-db-v11-prod.postgres.database.azure.com
DB_USER="DTS\ Platform\ Operations\ SC@ccd-data-store-api-postgres-db-v11-prod"
DB_NAME=ccd_data_store
PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)


        #referenceid=1594642772192927;
        for referenceid in `cat list_of_CaseReference.txt`;

            do

                QUERY=$(cat <<EOF

                        BEGIN;
                            DELETE FROM case_users_audit WHERE case_data_id = (SELECT id FROM case_data WHERE reference = ($referenceid));
                            DELETE FROM case_users WHERE case_data_id = (SELECT id FROM case_data WHERE reference = ($referenceid));
                            DELETE FROM case_event_significant_items WHERE case_event_id IN (SELECT id FROM case_event WHERE case_data_id IN (SELECT id FROM case_data WHERE reference = ($referenceid)));
                            DELETE FROM case_event WHERE case_data_id = (SELECT id FROM case_data WHERE reference = ($referenceid));
                            DELETE FROM case_data WHERE reference = ($referenceid);
                        COMMIT;

                EOF
                  )

# Run above query
psql "sslmode=require host=${DB_HOST} dbname=${DB_NAME} user=${DB_USER} port=5432 password=${PGPASSWORD}" -c "${QUERY}"

          done
```


## 2. On the Elastic Search VM, execute the script below using the `16-digit reference` to identify the Case 


```bash 
#!/bin/bash

QUERY=$(jq -n \
--arg my_val "$1" \
'
{
  query:{
    bool:{
      filter:{
        term:{
          "reference.keyword":$my_val
        }
      }
    }
  }
}
')

RESULT=$(curl -s -X GET 'localhost:9200/_search?pretty' -H 'Content-Type: application/json' -d "${QUERY}")

CASE_ID=$(echo "$RESULT" | jq -r '.hits.hits[0]._id')
INDEX_ID=$(echo "$RESULT" | jq -r '.hits.hits[0]._source.index_id')

echo "Case ID: $CASE_ID, Index ID: $INDEX_ID"

if [ "$INDEX_ID" != "null" ]; then
  CASE=$(curl -s -X GET "localhost:9200/$INDEX_ID/_doc/$CASE_ID" | jq .)
  curl -s -X DELETE "localhost:9200/$INDEX_ID/_doc/$CASE_ID" | jq .

else
  date
  echo "No valid index was found."
fi
```
e.g. 

```cmd
  ./find_case_id_by_reference.sh `<16-digit reference>`
```

and follow the screen prompt