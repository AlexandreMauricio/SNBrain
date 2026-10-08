---
type: reference
tags: [reference, platform, automation, security, integrations, instance-admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications > Automated Test Framework (ATF) > Headless Browser for Automated Test Framework (read 2026-10-08 through the docs site; whole section): Headless Browser for ATF, Headless Browser setup for Linux (generate certificates, configure Docker, Docker image, Docker secrets, instance setup, configure ATF, verify), Headless Browser setup for Microsoft Windows (install Docker and the same six steps), Headless Browser system properties, Headless Browser troubleshooting. The openssl and keytool command lines are summarised, not transcribed. https://www.servicenow.com/docs/r/application-development/automated-test-framework-atf/atf-headless-browser.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ATF Headless Browser (Legacy Docker Runner)

**What it is:** a way to run scheduled ATF user-interface tests without a person keeping a client test runner tab open: the instance asks a Docker host of yours to start a container that opens a browser, signs in and loads the scheduled client test runner.

From the Brazil docs. **Legacy**: ServiceNow recommends the Store application *ATF Test Generator and Cloud Runner* instead. Self-hosted (on-premise) instances must keep using this, because Cloud Runner is not offered to them. ATF itself: [[Automated Test Framework Overview]].

## Requirements

| Item | Detail |
|---|---|
| Roles | admin on the instance; local administrator on the host |
| MFA | must be **disabled** for the runner user's sign-in |
| Host | Linux, or **only** Windows Server 2019 build 10.0.17763.737 |
| Software | Docker, OpenSSL, Java 1.8 (for `keytool`; other versions make certificate validation on the instance fail) |
| Network | two-way: the instance must reach the host on the Docker port (2376 suggested), and the host must reach the instance. Allow the instance's IP ranges inbound |

## Setup, in order

1. **Certificates** (on the host): a certificate authority key and certificate, a server key pair whose subject alternative names include the host name and IP, and a client key pair for client authentication. Then put the CA certificate and the client key pair into a Java keystore file (`my.keystore`) and note its password. Without TLS the Docker API accepts unauthenticated requests. Keep the working passwords in session-only environment variables, never in a shell profile.
2. **Docker daemon**: point `tlscacert`, `tlscert`, `tlskey` at the files and set `tlsverify` true in `daemon.json` (`/etc/docker/daemon.json`; on Windows `C:\ProgramData\docker\config\daemon.json` with doubled backslashes and `"hosts": ["tcp://0.0.0.0:2376", "npipe://"]`), expose the API on the port (systemd override `ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2376` on Linux) and restart Docker.
3. **Image**: `docker pull ghcr.io/servicenow/atf-headless-runner:<tag>` (`lin-...` or `win-...`; the tag must match what the instance release expects).
4. **Secret**: `docker swarm init`, then create a Docker secret named `sn_password` holding the runner user's password. Keep the returned **secret ID**.
5. **Instance**:
   - a user with `atf_test_designer` whose password is the one stored in the secret (the Windows page says admin or `atf_test_admin`);
   - **System Definition > Certificates**: new, **Type** Java Key Store, the keystore password, attach the keystore file, **Validate certificate**;
   - **System Security > Protocol Profiles** (`sys_protocol_profile`): **Protocol** `docker`, **Default port** 2376, **Keystore** the certificate above;
   - **Connections & Credentials > Connection & Credential Aliases** (`sys_alias`) > alias *Docker* > new connection: no credential, **URL Builder** and **Mutual authentication** ticked, the protocol profile, **Host** = the host's name or IP;
   - with **self-signed** certificates only: `com.glide.communications.httpclient.verify_hostname` = false and `com.glide.communications.trustmanager_trust_all` = true. The second makes the platform trust any certificate for outbound calls: a real security trade-off, avoid it by using certificates from a trusted authority.
6. **ATF properties** (**Automated Test Framework > Administration > Properties**): enable test execution and scheduled suite execution, then under *Headless Runner Properties* enable the feature and set the user name, the secret ID and the image name; on Windows also the secret path `C:\ProgramData\Docker\secrets\<secret name>`.
7. **Verify**: a suite schedule with **Run** = On Demand, a scheduled suite row with browser Chrome or Firefox and the host's OS, **Execute Now**. Afterwards scheduled suites and CI/CD runs start headless runners by themselves.

## Properties (`sn_atf.headless.*`)

| Property | Default | Purpose |
|---|---|---|
| `enabled` | false | create headless runners for scheduled UI test runs |
| `username` | | the user that signs in |
| `secret_id`, `secret_name`, `secret_path` | path `/run/secrets/<secret_name>` | the Docker secret holding the password |
| `secret_uid`, `secret_gid` | 1000 | the container user's ids |
| `docker_image_name` | | `name:tag` of the image |
| `default_browser`, `default_os` | Chrome, Linux | |
| `browser_options` | `--no-sandbox,--disable-gpu` | options passed to the browser |
| `timeout_mins` | 1440 | minutes before the Docker service shuts itself down |
| `request_timeout_sec` | 200 | timeout of calls to the Docker host |
| `retry_count` | 10 | checks for the runner coming online before the run is cancelled |
| `docker_window_seconds` | 60 | two failed container starts within this time = no more restarts |
| `heartbeat_enabled`, `heartbeat_uri` | true, `/api/now/atf_agent/online` | the container checks every minute that its runner record (`sys_atf_agent`) is still online and stops otherwise |
| `images_check.enabled` | false | verify the image exists on the host before running |
| `service_stop_deletes` | false | true = keep services and containers after a run, for debugging |
| `service_clean_exclude_list` | | service ids the nightly cleanup must not delete |
| `runner_url`, `login_page`, `login_button_id`, `user_field_id`, `password_field_id`, `runner_banner_id`, `validation_page`, `validation_id`, `vp_has_role_id`, `vp_success_id` | base-system values | pages and HTML ids the automation script uses to sign in and to confirm the runner loaded; change only if the sign-in page was customised |

## Troubleshooting

| Symptom | Look at |
|---|---|
| Any run, passed or failed | container stdout and stderr are stored in `sn_atf_docker_service` |
| "Headless client test runner did not start in the time allotted" | the container failed while starting: read `sn_atf_docker_service` |
| "Error caught running Docker flow when starting the ATF tests" | follow the link to the flow context; usually the instance cannot reach the Docker host |
| Nothing arrives | firewalls in both directions |

## Related

- [[Automated Test Framework Overview]] · [[ATF Test Suites, Schedules and Administration]] · [[Autonomous Engineer and Test Agent]]
