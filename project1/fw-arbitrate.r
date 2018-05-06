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
    path = c(path, target)

    # as vector
    return(path)
}

fw.find <- function(graph, summary) {

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

    # apply floyd-warshall
    for (k in 1:NROW(nodes)) {
        cat("  doing all paths passing through", k, "\n")

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
    for (i in 1:NROW(nodes)) {

        if (dists[i, i] < 0) {
            # cycle path
            cat("the following arbitrage is possible:\n")
            cycle = fw.path(nexts, i, i)
            print(nodes[cycle])

            # cycle mult
            rates = as.numeric(as.character(summary[,3]))
            profit = fw.mult(nodes, edges, rates, cycle)
            cat("possible profit:", profit, "\n")

            break
        }
    }

    if (NROW(cycle) == 0) {
        cat("no arbitrage opportunity detected :(\n")
    }

    ret = list()
    ret$nodes = nodes
    ret$dists = dists
    ret$cycle = cycle
    ret$profit = profit

    return(ret)
}