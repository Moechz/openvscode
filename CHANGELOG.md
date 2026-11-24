# Changelog

All notable user-visible changes to the OpenVSCode Server TOS application package.

## 1.105.1-1 — 2026-11-14

### Added
- First release. OpenVSCode Server (`gitpod/openvscode-server:1.105.1`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8124 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/openvscodedocker/`.
