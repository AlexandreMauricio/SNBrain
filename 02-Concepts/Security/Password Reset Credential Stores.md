---
type: concept
tags: [concept, security, integrations, automation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Password Reset > Credential stores for Password Reset (Configure the connection to a credential store, Credential stores for AD, Integrate with Active Directory, Configure the connection to an AD credential store, Credential store for Microsoft Entra ID, Integrate with Entra ID, Configure the Entra ID credential store, Test the connection, Delete a connection), Configure the required strength for passwords, Customize password reset processes and integrate third-party credential services, Configure a credential store type to support third-party password auto-generation, Asynchronous password reset subflow, Create a credential store type, Password Reset Credential Store form, Set up Okta and Google Directory integrations, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/password-reset/c_CredentialStores.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Password Reset Credential Stores

**In one line:** a **credential store** (`pwd_cred_store`) is the connection Password Reset uses to reset, change, unlock or read the lock state of an account somewhere; it is built from a **credential store type** (`pwd_cred_store_type`), a set of subflows (or legacy workflows) that know how to talk to that kind of system.

From the Brazil docs; not tested. Part of [[Password Reset Application Overview]]. Roles: `password_reset_admin` or `password_reset_credential_manager` (create, change, delete); creating a type needs `password_reset_credential_manager`.

## Types

| Type | Comes with | Sample store |
|---|---|---|
| **Local ServiceNow Instance** | base system | *Local ServiceNow Instance* |
| **Microsoft AD Credential Store** | Microsoft AD for Password Reset store app | *Sample Microsoft AD Credential Store* |
| **Microsoft Entra ID Credential Store** | Microsoft Entra ID Integration for Password Reset | *Sample Microsoft (Entra ID) Credential Store* |
| Okta credential store | Password Reset integration with Okta | *Sample Okta Credential Store* |
| Google credential store | Password Reset integration with Google Directory | *Sample Google Directory Credential Store* |
| Remote ServiceNow instance (SOAP) | Orchestration plugin; legacy workflows only | |

**Password Reset > Credential Store Types** lists them; **Password Reset > Credential Stores** lists connections. One credential store per process (business rules *Single credential store per process*, *Update proc_to_cred_store*). A store in use by an active process cannot be deleted (*Prevent against deletion*): change the processes first, then **Actions > Delete**.

## The credential store form

| Field | Meaning |
|---|---|
| Type | the credential store type (template) |
| Auto-generate password | script include (category *Password generator*) that makes a temporary password; options include policy-compliant, crypto-secure or the default (`PwdDefaultAutoGenPassword`: a random word and 4 digits) |
| Enforce history policy | only for AD and Local types (hidden for Entra ID, which has no history support): add parameter `password_history_limit` in **Password Reset Credential Store Parameters** = number of past passwords refused (max 10; 0 allows any). With the local store, clear **Auto-generate password** on the process to use it |
| Child Alias | extra connection aliases under the type's base alias, so one store can reach several servers (e.g. several AD servers) |
| Enable password policy / Password policy | use a policy from [[Local Authentication - Login, Password Policy and Password Reset]] (option exists since Quebec) |
| Hostname | URL or IP of the store (Entra ID: the domain name of the Entra ID application) |
| User account lookup | script include mapping the ServiceNow user to the store account; default `PwdDefaultUserAccountLookup` returns the user name |
| Password rule hint | text shown to help the user (Windows app: newlines only, no formatting) |
| Password rule | client script that validates the new password on submit |
| Enable Password Strength / Strength rule | strength bar and the client script that computes it; on by default only for local stores; not in the Windows app |

Default example requirements: at least 8 characters, an upper and a lower case letter, a numeral. **Save and Test Connection** in the header tests a store (after creating one, or when users report problems).

The property `password_reset.history.limit` (default 10) caps the history value; business rule *Abort if password history limit exceeds* enforces it (ServiceNow store only). Lowering the limit queues event `pwd.credStore.history.limit.decrease`.

## Active Directory

Prerequisites: a **MID Server** on Windows that can reach AD ([[MID Server Overview and Architecture]]), and an AD account with rights on user objects: reset password, read/write `pwdLastSet`, `userAccountControl`, `lockoutTime`, write account restrictions, read `memberOf`, and on group objects read members. Credentials: with Orchestration, **Orchestration > Credentials** > New, Type *Windows*, user `<DOMAIN>\<SERVICE_ACCOUNT>`, applies to the MID Server; with Integration Hub, the **Microsoft AD Connection Alias** from the store ([[Connections, Credentials and Aliases]]). On the domain controller set password aging (`MIN_PASSWORD_AGE`) to 0 for the history policy. Parameter `max_reset_attempts` on the store limits failed attempts (0 = unlimited; AD stores only). The Windows application supports **only** AD stores.

## Third-party stores through Integration Hub

The base system has subflows only for the local instance; AD and Entra ID subflows come with their apps. For anything else, build actions in Workflow Studio ([[Custom Actions, Dynamic Inputs and Error Evaluation]]) and subflows with fixed names, inputs and outputs: *<Provider> Password Reset* (input Password Reset Request record and the new password; outputs Error Message, Status), *<Provider> Password Change* (`old_password`, `new_password`), *<Provider> Password Lock State* (output Locked), *<Provider> Password Unlock*, *<Provider> Password Connection Test*. Then a credential store type with **Use Flow** ticked and those subflows, then a store of that type.

Credential store type fields: Base Alias, Password change flow, Password reset flow, Unlock user flow (if set, Get user lock state flow becomes mandatory), Get user lock state flow, Connection test flow, **Supports history check**, **Password Delivery Mechanism**, **Supports Force Password Change On First Log In** (makes **User must reset password** appear on the process). Clearing **Use Flow** shows the deprecated workflow fields (Password Reset / Connection test / Get user lock state / Unlock user workflow), only present on upgraded instances.

## Asynchronous reset (no API, e.g. RPA)

For applications without a reset API, the reset subflow can hand the request to an external system such as a Robotic Process Automation robot: set **Password Delivery Mechanism** = *Reset flow doesn't accept password as input* (the user is not asked for a new password, and password policy and generation fields are hidden on the store). The request shows **Pending With External System**; the external side must call the subflow *Update Password Reset Request Status* (inputs: the request record and Request Status *Completed With Success* or *Completed With Failure*). The new password then reaches the user by email from the external system.

## Unconfirmed variants

- The Entra ID integration page says to create the connection "as described in Configure the connection to an AD credential store"; the Entra ID store page has its own procedure (role required: none). Kept both.
- Sample Entra ID store named *Sample Microsoft Credential Store* in one step and *Sample Microsoft Entra ID Credential Store* in the next.

## Example

An admin copies *Local ServiceNow Instance* as *Example Local Store*, ticks **Enforce history policy**, adds `password_history_limit` = 5, selects the password policy *Example Policy*, writes the hint "12+ characters, one number", then **Save and Test Connection**.

## Related

- [[Password Reset Reference - Properties, Tables and Components]] (workflows and tables) · [[Password Reset Extension Scripts]]
