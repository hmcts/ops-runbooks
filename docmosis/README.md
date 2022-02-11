# Docmosis

## Updating Docmosis Variables

- Clone [this](https://github.com/hmcts/cnp-flux-config) repository locally and checkout to a new branch before making any changes.
- Run the command 

```mkdir tmp; kubectl create secret generic docmosis-secret --from-literal DOCMOSIS_KEY={License Key} --from-literal DOCMOSIS_ADMINPW={Admin Password} --from-literal DOCMOSIS_ACCESSKEY={Access Key} --from-literal DOCMOSIS_SITE="Licensed To: Ministry Of Justice.  For use with single project: Reform Document Generation" --namespace docmosis --dry-run=client -o json > tmp/{env}-docmosis.json`. Make sure to fill in all the {} placeholders accordingly. You can obtain {License Key}, {Admin Password}, and {Access Key} by connecting to the K8S cluster in the environment you're making the change in and running this command `kubectl get secret docmosis-secret -o yaml -n docmosis```

<img width="1111" alt="image" src="https://user-images.githubusercontent.com/47995122/153570220-84880e5e-419d-4244-9bdb-28023efb5bc7.png">

- These values in the `data:` block are in base64, so run `echo "value" | base64 --decode` to decode, these are to be used as the placeholders.
- Once the above step is done, if the environment is using FluxV1 run `kubeseal --format=yaml --cert=k8s/{env}/pub-cert.pem < tmp/{env}-docmosis.json > k8s/{env}/common/sealed-secrets/docmosis-secret.yaml`. For environments that have fully migrated to FluxV2, run `kubeseal --format=yaml --cert=clusters/{env}/pub-cert.pem < {env}/sandbox-docmosis.json > apps/docmosis/{env}/base/docmosis-secret.yaml`.
- You can delete the tmp directory. Now commit your changes to Github, ensuring you don't include the `tmp/{env}-docmosis.json` file, and raise a PR. Once this PR is approved flux will handle replacing the secrets in the cluster.
- Kill the docmosis pods in the cluster for the environment you're altering a variable in for your changes to take effect. Docmosis pods live in the docmosis namespace.

## Verifying your changes
- [Docmosis GUI Password](https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_KeyVault/Secret/https://docmosisdevkv.vault.azure.net/secrets/docmosis-admin-key) 
- [Docmosis GUI (AAT)](https://docmosis.aat.platform.hmcts.net/tornado.html) - Connect to the VPN and then log in with the password found in the above point. You can then navigate to the Configuration tab and view the changes here.
