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
        cat("possible profit:", profit, "\n")
    } else {
        cat("no arbitrage opportunity detected :(\n")
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

    # worst case iter count
    max_iters = NROW(nodes) - 1

    # distance from source is zero
    # source is always the artificial node
    dists[1] = 0

    # Q behaves as a FIFO queue
    # ...also, add source to it
    Q = c(1)

    while (NROW(Q) > 0) {

        # get front
        node = Q[1]
        Q = Q[-which(Q==node)]

        cat("  inspecting node:", node, "\n")

        # neighbor node edge ids
        edge.ids = which(edges[,1]==nodes[node])

        for (i in 1:NROW(edge.ids)) {

            # distance inbetween
            distance = weights[edge.ids[i]]

            # neighbor node number
            neighbor = which(nodes==edges[edge.ids[i], 2])

            if (dists[node] + distance < dists[neighbor]) {
                dists[neighbor] = dists[node] + distance
                prevs[neighbor] = node

                # add to queue (only once)
                if (sum(Q==neighbor) == 0) {
                    Q = c(Q, neighbor)
                }
            }

        }

        # necessary for worst case
        max_iters = max_iters - 1
        if (max_iters == 0) {
            break
        }
    }

    # find negative cycle
    cycle = NULL
    profit = NULL
    for (i in 1:NROW(edges)) {

        u = which(nodes==edges[i, 1]) # node
        v = which(nodes==edges[i, 2]) # neighbor

        # only possible in the presence of negatie cycles
        if (dists[u] + weights[i] < dists[v]) {

            # cycle path
            cat("the following arbitrage is possible:\n")
            cycle = bf.path(nodes, prevs, edges[i,1])
            print(cycle)

            # cycle mult
            rates = as.numeric(as.character(summary[,3]))
            profit = bf.mult(edges, rates, cycle)
            cat("possible profit:", profit, "\n")

            break
        }
    }

    # case of "failure"
    if (NROW(cycle) == 0) {
        cat("no arbitrage opportunity detected :(")
    }

    ret = list()
    ret$nodes = nodes
    ret$dists = dists
    ret$prevs = prevs
    ret$cycle = cycle
    ret$profit = profit

    return(ret)
}
