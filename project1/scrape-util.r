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