# openvscode-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [OpenVSCode Server](https://github.com/gitpod-io/openvscode-server).

## What this is

A four-file TOS Docker application archive (`openvscodedocker.tar.gz`) that installs
OpenVSCode Server on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `openvscodedocker`)
- `openvscodedocker.lang` — 23-language superset (TOS requires 14)
- `openvscodedocker.svg` — application icon (274 bytes, 2 SVG elements)
- `docker-compose.yml` — one service, image `gitpod/openvscode-server:1.105.1`

## How it works

| | |
|---|---|
| Container image | `gitpod/openvscode-server:1.105.1` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8124/` (container port 3000) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/home/workspace` → `/Volume1/DockerAppData/openvscodedocker/workspace` |
| Logs | `docker logs openvscodedocker` (stdout/stderr) |

`/home/workspace` (mounted from `DockerAppData/openvscodedocker/workspace`) holds your projects, the `.openvscode-server` extensions/settings and `.connection-token`.

## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Entrypoint wrapper**: generates a random connection token on first start (stored in `workspace/.connection-token`) and passes it with `--connection-token-file`; the URL with `?tkn=…` is printed in the container log.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** probing the service on container port 3000.
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.
- **Token instead of open access.** The upstream container disables the connection token; the wrapper generates one and stores it in the workspace, so the editor is protected by a random URL.
- **Runs as uid 1000.** The image's `openvscode-server` user matches the TOS application user.

## Privacy

This application runs entirely on your NAS. It does not include analytics, telemetry or advertising SDKs, and the packaging contains no code that sends data to the packager. Data is only exchanged with the services you configure yourself (for example media servers, notification endpoints or model APIs), and only from the container. Everything the application stores lives in the application data folder described above; removing the app with its data deletes it.

## Third-party components

The package runs the upstream image `gitpod/openvscode-server:1.105.1` unmodified. Its components and their licences are those of the upstream project (https://github.com/gitpod-io/openvscode-server), which is distributed under **MIT**. No upstream source code is redistributed in this repository; only the four packaging files are original work.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/openvscodedocker/workspace` | OpenVSCode Server application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/openvscodedocker.tar.gz + .sha256
scripts/build.sh 1.105.1-2   # packaging iteration bump
scripts/build.sh 1.105.1-1 aarch64
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/openvscodedocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v1.105.1-1`**, assets `openvscodedocker.tar.gz` +
   `openvscodedocker.tar.gz.sha256` (Docker asset naming: `<app_id>.tar.gz`, **no
   platform suffix**).
3. Developer platform → Add Application: ID `openvscodedocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `1.105.1-1` → automated validation → review.

## License / branding

OpenVSCode Server is distributed by its upstream authors under **MIT**. The container image is the official image from Docker Hub (`gitpod/openvscode-server:1.105.1`) and is used unmodified; no upstream source code is redistributed here. This packaging is an independent community submission by Moechz and is not affiliated with the upstream project or TerraMaster.

## Limitations

- The token is printed in the log and stored in the workspace; delete the file and restart to rotate it.
- The terminal runs as uid 1000 on the NAS; treat access like SSH access.
- The UI is plain HTTP; use a TLS reverse proxy for remote access.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
