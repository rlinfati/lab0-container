#!/bin/sh

set -ex

export CONDA_PKGS_DIRS=$HOME/.orlibs/pkgsx/
conda create --quiet --yes --prefix $HOME/.orlibs/pycpx --no-deps ibmdecisionoptimization::cplex && \
conda create --quiet --yes --prefix $HOME/.orlibs/pygrb --no-deps gurobi::gurobi && \
conda create --quiet --yes --prefix $HOME/.orlibs/pyxpr --no-deps fico-xpress::xpress=9.8 fico-xpress::xpresslibs=9.8 && \
conda clean --all --yes && \
find $HOME/.orlibs/pycpx/ -type f -name libcplex\*   -ls && \
find $HOME/.orlibs/pygrb/ -type f -name libgurobi\*  -ls && \
find $HOME/.orlibs/pyxpr/ -type f -name libxprs.\*   -ls && \
find $HOME/.orlibs/pyxpr/ -type f -name libxprl\*    -ls && \
find $HOME/.orlibs/pyxpr/ -type f -name \*xpauth.xpr -ls
# FIX: fico-xpress::xpress=9.8

conda create --quiet --yes --prefix $HOME/.orlibs/pypip python && \
$HOME/.orlibs/pypip/bin/python -m pip --no-cache-dir install amplpy --upgrade && \
$HOME/.orlibs/pypip/bin/python -m amplpy.modules install --no-cache-dir cplex gurobi xpress && \
conda clean --all --yes && \
find $HOME/.orlibs/pypip/ -type f -name libcplex\*   -ls && \
find $HOME/.orlibs/pypip/ -type f -name libgurobi\*  -ls && \
find $HOME/.orlibs/pypip/ -type f -name libxprs.\*   -ls && \
find $HOME/.orlibs/pypip/ -type f -name libxprl\*    -ls && \
find $HOME/.orlibs/pypip/ -type f -name \*xpauth.xpr -ls

SYSEXT=so
if [[ $(uname -s) == "Darwin" ]]; then
    SYSEXT=dylib
else true; fi

mkdir -p $HOME/.orlibs && \
ln -sf $HOME/.orlibs  $HOME/.orlibs/lib && \
ln -sf $HOME/.orlibs  $HOME/.orlibs/bin && \
find $HOME/.orlibs/pycpx/ -type f -name libcplex\*      -ls -exec cp {} $HOME/.orlibs/ \; && \
find $HOME/.orlibs/pygrb/ -type f -name libgurobi\*     -ls -exec cp {} $HOME/.orlibs/ \; && \
find $HOME/.orlibs/pyxpr/ -type f -name libxprs.\*      -ls -exec cp {} $HOME/.orlibs/libxprs.$SYSEXT \; && \
find $HOME/.orlibs/pyxpr/ -type f -name libxprl\*       -ls -exec cp {} $HOME/.orlibs/libxprl.$SYSEXT.x9.8 \; && \
find $HOME/.orlibs/pyxpr/ -type f -name \*xpauth.xpr    -ls -exec cp {} $HOME/.orlibs/xpauth.xpr \;

if [[ "$(uname -s)" == "Darwin" ]]; then
    mv $HOME/.orlibs/libxprl.$SYSEXT.x9.8 $HOME/.orlibs/libxprl.$SYSEXT
    codesign --display --verify --verbose -d $HOME/.orlibs/libcplex*  || true
    codesign --display --verify --verbose -d $HOME/.orlibs/libgurobi* || true
    codesign --display --verify --verbose -d $HOME/.orlibs/libxprs*   || true
    codesign --display --verify --verbose -d $HOME/.orlibs/libxprl*   || true
    if [[ "$(uname -m)" == "x86_64" ]]; then
        codesign --remove-signature $HOME/.orlibs/libcplex*            || true
        codesign --remove-signature $HOME/.orlibs/libgurobi*           || true
    else true; fi
else true; fi

conda remove --quiet --yes --prefix $HOME/.orlibs/pycpx --all && \
conda remove --quiet --yes --prefix $HOME/.orlibs/pygrb --all && \
conda remove --quiet --yes --prefix $HOME/.orlibs/pyxpr --all && \
conda remove --quiet --yes --prefix $HOME/.orlibs/pypip --all && \
conda clean --all --yes && \
rm -r $HOME/.orlibs/pkgsx/ && \
find $HOME/.orlibs/
# FIX: libxprl.$SYSEXT.x9.8

julia --eval "using InteractiveUtils; versioninfo(); @ccall jl_dump_host_cpu()::Cvoid" && \
julia --threads auto --eval "import Pkg; Pkg.add(\"MathOptInterface\")"

CPLEX_STUDIO_BINARIES=$HOME/.orlibs/ julia --eval "import Pkg; Pkg.add(\"CPLEX\"); Pkg.build(\"CPLEX\")" && \
GUROBI_HOME=$HOME/.orlibs/ GUROBI_JL_USE_GUROBI_JLL="false" julia --eval "import Pkg; Pkg.add(\"Gurobi\"); Pkg.build(\"Gurobi\")" && \
XPRESSDIR=$HOME/.orlibs/ julia --eval "import Pkg; Pkg.add(\"Xpress\"); Pkg.build(\"Xpress\")"

julia --eval "import CPLEX; @show CPLEX.libcplex; @show CPLEX._get_version_number(); CPLEX.Optimizer()" && \
julia --eval "import Gurobi; @show Gurobi.libgurobi; @show Gurobi.GRB_VERSION_MAJOR, Gurobi.GRB_VERSION_MINOR, Gurobi.GRB_VERSION_TECHNICAL" && \
julia --eval "import Xpress; @show Xpress.libxprs; @show Xpress.get_version(); Xpress.Optimizer()"
# FIX: Gurobi.Optimizer

exit 0

julia --eval "import Pkg; Pkg.test(\"CPLEX\")"  && \
julia --eval "import Pkg; Pkg.test(\"Gurobi\")" && \
julia --eval "import Pkg; Pkg.test(\"Xpress\")"

exit 0
