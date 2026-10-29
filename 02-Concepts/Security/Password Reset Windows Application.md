---
type: concept
tags: [concept, security, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Password Reset > Password Reset Windows Application, Set up Microsoft Active Directory for Password Reset, Installing and configuring Password Reset Windows Application (installation requirements, download, install by EXE, MSI or wizard, security settings, proxy server options incl. PAC file, display language, McAfee disk encryption, customize, limitations, uninstall), Reset your password on Windows systems, Password Reset and Password Change reports and logs (event log), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/password-reset/install-configure-password-reset-windows-app.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Password Reset Windows Application

**In one line:** a Windows credential provider, installed on user PCs, that adds a **Forgot password?** link to the Windows login screen so a locked-out user can reset or unlock their **Active Directory** password through an instance Password Reset process.

From the Brazil docs; not tested. Part of [[Password Reset Application Overview]]; AD store set-up in [[Password Reset Credential Stores]].

## Requirements

- Instance: plugin **Password Reset Windows App (Password Reset Orchestration)** `com.glideapp.password_reset_desktop` and store app **Microsoft AD for Password Reset**; an AD credential store (the only type supported).
- Client: .NET Framework 4.7.1+, Visual C++ Redistributable (VS 2017), 1 GHz CPU, 512 MB RAM, 10 MB disk, x86 or x64; direct access to the internet and the instance (no SHA certificate blocking); on the corporate network to reset an AD password.
- Download: ServiceNow Store (Publisher Portal) > filter *Ancillary Software* > **Password Reset Windows Application** > **Download** (any user).

| Version (as stated) | Windows | Releases |
|---|---|---|
| 4.1 | 7, 8.1, 10 Enterprise, 10 Pro | "latest version from the store" |
| 5.1.4 | 11 | Yokohama, Xanadu, Washington DC |

## How it behaves

Identify (user name, or user name and email for multi-identification, plus CAPTCHA) > Verify (personal data, authenticator app, security questions, SMS, email or Soft PIN) > Reset (new password twice) or, when locked, **Unlock Account** (if **Enable account unlock**) as well as **Reset Password**. Depending on the process the user then sees a generated password or gets an email; by default the instance emails a URL with a user-specific token, not a temporary password.

Limitations: no custom verifications; always the base-system CAPTCHA (never Google reCAPTCHA); no strength bar; only one verification of some types; Advanced-tab UI macros ignored (default success and failure messages only); the password hint keeps newlines but no other formatting.

## Install

Instance side first: a `security_admin` (elevated) sets `glide.security.use_csrf_token` = true so the app can get a token ([[High Security Settings]]). Then a Windows local administrator installs by one of:

- **EXE**: `PasswordResetWinAppInstall.exe /VERYSILENT /PasswordResetLinkURL https://<instance>.service-now.com/$pwd_reset.do?sysparm_url=<suffix> /PasswordResetLinkName "Forgot password?"` with optional `/Log=<path>` (folder must exist), `/NORESTART`, `CredentialProviderGUID` (only for a custom credential provider). Type the quotes, do not paste them.
- **MSI** (network roll-out): `msiexec.exe /i PasswordResetWinAppInstall.msi /quiet WRAPPED_ARGUMENTS="/SUPPRESSMSGBOXES /VERYSILENT /NORESTART /PasswordResetLinkURL ... /PasswordResetLinkName ""Forgot password?"""` (doubled quotes inside); MSI restarts by default unless `/NORESTART`. Match the file name to the download.
- **Wizard**: run the EXE as administrator, enter the reset page URL, the link text, keep the default GUID, accept licence, folder and Start menu folder *ServiceNow*, install, restart.

Uninstall: `C:\Program Files\ServiceNow\uninstall\unins000.exe`, or `msiexec.exe /x PasswordResetWinAppInstall.msi /quiet`.

## Proxy

Options (the page announces three and lists four): registry keys on the credential provider key (`ProxyServer` `<proxy>:<port>`, `ProxyEnable`, `ProxyUser`, `ProxyPassword` `<PROXY_PASSWORD>`, `ProxyDomainName`, `ByPassProxyOnLocal`); an exception policy on the proxy for `service-now.com` (set the LAN proxy for the SYSTEM account through `psexec -s -i` and Internet Explorer, then export `HKEY_USERS\.DEFAULT\...\Internet Settings` to clients); client credentials in the form `http://<user>:<password>@<proxy>:<port>`; or a PAC / WPAD script, either in Internet Explorer settings or in the registry (`ProxyEnable` true, `ProxyServer` = PAC URL, `UseProxyAutoConfigScript` true).

## Registry customisation

Under `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{<GUID>}`: `AppDir` (`C:\Program Files\ServiceNow`), `AppFormIconFile` (replace the logo), `AppFormTitle`, `CheckCertificateRevocationList` (default true; false skips the CRL check when the app is slow to start, at the cost of certificate validation), credential provider GUID, `DebugFlag` (1 writes the *ServiceNowPwdReset* event log, viewed in Event Viewer), link text and URL, proxy keys, `ServiceNowServerVersion`, `ServiceNowWinAppVersion`, `UserAccountPictureLoc`, `WorkingDir`.

Language: the app passes the Windows display language; activate that language plugin and make sure no `sys_user_preference` row fixes `user.language` for the guest user. McAfee Drive Encryption 7.2: in ePolicy Orchestrator allow integrated third-party credential providers, and add the client registry key under `McAfee EndPoint Encryption\IntegratedCredentialProviders\{0780AF60-65C2-4718-942D-E0C56E89EF9B}` with Vendor, Product, Version, BuiltAgainst.

## Unconfirmed variants

- Credential provider GUID: `{0780AF60-65C2-4718-942D-E0C56E89EF9B}` (proxy and McAfee pages), `{6f45dc1e-5384-457a-bc13-2cd81b0d28ed}` (customisation table) and `{B6EFF27D-C1C4-481F-B81B-F3547C47D58A}` (DebugFlag on the logs page).
- Supported versions and Windows editions differ between the two requirement pages (table above).
- Proxy: "three options" vs four listed.

## Related

- [[Password Reset Verifications and Enrollment]] · [[MID Server Overview and Architecture]] (AD resets run through a MID Server)
