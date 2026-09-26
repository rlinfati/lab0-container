# lab0-container

Multi-architecture (`x86_64` and `aarch64`) container images that GitHub Actions builds and publishes to `ghcr.io/rlinfati/lab0-container`.

## Images

| Tag | Base | Contents | Ports |
|---|---|---|---|
| `grbts` | ubi10/ubi-micro | Gurobi Token Server (`grb_ts`, `grbgetkey`, `grbprobe`). The license is mounted at `/opt/gurobi` | 41954/tcp |
| `jupyter-hub` | ubi10/ubi-minimal | JupyterHub with oauthenticator, kubespawner and idle-culler | 8000/tcp |
| `jupyter-lab-<apps>-<vers>` | ubi10/ubi-minimal | Single-user JupyterLab (user `jovyan`) | 8888/tcp |
| `rbackup` | ubi10/ubi | rclone, ffmpeg, rsync and ssh for backups | — |
| `strongswan` | fedora:44 | strongSwan (IPsec) and nftables | 500/udp, 4500/udp |
| `vlmcsd` | ubi10/ubi-micro | vlmcsd KMS server, built from `vlmcsd-master.zip` | 1688/tcp |

### jupyter-lab variants

| `apps` | `vers` | Extra contents |
|---|---|---|
| `base` | `latest` | Miniconda, JupyterLab, nb_conda_kernels |
| `devcpp` | `latest` | gcc, clang, gdb, make, cmake, strace |
| `anaconda` | `latest` | Full `Anaconda` conda environment |
| `julia` | `1.10`, `1.12`, `1.13`, `1.14` | Julia, IJulia, JuMP and the CPLEX, Gurobi and Xpress solvers ([setup.jl](jupyter-lab/setup.jl), [setupORlib.sh](jupyter-lab/setupORlib.sh)) |
| `juliacuda` | `1.10` | `julia` + CUDA.jl |

The Julia 1.14 build is allowed to fail without failing the whole workflow (`continue-on-error`).

## Git

- git update-ref -d HEAD && git commit -a -m Initial\ commit && git push -f
- git commit -a -m commit-$(date +'%Y-%m-%d-%H-%M-%S') && git push
- git gc --prune=now && git fsck
