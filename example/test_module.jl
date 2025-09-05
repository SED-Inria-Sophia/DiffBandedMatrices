using LinearAlgebra
using BandedMatrices
using Pkg
Pkg.activate(".")
Pkg.add(url="git@github.com:SED-Inria-Sophia/DiffBandedMatrices.git") # , rev="v0.1.0")
using DiffBandedMatricesModule

using Random
rng = MersenneTwister(1234)

n = 5
# parent quelconque pour la démo (dans ton cas: une BandedMatrix{T})

parent = BandedMatrix(
   -1 => rand( rng,  -5:5, n-1 ),  # sous-diagonale
    0 => rand( rng, -5:5, n   ),  # diagonale
   +1 => rand( rng, -5:5, n-1 ),  # sur
)
display(parent)
# Modifs demandées sous forme (i,j,newval)
new_mods  = Dict( CartesianIndex(1, 2) => [2, 3], CartesianIndex(2,2) => [1, 5] )
# mods_ko = [(1,2, 9.0), (4,1, -2.0)] # Modification hors-bande (4,1) -> erreur quand on appelle apply!
# mods_ok = [(1,2, 9.0), (3,3, 4.0)] # Modification dans la bande
# display(parent)
A = DiffBandedMatrices(parent, new_mods)

display(value(A,2))

value(A,1)
value(A,1)[1,2]          # -> 9.0 (écrase parent[1,2])
value(A,2)[2,1]          # -> 2.0 (hérité du parent)
display(Matrix(value(A,1)))       # fallback dense générique -> même chose que materialize_dense(A)

for i in 0:2
   println("******* i=$i: ********")
   display(Matrix(value(A,0)))
   
   y = value(A,i) * ones(n)
   println(typeof(y))
   println("A[$i] * ones = $y")
end



# apply(A,k,v) # calcule A*v avec les modifications d'indice k
