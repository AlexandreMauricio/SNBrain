---
type: reference
tags: [reference, security, integrations, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Edge Encryption (chapter read in full 2026-10-08) - Edge Encryption proxy server properties, Configure additional properties, Configure a web proxy, Set up a SafeNet KeySecure keystore, Using a load balancer with the Edge proxy server, Edge Encryption clients, Increase debug logging for the Edge Encryption proxy. https://www.servicenow.com/docs/r/platform-security/edge-encryption/edge-encryption-proxy-server-properties.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Edge Encryption Proxy Properties Reference

**In one line:** the settings of an Edge Encryption proxy live in `<installation directory>/conf/edgeencryption.properties` on the proxy host (not on the instance); the proxy must be restarted after any change.

From the Brazil docs. Context: [[Edge Encryption Proxy - Installation, Keystores and Upgrades]]. Values that hold passwords are shown here by name only.

"Same on all" = the docs state it must be identical on every proxy of the instance (blank = not stated; all proxies must in any case hold the same encryption keys).

## Identity and connection

| Property | Meaning | Same on all |
|---|---|---|
| `edgeencryption.proxy.name` | unique proxy name (duplicates stop statistics and error reporting) | no, unique |
| `edgeencryption.proxy.host` | host name clients use | no |
| `edgeencryption.proxy.http.port`, `edgeencryption.proxy.https.port` | listening ports | no |
| `edgeencryption.proxy.rewrite.location.host`, `edgeencryption.proxy.rewrite.location.https.port` | host and port of the load balancer, written into redirects | |
| `edgeencryption.target.host`, `.port`, `.protocol` | the instance | yes |
| `edgeencryption.target.username`, `edgeencryption.target.password` | the account with role `edge_encryption` | |
| `edgeencryption.webproxy.host`, `.port`, `.user`, `.password` | outbound web proxy; leave commented out if none | |
| `edgeencryption.proxy.locked` | true: the proxy accepts no more configuration or rule changes from the instance. For production once everything is final | |

## Keys, signing and certificate

| Property | Meaning | Same on all |
|---|---|---|
| `edgeencryption.customer.assigned.known.cleartext` | a text each proxy encrypts at start-up so the instance can check that all proxies hold the same keys (the instance never learns the text or the keys) | yes |
| `edgeencryption.encrypter.static.iv` | initialization vector for equality and order preserving encryption; exactly 16 ASCII characters | yes |
| `edgeencryption.proxy.signature.keystore.path`, `.password`, `.keyalias` | keystore and alias of the RSA pair that signs configurations and rules | yes |
| `edgeencryption.proxy.https.cert.alias`, `edgeencryption.proxy.https.keystore.path`, `.password` | the certificate the proxy presents to clients | |
| `edgeencryption.keystore.path`, `edgeencryption.keystore.password` | Java KeyStore holding the AES keys; commented out for file store or SafeNet | |
| `edgeencryption.keyfile.directory` | directory of key files (`keys`); for the file store and for Unbound keys | |
| `edgeencryption.nae.enabled`, `.server`, `.port`, `.protocol`, `.retries`, `.keystore.path`, `.keystore.password` | SafeNet KeySecure (NAE) connection | |
| `edgeencryption.nae.username` (printed as `edgeencryption.nae.user` in the SafeNet example), `edgeencryption.nae.password` | SafeNet login, or instead: | |
| `edgeencryption.nae.client.certificate` | client certificate authentication to SafeNet (not combined with user and password) | |
| `edgeencryption.ekm.provider.classname` | internal provider class; do not change (set to the NAE provider class to keep SafeNet libraries outside the install directory) | |
| `edgeencryption.thirdparty.vendor.library.path` | directory of vendor jars (SafeNet, Unbound) | |
| `edgeencryption.ekm.provider.rsa.wrapping.key.alias` | Unbound wrapping key alias | yes |
| `edgeencryption.encrypter.properties.password` | name of the file in `conf` whose content is used to obfuscate passwords in this file | |

Deprecated, kept for compatibility (keys are now maintained on the instance): `edgeencryption.encrypter.default.key128`, `.default.key256`, `.key`, `.type`, `.file`, `.password`.

## Proxy database

`edgeencryption.db.url`, `edgeencryption.db.name` (default `edgeencryption`), `edgeencryption.db.user`, `edgeencryption.db.password`, `edgeencryption.db.bootstrap.file` (do not change). All the same on every proxy.

## Behaviour and tuning

| Property | Default | Meaning |
|---|---|---|
| `edgeencryption.config.poll.interval` | 5 s | how often configuration is fetched. **Do not change** |
| `edgeencryption.proxy.keepalive.interval` | 10 s (minimum 5; the clients page says default 5) | heartbeat to the instance |
| `edgeencryption.proxy.idle.timeout` | 300 s | transaction timeout |
| `edgeencryption.register.retry.count` | 0 = no limit | registration attempts |
| `edgeencryption.rules.dir` | | folder of encryption rules on the proxy |
| `edgeencryption.jobs.concurrency` | | mass jobs running at once on this proxy |
| `edgeencryption.jobs.requests_per_second` | | job requests per second sent to the instance |
| `edgeencryption.attachments.request.timeout.seconds` | | attachment upload timeout |
| `edgeencryption.encryption.order_preserving.cache.enable`, `.cache.size` | | cache for order-preserving encryption, size in bytes |
| `edgeencryption.tokenization.exclusion.list` | | fields where patterns must not tokenize |
| `edgeencryption.request.buffer.size`, `edgeencryption.httpclient.request.buffer.size`, `edgeencryption.httpclient.header.size` (8K to 32K) | | buffers. **Do not change** |
| `edgeencryption.stat.collection.enabled` | true (not in the file by default) | statistics for the performance graphs |
| `edgeencryption.stat.collection.interval` | 30 s (minimum) | statistics interval |

## Other files on the proxy host

| File | Use |
|---|---|
| `conf/wrapper.conf` | Java options (`wrapper.java.additional.<n>`): memory limits, temp directory, `-Djavax.net.debug=all` for TLS debugging (restart needed); Windows service name |
| `conf/log4j2.properties` | logging; picked up within about a minute without restart. `logger.edge.level=debug` for verbose application logs; an extra timing appender writes one line per request (URI, method, rule executed, processing and round-trip times, response code) to `logs/edgenetwork.log` |
| `logs/edgeencryption.log`, `logs/wrapper_<date>.log` | application log; wrapper log (also where a rule's `print()` writes) |

## Related

- [[Edge Encryption Proxy - Installation, Keystores and Upgrades]] · [[Edge Encryption Overview]] · [[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]]
