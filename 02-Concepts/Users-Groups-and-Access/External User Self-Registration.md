---
type: concept
tags: [concept, users, roles, portal, security, flows, import-sets, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Self-register to ServiceNow instance (whole section, 10 topics, 365 cleaned lines, read in full 2026-10-08 through the docs site) - explore, activate, external roles, user registration configuration, Google reCAPTCHA, default and custom registration form fields, enable for Service Portal, verify requests. https://www.servicenow.com/docs/r/platform-security/authentication/external-user-self-registration.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# External User Self-Registration

**In one line:** lets people outside the organisation create their own account from a Service Portal login page: a registration form, an emailed activation link, then a user record with `snc_external` (or a role containing it) and a password-setup email.

From the Brazil docs. The external role and what it can reach: [[Explicit Roles and Elevated Privilege Roles]]. Creating users by hand: [[Create a User]].

- Plugin **External User Self-Registration** (`com.snc.external_user_self_registration`); role `external_user_self_registration_admin`.
- Typical use: a custom application for a large outside population (the docs' example: students registering for campus parking).

## Registration configuration

**External User Self-Registration > User Registration Configurations > New**:

| Field | Meaning |
|---|---|
| **Name**, **Active**, **Description** (after first save) | |
| **Roles assigned to provisioned users** | each must be `snc_external` or contain it |
| **Enable terms and conditions**, **Terms and conditions URL** | a public URL shown on the form |
| **Enable CAPTCHA** | Google reCAPTCHA by default |

After submitting, the tabs:

| Tab | Content |
|---|---|
| **Registration** | the form fields: **Display in Registration Form**, **Order**, **Mandatory**, **Validation only field** (checked but not saved to the user, for example a registration code). Default fields (names, email, phones, address, country, language, title, prefix, gender, EDU status) cannot be deleted; custom ones are added as rows (types: single line text, wide text, email, date, date/time, yes/no, multiple choice, select box; default order 10,000) |
| **Verification** | **Requires user verification** runs the subflow in **User verification flow** (default *External User Verification*): an activation link by email, valid **Activation link expiry time (in hours)** (default 24) |
| **Transformation** | two transform maps (`u_reg_xmap_...`) carry the request into the activation table and then the user table; copy and adapt them rather than editing |
| **Onboarding** | subflow run for activated users (default *External User Onboarding*: emails a password reset link) |
| **Advanced** | **Registration table**, **Activation table**, **User table**, the record producer behind the form, success, error and post-registration redirect pages, **Registration link label** (default *Register*) |

**Preview Registration Form** shows the result. Copy the default subflows in Workflow Studio to change them ([[Flows, Subflows and Actions Overview and Architecture]]).

## Switching it on

1. **Service Portal > Portals** > the portal > **External user registration configuration** = the configuration. The login widget then shows the registration link.
2. reCAPTCHA (keys requested from Google): properties `glide.user.registration.google.recaptcha.site_key`, `glide.user.registration.google.recaptcha.secret` (type password2), `glide.user.registration.captcha.widget` (sys_id of the captcha widget).
3. **External User Self-Registration > Registration Requests** lists requests and their status (Pending, Processed).

Since Paris a property must be enabled so that external users are not also given internal roles (the docs refer to "Prevent future internal role assignments for external users"; property name not given here (?)).

## Related

- [[Explicit Roles and Elevated Privilege Roles]] · [[Access Control Lists (ACLs)]] · [[Create a User]] · [[Local Authentication - Login, Password Policy and Password Reset]]
