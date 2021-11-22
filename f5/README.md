# F5 VPN

## Useful links

- [GitHub Repository](https://github.com/hmcts/azure-vpn-f5) (not live yet, automation is in progress)
- [User Accounts](accounts.md)

## Guides

- [Setup access to internal apps](VPN-routing-config.md)


## Common Issues

- Failed HDD encryption check: Likely means that FileVault is turned off if it's Mac, or some other whitelisted Full Disk encryption needs to be installed and used on a Windows/Ubuntu machine.
- User is not assigned to a role for the application: https://hmcts.github.io/onboarding/person/#person
- Failed to open tunnel, Tunnel server already launched: To make this works for general cases, use the following: Find the svpn process id: ps alx | grep svpn On the result process ID use the kill command: kill -9 [the process id from the ps command], and or restart the machine.

If the issue persists or has no available solution, you may need to initiate a support request with F5. To do this you'll need the F5 serial number / Registration key.  (can we add it here?)
