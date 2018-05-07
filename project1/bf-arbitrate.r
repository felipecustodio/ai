bf.mult <- function(edges, rates, cycle) {

    profit = 1

    # find and multiply by pairs
    for (i in 1:(NROW(cycle)-1)) {
        next_value = rates[which(edges[,1]==cycle[i] & edges[,2]==cycle[i+1])]
        profit = profit * as.numeric(next_value)
    }

    # as number
    return(profit)
}

bf.path <- function(nodes, prevs, terminal) {

    path = as.matrix(c(terminal))
    prev = nodes[prevs[which(nodes==terminal)]]

    # track util repeated element
    while (sum(path==prev) == 0) {
        path = rbind(path, prev)
        prev = nodes[prevs[which(nodes==prev)]]
    }

    # add repeated element
    path = rbind(path, prev)

    # trim the fat
    trim.bound = which(path==prev)[1]
    path = path[trim.bound:NROW(path)]
    path = as.matrix(rev(path))

    # as matrix
    return(path)
}

bf.find <- function(graph, summary) {

    # receive an EDGE LIST with the following format:
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

    # ready state
    dists = rep(Inf, NROW(nodes))
    prevs = rep(NULL, NROW(nodes))

    # distance from source is zero
    # source is always the artificial node
    dists[1] = 0

    cat("relaxing weights...\n")
    for (i in 1:(NROW(nodes)-1)) { # this can STILL stop earlier
        cat(" iteration: ", i, "\n")

        for (j in 1:NROW(edges)) {

            if (dists[which(nodes==edges[j,1])] + weights[j] < dists[which(nodes==edges[j,2])]) {
                dists[which(nodes==edges[j,2])] = dists[which(nodes==edges[j,1])] + weights[j]
                prevs[which(nodes==edges[j,2])] = which(nodes==edges[j,1])
            }
        }
    }

    # test for negative cycles
    cycle = NULL
    for (i in 1:NROW(edges)) {

        # a path with NROW(nodes) steps can only occur via a negative cycle
        if (dists[which(nodes==edges[i,1])] + weights[i] < dists[which(nodes==edges[i,2])]) {
            cycle = bf.path(nodes, prevs, edges[i,1])
            cat("the following arbitrage is possible:\n")
            print(cycle)
            break
        }
    }

    # then find possible profit
    profit = NULL
    if (NROW(cycle) > 0) {
        rates = as.numeric(as.character(summary[,3]))
        profit = bf.mult(edges, rates, cycle)
        cat("profit:", profit, "\n")
    } else {
        cat("no negative cycles found")
    }

    ret = list()
    ret$nodes = nodes
    ret$dists = dists
    ret$prevs = prevs
    ret$cycle = cycle
    ret$profit = profit
    return(ret)
}

bf.spfa <- function(graph, summary) {

    # ready data
    edges = as.matrix(graph)
    nodes = unique(matrix(edges[,1:2], ncol=1))
    weights = as.numeric(as.character(edges[,3]))

    # ready state
    dists = rep(Inf, NROW(nodes))
    prevs = rep(NULL, NROW(nodes))

    # distance from source is zero
    # source is always the artificial node
    dists[1] = 0

    # add source to queue
    Q = c(1)

    while (NROW(Q) > 0) {

        # randomly retract a node the from queue
        node = as.numeric(sample(Q, NROW(Q), 1))
        Q = Q[-which(Q==node)]

        # separate it's neighbors
        neighbors.edges = edges[which(edges[1,]==nodes[node]),]
        neighbors.nodes = neighbors.edges[,2]

        for (i in 1:NROW(neighbors.nodes)) {

            # TODO HERE
            # TODO HERE
            # TODO HERE
            # TODO HERE
            # TODO HERE
        }

    }
}