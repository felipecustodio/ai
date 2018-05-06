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

    # always start at artificial node
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
    negative.cycle = NULL
    for (i in 1:NROW(edges)) {

        # a path with NROW(nodes) steps can only occur via a negative cycle
        if (dists[which(nodes==edges[i,1])] + weights[i] < dists[which(nodes==edges[i,2])]) {
            cat("found negative cycle containing edge (", edges[i,1], ", ", edges[i,2], "):\n")
            negative.cycle = bf.path(nodes, prevs, edges[i,1])
            print(negative.cycle)
            break
        }
    }

    # then find possible profit
    possible.profit = NULL
    if (NROW(negative.cycle) > 0) {
        cat("possible profit from arbitrage: \n")
        rates = as.numeric(as.character(summary[,3]))
        possible.profit = bf.mult(edges, rates, negative.cycle)
        print(possible.profit)
    } else {
        cat("no negative cycles found")
    }

    ret = list()
    ret$nodes = nodes
    ret$dists = dists
    ret$prevs = prevs
    ret$cycle = negative.cycle
    ret$profit = possible.profit
    return(ret)
}