# Generating an SAS Token

This wiki page documents the procedure for generating a new SAS token

## To grant yourself permissions:

Go to the [PIM settings](https://portal.azure.com/#blade/Microsoft_Azure_PIMCommon/CommonMenuBlade/quickStart). 

Click on **My roles** under tasks in the left hand side. Select Group Administrator and select **activate**. Then submit your request for elevator permissions. 

Once this has been activated, add yourself to a group with the **owner** permission over the subscription the storage account you need to generate the token for sits in.

## Generating the token

Navigate to the storage account and open 'Shared Access signature'. Select the level of permission required, be sure to select your allowed resource types, set the expiry date, and include the allowed ip address. From here, securely pass the details to the requester and confirm token is working.