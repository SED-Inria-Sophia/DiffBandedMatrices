using BandedMatrices
include(joinpath(@__DIR__, "src", "DiffBandedMatrices.jl"))

my_banded_matrix = BandedMatrix(rand(5,5), (1,1))
println(my_banded_matrix)

my_diff_banded_matrix1 = DiffBandedMatrix(my_banded_matrix)
println(my_diff_banded_matrix1)
display(my_diff_banded_matrix1)

my_diff_banded_matrix2 = DiffBandedMatrix(my_banded_matrix, [ (1, 2 , 2.0), (3, 3, 4.0) ])
println(my_diff_banded_matrix2)
display(my_diff_banded_matrix2)
