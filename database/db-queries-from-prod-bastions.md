# DB Queries from Prod Bastion

This document itemises steps to take when there is the need to access production database.
Other teams sometimes need certain pieces of information from the production Db and would raise
a ticket, providing their sql query and requesting PlatOps run these against
production Db as they don't have access to this.

To fulfill one of these request, you can follow steps below.

## Prerequisites 💥
* **Important:** Verify you are all setup, [click here for detail steps](https://github.com/hmcts/cnp-module-postgres#production)
* Turn on your VPN
* Grant yourself access to production Bastion, [click here details](https://tools.hmcts.net/confluence/pages/viewpage.action?pageId=1411089455#Bastion-RequestaccesstothebastionhostviaJIT) <br>
  Note if not on call then just one day is sufficient
* Keep your HMCTS user account detail handy

## Suggested Steps

* Confirm the database connection host by looking at the Key vaults on [Azure](https://portal.azure.com/#home) <br> 
  You can tell by looking at the Jira ticket and the host you have been asked to run the query against
* From same place ([key vaults](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.KeyVault%2Fvaults)), keep the db host password handy as you'd need it to connect
* Sanity check the query provided in the ticket, not that you are expected to know any sql 🤥 <br>
Sometimes typos or misplaced variables are easy to spot
* Jump onto the production bastion with following command 
  ```cmd
  ssh user.name@hmcts.net@bastion-devops-prod.platform.hmcts.net
  ```
* Provide browser authentication code. Microsoft would prompt you for this  

## Executing Queries
Once on the bastion server you can execute queries against the db in any number of ways, below are some suggestions

### Small queries

* Connect to  Postgres by typing the following command. Verify you have followed steps outlined [here](https://github.com/hmcts/cnp-module-postgres#production) <br> 
  Note the **Bastion configuration** section, it's important.
  ```cmd 
  psql -U ccd@ccd-data-store-api-postgres-db-prod -h ccd-data-store-api-postgres-db-prod.postgres.database.azure.com
  ```
  I'm using the ccd data store database as an example here
* Once in, you can execute provided query
  ```cmd
   psql> paste your query here;
  ```
* Copy the output result and send it to the authorised recipient, this is usually mentioned in the ticket. If not mentioned, then confirm with team members before sending data off  

### Larger, lengthier queries

* Connect to Postgres as described in above step
* Create a new file, for example
  ```cmd
  vi <ticket-number>-<any-extras-labeling>.sql
  ```
  You could use `nano` as well. Just replace `vi` with `nano`
* Copy/paste query and save it
  ```cmd 
  :wq!
  ```
  If using `nano` then use its equivalent
* Once file is saved you could run the command passing the file as input to Postgres. See an example below using ccd datastore db
  ```cmd 
  psql -U ccd@ccd-data-store-api-postgres-db-prod -h ccd-data-store-api-postgres-db-prod.postgres.database.azure.com -d ccd_data_store -o DTSPO-2766-result.csv < DTSPO-2766-get-case-data.sql
  ```
* If no errors, you can `cat` the output file for a quick eye-balling 👀
  ```cmd 
  cat <output-file>.csv
  ```

### Bringing query file home
You can use any `sftp` tool of your choice to connect to bastion or follow below steps

* Log out of your ssh terminal by exiting
* Copy the file from the bastion server right from your terminal
  ```cmd 
  scp user.name@hmcts.net@bastion-devops-prod.platform.hmcts.net:/home/user.name/DTSPO-2766-result.csv /Users/<location-of-choice>
  ```
  `/Users/<location-of-choice>` being a path on your file system, here is an example using a MAC
* You can now send the file(s) to authorised recipient(s) or share as instructed in the ticket.<br> 
  If unclear, confirm with team members.
  
If you run into any other issues please feel free to reach out to team members.
