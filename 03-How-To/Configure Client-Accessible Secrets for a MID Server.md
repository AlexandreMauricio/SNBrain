---
type: how-to
tags: [how-to, security, integrations, discovery, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Secrets Management > Configuring client accessible secrets (chapter read in full 2026-10-08) - Create encryption keys and certificate, Add your certificate to the ServiceNow Trusted Key Store, Create a secret group with criteria, Upload the public/private keypair to the MID Server, Create credentials and test credential encryption, Configure Flow Designer to manage the integration, Test the end-to-end integration, Test a WMI credential. https://www.servicenow.com/docs/r/platform-security/client-access-secret-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Configure Client-Accessible Secrets for a MID Server

**Goal:** store a credential on the instance so that only one MID Server, holding your private key, can decrypt it.
**Prerequisites:** Secrets Management Enterprise (being retired: see the concept note); a working MID Server; roles `admin`, `sn_kmf.admin`, `sn_kmf.cryptographic_manager`, `sn_secrets.admin` / `sn_secrets.secret_manager` (the MID Server's logged-in user needs the same key and secrets roles); OpenSSL or an equivalent tool; administrator rights on the MID Server host.
**Navigation:** All > Secrets Management > Secret Groups with Criteria

Background: [[Secrets Management - Secret Groups and Client-Side Secrets]].

## Steps

1. **Key pair** (on your own machine): generate a 4096-bit RSA private key and a certificate, then one bundle file holding both:

```bash
openssl req -newkey rsa:4096 -nodes -keyout sm_private_key.pem -x509 -days 365 -out sm_public_cert.pem
```

```bash
cat sm_private_key.pem sm_public_cert.pem > sm_keypair_bundle.pem
```

2. **Trust the certificate** (only for a self-signed one): `sys_certificate.list` > **New**: **Format** PEM, **Type** *Trusted Store Cert*, paste the certificate text (from `-----BEGIN CERTIFICATE-----` to `-----END CERTIFICATE-----`) into **PEM Certificate**.
3. **Secret group**: **Secret Groups with Criteria > New**: **Group name**, **Secret type** *Client accessible*, **Autogen module** ticked, **Criterion type** *Target table*, **Target table** for example SSH Credentials (`ssh_credentials`). Save; leave **Active** unticked for now.
4. **Identity group**: on the group, **Manage client side access** > **New** > give the identity group alias a name > **Upload identity key**: enter an **Identity key alias** (remember it exactly) and import `sm_public_cert.pem` > submit. Tick the identity group in the list > **Associate secret group**.
5. **Members**: open the identity group from the related list *Secret Group - Identity Group* > **Identity group members > New**: **Member table** MID Server (`ecc_agent`), choose the MID Server.
6. Reopen the secret group, tick **Active**, update.
7. **Private key to the MID Server**: on the MID Server host, in an administrator shell, run the script from the MID Server's `bin\scripts` folder with the same alias and the bundle file:

```bash
manage-certificates.bat -a <identity_key_alias> <path>\sm_keypair_bundle.pem
```

   Expect "Installed certificate with alias: ... into the MID keystore." Then **Restart MID** and wait for *Up* and *Validated*.
8. **Credential**: create the credential in the target table (for example SSH), **Applies to** *Specific MID Servers*, your MID Server, and give it a **Credential alias** of type *Credential*.
9. **Use it**: in Workflow Studio build an action: *Look Up Record* on `ecc_agent` (your MID Server), then an *SSH* step (or *PowerShell* for Windows) with *Define Connection Inline*, the credential alias, the host, and **MID Selection** *Specific MID Server* = the record from the first step. **Test**.

## Result / how to check it worked

- **Show XML** on the credential: the password value is cipher text with a key sys_id in front; that sys_id is found in `sys_kmf_module_key`, and `sys_kmf_wrapped_module_key` (filter on the group's crypto module) shows the symmetric key wrapped by your public key.
- The test action returns step status code 0 "Success" and the command has run on the target.
- The same credential used through a MID Server that is not in the identity group fails.

## Example

Secret group `example_ssh_client_secrets` (client accessible, target table `ssh_credentials`). Identity group alias *Example MID identity*, identity key alias `example_mid_key`, member MID Server *Example MID 01*. Credential *Example Linux login* (an invented service account) with credential alias `example_ssh_alias`. A test action runs `/bin/date > example_check.txt` on host `10.0.0.10` through *Example MID 01*; the file appears with the current time, proving the MID Server decrypted the secret locally.

## Tables / fields involved

- `sn_sm_secret_group` (groups), `sn_sm_identity_group` (identity groups), `sn_sm_secret` (wrapped secrets)
- `sys_kmf_module_key`, `sys_kmf_wrapped_module_key`: keys
- `sys_certificate`: the trusted certificate
- `ssh_credentials` (or another credential table), `sys_alias`, `ecc_agent`

## Gotchas

- The identity key alias on the instance and the `-a` value on the MID Server must match exactly.
- The private key file is a secret: keep it out of the instance, tickets and notes; delete working copies after installing it in the MID keystore.
- The group is inactive when created; nothing is encrypted with it until it is active.
- Existing credentials are not re-encrypted automatically: run a Secrets Management security job (*Secret Group Enforcement*).
- The certificate in the example is valid 365 days: plan its renewal.
- After a clone, client-side groups copied from the source must be reconfigured by hand.
- If the SSH step is missing in Workflow Studio, the Integration Hub plugin providing it is not active.
