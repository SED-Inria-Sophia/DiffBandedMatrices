# module DiffBand

export DiffBandedMatrix, apply!, materialize_dense

using Base: @propagate_inbounds, IndexStyle, IndexCartesian

"""
    DiffBandedMatrix(parent, edits)

Wrapper immuable d'une matrice `parent` (souvent une `BandedMatrix{T}`) et d'un
ensemble d'éditions `edits` stockées comme `Dict{CartesianIndex{2},T}`.

Questions:
- pourquoi veut-on stocker uniquement les différences ?
- quelles opérations doivent être supportées par cette structure ?
"""
struct DiffBandedMatrix{T,P<:AbstractMatrix{T}} <: AbstractMatrix{T}
    parent::P
    edits::Dict{CartesianIndex{2},T}
end

# -- Constructeurs pratiques ---------------------------------------------------

# À partir du parent seul (pas d'édition au début)
DiffBandedMatrix(parent::P) where {T,P<:AbstractMatrix{T}} =
    DiffBandedMatrix{eltype(parent),P}(parent, Dict{CartesianIndex{2},eltype(parent)}())

# À partir d'une liste de tuples (i,j,val) comme demandé
function DiffBandedMatrix(parent::P, changes::AbstractVector{<:Tuple{Int,Int,T}}) where {T,P<:AbstractMatrix{T}}
    ed = Dict{CartesianIndex{2},T}()
    @inbounds for (i,j,v) in changes
        ed[CartesianIndex(i,j)] = v
    end
    return DiffBandedMatrix{T,P}(parent, ed)
end

# -- Base Array interface ------------------------------------------------------

Base.size(A::DiffBandedMatrix) = size(A.parent)
Base.axes(A::DiffBandedMatrix) = axes(A.parent)
Base.eltype(::Type{DiffBandedMatrix{T}}) where {T} = T
IndexStyle(::Type{<:DiffBandedMatrix}) = IndexCartesian()

@propagate_inbounds function Base.getindex(A::DiffBandedMatrix{T}, i::Int, j::Int) where {T}
    get(A.edits, CartesianIndex(i,j), A.parent[i,j])
end

# (Optionnel) rendre l’overlay modifiable sans toucher le parent
function Base.setindex!(A::DiffBandedMatrix{T}, v::T, i::Int, j::Int) where {T}
    A.edits[CartesianIndex(i,j)] = v
    return v
end

# -- Matérialisation (si on veut figer le résultat) ---------------------------

"Retourne une copie dense Materialisée du résultat (parent + éditions)."
function materialize_dense(A::DiffBandedMatrix)
    M = Matrix(A.parent)             # dense
    @inbounds for (k, v) in A.edits  # appliquer les deltas
        M[k] = v
    end
    return M
end

"Applique les éditions *dans* le parent si celui-ci accepte setindex!."
function apply!(A::DiffBandedMatrix)
    @inbounds for (k, v) in A.edits
        A.parent[k] = v              # attention: échouera si hors-bande ou parent immuable
    end
    empty!(A.edits)
    return A.parent
end

# -- Accélération utile : produit matrice-vecteur ------------------------------
# Conserve la perf du produit bande, puis corrige par les modifications.

function Base.:*(A::DiffBandedMatrix{T}, x::AbstractVector{T}) where {T}
    y = A.parent * x                          # rapide via algo bande
    @inbounds for (k, v) in A.edits
        print(typeof(k)     )   
        i, j = Tuple( k )                           # indices
        y[i] += (v - A.parent[i,j]) * x[j]     # delta
    end
    return y
end

# end # module

# -- Affichage -----------------------------------------------------------------

"""
Affichage compact (utilisé par `print`/`println`).
Ex: DiffBandedMatrix{Float64}(5×5, edits=3)
"""
function Base.show(io::IO, A::DiffBandedMatrix)
    T = eltype(A)
    m, n = size(A)
    print(io, "DiffBandedMatrix{$T}($(m)×$(n), edits=$(length(A.edits)))")
end

"""
Affichage enrichi en contexte text/plain (REPL, `display`).
Montre un résumé du parent et un aperçu des éditions.
"""
function Base.show(io::IO, ::MIME"text/plain", A::DiffBandedMatrix)
    T = eltype(A)
    m, n = size(A)
    k = length(A.edits)
    println(io, "DiffBandedMatrix{$T} $(m)×$(n)")
    println(io, "  parent: ", summary(A.parent))
    if k == 0
        print(io, "  edits: ∅")
        return
    end
    print(io, "  edits ($k): ")
    shown = 0
    sep = ""
    for (idx, v) in A.edits
        i, j = idx.I
        print(io, sep, "(", i, ",", j, ")→", v)
        shown += 1
        sep = ", "
        if shown >= 8 && k > shown
            print(io, ", …")
            break
        end
    end
end
