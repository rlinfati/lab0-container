# lab0-container

Multi-arch (x86_64 + aarch64) container images built with GitHub Actions and
published to `ghcr.io/rlinfati/lab0-container`.

## Images

| Image | Description | Base | Ports |
|---|---|---|---|
| `grbts` | Gurobi Token Server (`grb_ts`) | ubi10/ubi-micro | 41954/tcp |
| `jupyter-hub` | JupyterHub + KubeSpawner + OAuthenticator | ubi10/ubi-minimal | 8000/tcp |
| `jupyter-lab-<app>-<ver>` | JupyterLab single-user (base, devcpp, anaconda, julia, juliacuda) | ubi10/ubi-minimal | 8888/tcp |
| `rbackup` | rclone + ffmpeg + rsync/ssh | ubi10/ubi | — |
| `strongswan` | strongSwan IPsec + nftables | fedora:44 | 500/udp, 4500/udp |
| `vlmcsd` | vlmcsd KMS emulator | ubi10/ubi-micro | 1688/tcp |

## Tags

Each build produces:

- `<image>-<arch>-<YYYY-MM-DD>`: per-architecture image (deleted weekly by the `z-cleanup` workflow)
- `<image>-<YYYY-MM-DD>`: dated multi-arch manifest
- `<image>`: points to the latest build

Jupyter-lab images use `jupyter-lab-<app>-<ver>` as the image name, e.g. `jupyter-lab-julia-1.12`.

## Updating versions

- **GitHub Actions and base images**: Dependabot (`.github/dependabot.yml`).
- **rclone, ffmpeg, Gurobi**: update the `ARG` in the Dockerfile **and** the workflow matrix
  (`rbackup.yml`, `grbts.yml`). Look for `# FIX:` comments.
- **Julia**: add the version to the matrix in `.github/workflows/jupyter-lab.yml`.

## Repo maintenance

- git update-ref -d HEAD && git commit -a -m Initial\ commit && git push -f
- git commit -a -m commit-$(date +'%Y-%m-%d-%H-%M-%S') && git push
- git gc --prune=now
- git fsck
