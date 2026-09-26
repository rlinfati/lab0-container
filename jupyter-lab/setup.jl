import Pkg

pkgall = ["IJulia"]
push!(pkgall, "Plots")
push!(pkgall, "JuMP", "GLPK", "HiGHS")
push!(pkgall, "DataFrames", "Distributions", "CSV", "JSON", "XLSX")
push!(pkgall, "LightOSM")
push!(pkgall, "JuliaFormatter")
push!(pkgall, "BenchmarkTools")

Sys.islinux() && Sys.ARCH == :x86_64  && push!(pkgall, "MKL")
Sys.isapple()                         && push!(pkgall, "AppleAccelerate")
Sys.isapple() && Sys.ARCH == :aarch64 && push!(pkgall, "Metal")

Pkg.add(pkgall; preserve=Pkg.PRESERVE_TIERED_INSTALLED)
Pkg.precompile(strict = true)
