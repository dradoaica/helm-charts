# Security Policy

## Scope

This repository ships **Helm charts only**. The applications they deploy (Apache Ignite 2.x and 3.x, ClamAV, Conductor
OSS, and the ASP.NET Core Ignite server) are maintained upstream.

In scope, meaning issues introduced by the charts themselves:

- Templates that leak credentials, for example a password rendered into a ConfigMap, an annotation, or an environment
  variable when a Secret reference was intended
- Insecure defaults in `values.yaml`, such as overly broad RBAC, privileged or root containers, or services exposed
  without need
- `existingSecret` / `manageSecret` handling that ignores the user-supplied Secret or overwrites it
- TLS/SSL wiring that silently turns encryption off or skips certificate verification
- Problems in the release pipeline (`.github/workflows/release.yaml`), the GitHub Pages chart index, or the OCI charts
  published to `ghcr.io/dradoaica/charts`

Out of scope, so please report these upstream:

- Vulnerabilities in the container images or the applications themselves:
  [Apache Ignite](https://ignite.apache.org/our-community.html#faq),
  [ClamAV](https://github.com/Cisco-Talos/clamav/security),
  [Conductor OSS](https://github.com/conductor-oss/conductor/security)
- Kubernetes or Helm vulnerabilities
- Configurations that only become insecure because of values you explicitly set

If a CVE is fixed upstream and the chart still pins an affected `appVersion` or image tag, that is in scope: open an
issue asking for a version bump.

## Supported Versions

Only the latest released version of each chart is supported. Fixes are released as a new chart version and never
backported.

| Chart                    | Supported line |
|--------------------------|----------------|
| aspnetcore-ignite-server | latest 2.18.x  |
| clamav-openshift         | latest 1.5.x   |
| conductor-oss-conductor  | latest 3.32.x  |
| ignite                   | latest 2.18.x  |
| ignite-3                 | latest 3.2.x   |

If you can't upgrade, say why in your report so the impact on your setup can be weighed.

## Reporting a Vulnerability

**Do not open a public issue for an unfixed vulnerability.**

Report it privately through
[GitHub Security Advisories](https://github.com/dradoaica/helm-charts/security/advisories/new). If that isn't available
to you, email the maintainer at the address listed in any chart's `Chart.yaml` under `maintainers`.

Please include:

- The chart name and version (`helm list` or `Chart.yaml`)
- The values used, minimal and with secrets redacted
- The rendered manifest that shows the problem (`helm template ...`)
- The impact, and how an attacker could exploit it

You should get an acknowledgement within 7 days. Once a fix is released, the advisory is published and you will be
credited unless you ask not to be.

Hardening suggestions that aren't exploitable (for example, tightening a default `securityContext`) can go in a normal
issue labelled `vulnerability`.

## Known Limitations

- **ignite-3**: the SSL keystore/truststore passwords (`ssl.*.keyStorePassword` / `ssl.*.trustStorePassword`) are
  rendered into the node ConfigMap (`ignite-config.conf`), because Ignite 3 can't yet read them from environment
  variables in its HOCON configuration. The Secret-backed environment variables are already wired into the StatefulSet
  and will be used once upstream supports `${?VAR}` substitution. Until then, restrict `get` on ConfigMaps in the
  release namespace to the same principals that can read Secrets. The authentication password isn't affected: the
  cluster-init Job reads it from the Secret.

## Hardening Recommendations

- Prefer `existingSecret` (managed by External Secrets, Sealed Secrets, Vault, or similar) over putting passwords in
  values files, and set `manageSecret: false`.
- Pin chart versions, and pull OCI charts from `oci://ghcr.io/dradoaica/charts` by version.
- Enable TLS/SSL wherever the chart supports it, and keep services `ClusterIP` unless you need external access.
