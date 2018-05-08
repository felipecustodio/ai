# MULTIPLY transaction rates in a given cycle to obtain possible profit
fw.mult <- function(nodes, edges, rates, cycle) {

    profit = 1

    # find and multiply by pairs
    for (i in 1:(NROW(cycle)-1)) {
        next_value = rates[which(edges[,1]==nodes[cycle[i]] & edges[,2]==nodes[cycle[i+1]])]
        profit = profit * as.numeric(next_value)
    }

    # as number
    return(profit)
}

# RETRIEVE a path given a predecessor array and a source/target pair of nodes
fw.path <- function(nexts, source, target) {

    if(!is.numeric(source) | !is.numeric(target)) {
        cat("error: fw-path: no-numerical source/target\n")
        return()
    }

    if (nexts[source][target] == -1) {
        cat("error: fw-path: no paths between source/target\n")
        return()
    }

    # track steps
    path = c(source)
    following = nexts[source]
    while (following != target) {
        path = c(path, following)
        following = nexts[following, target]
    }

    # do last step
    path = as.matrix(c(path, target))

    # as vector
    return(path)
}

# APPLY classic Floyd-Warshall Algorithm
fw.find <- function(graph, summary, debug=T) {

    # receive graph as an EDGE LIST with the following format:
    #
    #        [,1]    [,2]    [,3]
    # [1,]  node 1  node 2  weight
    # [1,]  node 1  node 3  weight
    # [1,]  node 2  node 1  weight
    #   .     .       .       .
    #   .     .       .       .
    #   .     .       .       .

    # ready data
    edges = as.matrix(graph)
    nodes = unique(matrix(edges[,1:2], ncol=1))
    weights = as.numeric(as.character(edges[,3]))

    # distances matrix
    dists = matrix(rep(Inf, NROW(nodes)**2), nrow=NROW(nodes), byrow=T)

    # path reconstruction
    nexts = matrix(rep(-1, NROW(nodes)**2), nrow=NROW(nodes), byrow=T)

    # copy existing distances
    for (i in 1:NROW(edges)) {
        u = which(nodes==edges[i, 1]) # from
        v = which(nodes==edges[i, 2]) # to
        dists[u, v] = weights[i]
        nexts[u, v] = v
    }

    # distance to itself is zero
    for (i in 1:NROW(nodes)) {
        dists[i, i] = 0
    }

    if (debug) {
        cat("Applying Floyd-Warshall algorithm\n")
    }

    for (k in 1:NROW(nodes)) {

        if (debug) {
            cat("  computing all paths passing through node", k, "\n")
        }

        for (i in 1:NROW(nodes)) {
            for (j in 1:NROW(nodes)) {
                if (dists[i, k] + dists[k, j] < dists[i, j]) {
                    dists[i, j] = dists[i, k] + dists[k, j]
                    nexts[i, j] = nexts[i, k]
                }
            }
        }
    }

    # check for cycles
    cycle = NULL
    profit = NULL
    for (i in 1:NROW(nodes)) {

        if (dists[i, i] < 0) {
            # cycle path
            cycle = fw.path(nexts, i, i)

            # cycle mult
            rates = as.numeric(as.character(summary[,3]))
            profit = fw.mult(nodes, edges, rates, cycle)

            if (debug) {
                cat("Arbitrage cycle found!\n")
                print(nodes[cycle])
                cat("Possible profit:", profit, "\n")
            }

            break
        }
    }

    if (NROW(cycle) == 0) {
        if (debug) {
            cat("No negative cycles found :(\n")
        }
    }

    ret = list()
    ret$nodes = nodes
    ret$cycle = cycle
    ret$profit = profit

    return(ret)
}
