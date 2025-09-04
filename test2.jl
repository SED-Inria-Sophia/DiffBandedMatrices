using LinearAlgebra
using BandedMatrices
include(joinpath(@__DIR__, "src", "DiffBandedMatrices.jl"))

n = 5
# parent quelconque pour la démo (dans ton cas: une BandedMatrix{T})
parent = BandedMatrix(rand( n, n), (1,1))

# Modifs demandées sous forme (i,j,newval)
new_mods  = Dict( CartesianIndex(1, 2) => [2.0, 3.0], CartesianIndex(2,2) => [2.5, 3.5] )
# mods_ko = [(1,2, 9.0), (4,1, -2.0)] # Modification hors-bande (4,1) -> erreur quand on appelle apply!
# mods_ok = [(1,2, 9.0), (3,3, 4.0)] # Modification dans la bande
# display(parent)
A = DiffBandedMatrices(parent, new_mods)
# apply!(A)  # -> erreur (4,1) hors-bande
# A = DiffBandedMatrix(parent, mods_ok)   
# apply!(A)  # OK

display(get(A,2))

get(A,1)
get(A,1)[1,2]          # -> 9.0 (écrase parent[1,2])
# get(A,2)[2,1]          # -> 2.0 (hérité du parent)
# display(Matrix(A))       # fallback dense générique -> même chose que materialize_dense(A)
# y = get(A,1) * ones(n) # produit rapide : parent*1 + corrections des deltas



# apply(A,k,v) # calcule A*v avec les modifications d'indice k
