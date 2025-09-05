using BandedMatrices
include(joinpath(@__DIR__, "src", "DiffBandedMatricesModule.jl"))
using .DiffBandedMatricesModule

n=10
my_banded_matrix = BandedMatrix(
   -1 => rand( -5:5, n-1 ),  # sous-diagonale
    0 => rand( -5:5, n   ),  # diagonale
   +1 => rand( -5:5, n-1 ),  # sur
)
println(my_banded_matrix)

my_diff_banded_matrix = DiffBandedMatrices(my_banded_matrix, 
 Dict( CartesianIndex(1, 2) => [2, 4], CartesianIndex(2,2) => [3, 5] )
)
println(my_diff_banded_matrix)
display(my_diff_banded_matrix)
