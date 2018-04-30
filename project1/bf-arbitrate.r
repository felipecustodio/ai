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
    for (i in 1:(NROW(nodes)-1)) { # EXACTLY this many iterations
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

    # then find possible cycles
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

# TODO TOTALLY REWRITE THIS
scrape.btx <- function() {

    require(jsonlite)

    # scrape nodes
    node_data.raw = readLines("https://bittrex.com/api/v1.1/public/getcurrencies")
    node_data.json = jsonlite::fromJSON(node_data.raw)

    # scrape edges
    edge_data.raw = readLines("https://bittrex.com/api/v1.1/public/getmarketsummaries")
    edge_data.json = jsonlite::fromJSON(edge_data.raw)

    print("requests done, getting data ready...")

    # nodes: indices
    nodes = node_data.json$result$Currency
    nodes = cbind(nodes, seq(1, NROW(nodes)))

    # edges: indices
    market_names = edge_data.json$result$MarketName
    parsed_names = apply(as.matrix(market_names), 1, function(row) {
                             strsplit(row, "-")[[1]] # this crap returns a nested list
})
    parsed_names = t(parsed_names) # so it becomes and N by 2 matrix
    parsed_ids = cbind(rep(0, NROW(parsed_names)), rep(0, NROW(parsed_names)))

    for (i in 1:NROW(nodes)) {
        currency = nodes[i, 1]
        currency_id = as.numeric(nodes[i, 2])
        parsed_ids[which(parsed_names==currency)] = currency_id
    }

    # edges: weights
    asks = 1/as.numeric(as.character(edge_data.json$result$Ask))
    bids = edge_data.json$result$Bid

    parsed_ids_ask = as.matrix(cbind(parsed_ids, asks))
    parsed_ids_bid = as.matrix(cbind(parsed_ids[,2], parsed_ids[,1], bids))
    edges = rbind(parsed_ids_ask, parsed_ids_bid)

    ret = list()
    ret$nodes = data.frame(nodes)
    ret$edges = data.frame(edges)

    return(ret)
}
