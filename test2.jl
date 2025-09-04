using LinearAlgebra
using BandedMatrices
include(joinpath(@__DIR__, "DiffBandedMatrices.jl"))

n = 500
# parent quelconque pour la démo (dans ton cas: une BandedMatrix{T})
# parent = BandedMatrix{Float64}( -1 => [2, 4, 6], 0 => [1, 3, 5, 7], 1 => [8, 9, 10] )
parent = BandedMatrix(rand( n, n), (1,1))

# Modifs demandées sous forme (i,j,newval)
mods_ko = [(1,2, 9.0), (4,1, -2.0)] # Modification hors-bande (4,1) -> erreur quand on appelle apply!
mods_ok = [(1,2, 9.0), (3,3, 4.0)] # Modification dans la bande
# display(parent)
A = DiffBandedMatrix(parent, mods_ko)
# apply!(A)  # -> erreur (4,1) hors-bande
A = DiffBandedMatrix(parent, mods_ok)   
apply!(A)  # OK

# display(A)

A[1,2]          # -> 9.0 (écrase parent[1,2])
A[2,1]          # -> 2.0 (hérité du parent)
# display(Matrix(A))       # fallback dense générique -> même chose que materialize_dense(A)
y = A * ones(n) # produit rapide : parent*1 + corrections des deltas

apply(A,k,v) # 
