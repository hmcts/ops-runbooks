# Accessing Databases from Prod Bastion

Steps to take when there is the need to access production databases to run queries that retrieve, update or delete data from tables.
Other teams sometimes need certain pieces of information from the production DB and would raise
a ticket, providing their sql query and requesting PlatOps run these against
production Db as they don't have access to this.

*Note:* there's a [self service](https://tools.hmcts.net/confluence/display/DTSPO/%5BSelf-Service%5D+Database) process that should be used by the team if they have an SC person on their team instead.

To fulfill one of these request, you can follow the steps below.

## Prerequisites 💥
* **Important:** Verify you are all setup as outlined in [cnp-module-postgres](https://github.com/hmcts/cnp-module-postgres#production)
* Grant yourself access to production Bastion as outlined in [cnp-module-postgres](https://github.com/hmcts/cnp-module-postgres#production), in the `Steps to access` section of the document <br>
  **Note:** If not on call then just one day is sufficient, you could also customize how long you want access for.

## Suggested Steps

* Confirm the database connection host. This should be in the ticket, but you can also confirm by searching it in the portal on [Azure](https://portal.azure.com/#home) <br>
* Sanity check the query provided in the ticket, not that you are expected to know any sql 🤥 <br>
  Sometimes typos or misplaced variables are easy to spot
* Jump onto the production bastion, steps on how to do this are in the [cnp-module-postgres](https://github.com/hmcts/cnp-module-postgres#production)  documentation <br>
  _Example:_<br>
  ![Connecting to DB](images/connecting.png)

## Guides
- [Connecting to a Database](executing-queries.md)
- [Deleting cases from CCD Datastore Database](deleting-cases-from-ccd-datastore.md)
- [Restoring a Database](restoring-an-azure-single-server-database.md)