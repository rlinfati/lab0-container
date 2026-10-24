# lab0-container

Multi-architecture (`x86_64` and `aarch64`) container images that GitHub Actions builds and publishes to `ghcr.io/rlinfati/lab0-container`.

```sh
docker pull ghcr.io/rlinfati/lab0-container:rbackup
docker pull ghcr.io/rlinfati/lab0-container:jupyter-lab-julia-1.13
```

## Images

| Tag | Base | User | Contents | Ports |
|---|---|---|---|---|
| `grbts` | ubi10/ubi-micro | `nobody` (65534) | Gurobi Token Server (`grb_ts`, `grbgetkey`, `grbprobe`). The license is mounted at `/opt/gurobi` | 41954/tcp |
| `jupyter-hub` | ubi10/ubi-minimal | `jhub` (1000:100) | JupyterHub with oauthenticator, kubespawner and idle-culler. Config file: `/etc/jupyterhub/jupyterhub_config.py` | 8000/tcp |
| `jupyter-lab-<target>-<julia_version>` | ubi10/ubi-minimal | `jovyan` (1000:100) | Single-user JupyterLab (volume `/home/jovyan/work`) | 8888/tcp |
| `rbackup` | ubi10/ubi | `rbackup` (1000:100) | rclone, ffmpeg, rsync and ssh for backups | — |
| `strongswan` | fedora:latest | root | strongSwan (IPsec) and nftables | 500/udp, 4500/udp |
| `vlmcsd` | ubi10/ubi-micro | `nobody` (65534) | vlmcsd KMS server | 1688/tcp |

Only `strongswan` runs as root (it needs privileges for IPsec and nftables). The users with UID 1000 (`jhub`, `jovyan`, `rbackup`) expect the volumes they write to (PVCs and `hostPath`, e.g. `/DataVolume/DataBackup`) to be owned by `1000:100`.

### jupyter-lab variants

`<target>` is the stage of [jupyter-lab/Dockerfile](jupyter-lab/Dockerfile) and `<julia_version>` is the Julia version (`latest` for the non-Julia targets).

| `target` | `julia_version` | Extra contents |
|---|---|---|
| `base` | `latest` | Miniconda, JupyterLab, nb_conda_kernels |
| `devcpp` | `latest` | gcc, clang, gdb, make, cmake, strace |
| `anaconda` | `latest` | Full `Anaconda` conda environment plus the Gurobi, CPLEX and Xpress Python packages |
| `julia` | `1.10`, `1.12`, `1.13`, `1.14` | Julia, IJulia, JuMP and the CPLEX, Gurobi and Xpress solvers ([setup.jl](jupyter-lab/setup.jl), [setupORlib.sh](jupyter-lab/setupORlib.sh)) |
| `juliacuda` | `1.10` | `julia` + CUDA.jl |

The Julia 1.14 build is allowed to fail without failing the whole workflow (`continue-on-error`).

AMPL is not installed in the image. The `julia` targets ship [setupAMPL.sh](jupyter-lab/setupAMPL.sh) as `/opt/setupAMPL.sh`; run it by hand inside a container (`sh /opt/setupAMPL.sh`) to install `amplpy` and the AMPL base module, and to activate the AMPL license.

## Licenses

The [LICENSE](LICENSE) of this repository only covers its own files (Dockerfiles, scripts and workflows). The images include third-party software under its own terms, and the commercial solvers (Gurobi, CPLEX, Xpress, AMPL) are **not licensed by the images**: bring your own license and provide it at runtime, outside the image.

## Tags

Each build publishes three kinds of tags (`<image>` is the tag name from the tables above):

| Tag | Meaning |
|---|---|
| `<image>-<arch>-<date>` | Single-architecture image (`x86_64` or `aarch64`), `<date>` is `YYYY-MM-DD` of the build |
| `<image>-<date>` | Multi-architecture manifest of the two images above |
| `<image>` | Multi-architecture manifest, same as the most recent `<image>-<date>` |

## Workflows

All in [.github/workflows](.github/workflows).

| Workflow | Trigger | What it does |
|---|---|---|
| `_image.yml` | called by the image workflows | Reusable. Builds each architecture on a native runner, then merges them with `docker buildx imagetools create`. With `retag: true` it only promotes an existing `<image>-<date>` to `<image>` |
| `grbts`, `jupyter-hub`, `jupyter-lab`, `rbackup`, `strongswan`, `vlmcsd` | push to `master` touching `_image.yml`, its own workflow or its own directory; manual | One per image. They only set the build arguments and call `_image.yml` |
| `rebuild-all.yml` | day 21 of each month, 01:01 UTC; manual | Dispatches the six image workflows above (list configurable), so images pick up base-image and package updates |
| `cleanup.yml` | Sundays, 12:12 UTC; manual | Deletes the per-arch tags (older than 1 day), untagged, ghost and partial images from ghcr.io |

Manual runs of an image workflow take two inputs:

- `retag`: promote an existing image to `<image>` instead of building.
- `date`: the `<date>` of the image to promote, only used with `retag`.

`jupyter-lab` also takes `target` and `julia_version` to build (or retag) a single variant; empty means all variants. A retag needs both.

The image and manifest steps run on `ubuntu-slim` where possible. Only the build jobs need a Docker daemon, so only they use the full runners (`ubuntu-26.04`, `ubuntu-26.04-arm`).

## Dependency updates

[Renovate](renovate.json) only reports: with `dependencyDashboardApproval` it opens no PRs and lists pending updates in the "Dependency Dashboard" issue; tick a box there to get its PR. It runs from [renovate.yml](.github/workflows/renovate.yml) on Mondays 05:00 UTC and manually (`dry-run` only logs, without touching the issue).

It covers GitHub Actions, Dockerfile `FROM` lines, and the versions annotated with `# renovate: datasource=... depName=...` in the Dockerfiles (Gurobi, Julia, CUDA, rclone, FFmpeg) and in `setupORlib.sh` (Xpress). Dependabot is not used.

The workflow uses the `RENOVATE_TOKEN` secret (a PAT with `repo` and `workflow` scopes) and falls back to `github.token`, which is enough for the issue but cannot create PRs that trigger workflows.

## Git

- git update-ref -d HEAD && git commit -a -m Initial\ commit && git push -f
- git commit -a -m commit-$(date +'%Y-%m-%d-%H-%M-%S') && git push
- git gc --prune=now && git fsck

## Operations

```sh
kubectl -n prepull rollout restart ds/prepull
kubectl -n prepull logs ds/prepull -c prepull-once -f

# owner 1000:100, files 0644/0755, directories 0755
find /DataVolume /var/mnt/localpath \
  \( ! -uid 1000 -o ! -gid 100 \
     -o \( -type f ! -perm 0644 ! -perm 0755 \) \
     -o \( -type d ! -perm 0755 \) \) -ls
```
