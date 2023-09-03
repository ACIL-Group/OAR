"""
    dv.jl

# Description
Dual-vigilance definitions.
"""

"""
[`START`](@ref) options struct as a `Parameters.jl` `@with_kw` object.
"""
@with_kw mutable struct opts_DVSTART @deftype Float
    """
    Lower-bound vigilance parameter: rho_lb ∈ [0, 1].
    """
    rho_lb = 0.55;
    # @assert rho_lb >= 0.0 && rho_lb <= 1.0

    """
    Upper bound vigilance parameter: rho_ub ∈ [0, 1].
    """
    rho_ub = 0.75; @assert rho_lb <= rho_ub
    # @assert rho_ub >= 0.0 && rho_ub <= 1.0 && rho_ub > rho_lb

    """
    Choice parameter: alpha > 0.
    """
    alpha = 1e-3; @assert alpha > 0.0

    """
    Learning parameter: beta ∈ (0, 1].
    """
    beta = 1.0; @assert beta > 0.0 && beta <= 1.0

    """
    Maximum number of epochs during training.
    """
    epochs::Int = 1

    """
    Flag for generating nodes at the terminal distributions below their nonterminal positions.
    """
    terminated::Bool = false
end

"""
Trains [`OAR.START`](@ref) module on a [`OAR.SomeStatement`](@ref) from the [`OAR.START`](@ref)'s grammar.

# Arguments
- `art::START`: the [`OAR.START`](@ref) to update with the [`OAR.SomeStatement`](@ref).
- `statement::SomeStatement`: the grammar [`OAR.SomeStatement`](@ref) to process.
- `y::Integer=0`: optional supervised label as an integer.
"""
function train_dv!(
    art::START,
    statement::SomeStatement;
    y::Integer=0,
)
    # Flag for if the sample is supervised
    supervised = !iszero(y)

    # If this is the first sample, then fast commit
    if isempty(art.protonodes)
        y_hat = supervised ? y : 1
        create_category!(art, statement, y_hat)
        # add_node!(art)
        # learn!(art, statement, 1)
        return y_hat
    end

    # If the label is new, break to make a new category
    if supervised && !(y in art.labels)
        create_category!(art, statement, y)
        return y
    end

    # Compute the activations
    # n_nodes = length(art.protonodes)
    # activations = zeros(n_nodes)
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    # for ix = 1:n_nodes
    for ix = 1:art.stats["n_categories"]
        # activations[ix] = activation(art.protonodes[ix], statement)
        art.T[ix] = activation(art.protonodes[ix], statement)
        art.M[ix] = match(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    # index = sortperm(activations, rev=true)
    index = sortperm(art.T, rev=true)
    mismatch_flag = true
    # for jx = 1:n_nodes
    for jx = 1:art.stats["n_categories"]
        # Get the best-matching unit
        bmu = index[jx]
        # If supervised and the label differed, force mismatch
        if supervised && (art.labels[bmu] != y)
            break
        end
        # if activations[bmu] >= art.opts.rho
        # Vigilance test upper bound
        # if activations[bmu] >= art.opts.rho_ub
        if art.T[bmu] >= art.opts.rho_ub
            y_hat = art.labels[bmu]
            learn!(art, statement, bmu)
            art.stats["n_instance"][bmu] += 1
            mismatch_flag = false
            break
        # elseif activations[bmu] >= art.opts.rho_lb
        elseif art.T[bmu] >= art.opts.rho_lb
            # Update sample labels
            y_hat = supervised ? y : art.labels[bmu]
            # Create a new category in the same cluster
            create_category!(art, statement, y_hat, new_cluster=false)
        end
    end

    # If we triggered a mismatch, add a node
    if mismatch_flag
        # bmu = n_nodes + 1
        y_hat = supervised ? y : art.stats["n_categories"] + 1
        create_category!(art, statement, y_hat)
        # learn!(art, statement, bmu)
    end

    # Return the training label
    return y_hat
end


"""
Classifies the [`OAR.Statement`](@ref) into one of [`OAR.START`](@ref)'s internal categories.

# Arguments
- `art::START`: the [`OAR.START`](@ref) to use in classification/inference.
- `statement::Statement`: the [`OAR.Statement`](@ref) to classify.
- `get_bmu::Bool=false`: optional, whether to get the best matching unit in the case of complete mismatch.
"""
function classify_dv(
    art::START,
    statement::Statement ;
    get_bmu::Bool=false,
)
    # Compute the activations
    # n_nodes = length(art.protonodes)
    # activations = zeros(n_nodes)
    # for ix = 1:n_nodes
    accommodate_vector!(art.T, art.stats["n_categories"])
    accommodate_vector!(art.M, art.stats["n_categories"])
    for ix = 1:art.stats["n_categories"]
        # activations[ix] = activation(art.protonodes[ix], statement)
        art.T[ix] = activation(art.protonodes[ix], statement)
        art.M[ix] = match(art.protonodes[ix], statement)
    end

    # Sort by highest activation
    index = sortperm(art.T, rev=true)

    # Default is mismatch
    mismatch_flag = true
    y_hat = -1
    # for jx in 1:n_nodes
    for jx in 1:art.stats["n_categories"]
        bmu = index[jx]
        # Vigilance check - pass
        # if activations[bmu] >= art.opts.rho
        if art.T[bmu] >= art.opts.rho_ub
            # Current winner
            # y_hat = bmu
            y_hat = art.labels[bmu]
            mismatch_flag = false
            break
        end
    end

    # If we did not find a match
    if mismatch_flag
        # Report either the best matching unit or the mismatch label -1
        bmu = index[1]
        # y_hat = get_bmu ? bmu : -1
        y_hat = get_bmu ? art.labels[bmu] : -1
    end

    return y_hat
end
