# F5 VPN Config

This document details the steps to configure routing to make internal apps available over the vpn.

## Routing

1. Connect to the [VPN](https://portal.platform.hmcts.net)
2. Login to <https://vpn.platform.hmcts.net/>.\
If you are accessing the F5 portal for the first time, submit a pull request to the [user accounts](accounts.md) file in this repo and ask someone with existing access to create your account.
If you lose your login details, a person with existing access can provide you with new credentials.

3. For making the changes to the ACL: click 'Access → 'Access Control Lists' → 'acl_vpn_reform', [direct link](https://vpn.platform.hmcts.net/tmui/Control/jspmap/tmui/accessctrl/acls/properties.jsp?name=/Common/acl_vpn_reform)

4. You will see a list of ACLs for all the entries. Open two tabs in your browser on the same page, open an existing one and then click 'Add' for your new one. Copy the required details from the existing one to the new one.
Note: If using Firefox then the search function probably won't find the IP address you type in.

5. You will find 2 entries; HTTP and HTTPS. Change it to add new CIDR range, such as below:
<img src=images/properties.png  width="400">

## Access Policy

1. Navigate to Connectivity profiles to make a corresponding change to the routing.\
[Connectivity Profiles](https://vpn.platform.hmcts.net/tmui/tmui/util/ajax/app.jsp?appId=apps.AccessPolicy.perclientpolicy)

2. Add the new CIDR range under IPV4 and IPV6 . After verification, click on the `Apply Access policy` on the top left corner of the portal to propagate the routing changes.\
[VPN ACL](https://vpn.platform.hmcts.net/tmui/Control/jspmap/tmui/remconnectivity/nwaccessresources/l2_settings.jsp?name=/Common/netacl_mojvpn&type=1)

3. Logout of your current F5 VPN session (<https://portal.platform.hmcts.net>) and log back in to validate if the routing table update has taken place for the new network address space as shown below:

<p float="left">
<img src=images/VPN_Routing_table.png  width="400" />
<img src=images/Routing_Change.png  width="400" />
</p>

## Apply Access Policy

Once you have made a change to F5, you are required to Apply Access Policy.

1. When a change has been made, you need to Apply Access Policy before change is effective on F5. You will notice this in top left of the F5 Portal when you have made a change.

Select Apply Access Policy

<img src=images/apply_access_policy.png  width="400">

2. Review Access profile & ensure option prof_portal.platform.hmcts.net is ticked

Select Apply

<img src=images/apply_access_profile.png  width="400">

3. Access profile policies are then shown, it should already be ticked for all.

Select Apply

<img src=images/apply_access_profile_all.png  width="400">

4. Once successful apply, all access profiles should be green

<img src=images/apply_access_policy_review.png  width="400">