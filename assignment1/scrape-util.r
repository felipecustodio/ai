scrape.btx <- function() {

    # fail if not installed
    library("jsonlite")

    # scrape raw data
    rawdata = readLines("https://bittrex.com/api/v1.1/public/getmarketsummaries")
    edges = jsonlite::fromJSON(rawdata)
    print("requests done")

    # parsed edge data
    market.names = edges$result$MarketName
    pairs = apply(as.matrix(market.names), 1, function(row) {
        # original data is a nested list
        strsplit(row, "-")[[1]]
    })

    # so it becomes and N by 2 matrix
    pairs = as.matrix(t(pairs))

    # bittrex returns flipped coin pairs
    reverse.pairs = cbind(pairs[,2], pairs[,1])

    bids = as.numeric(as.character(edges$result$Bid))
    asks = 1/as.numeric(as.character(edges$result$Ask))
    asks[which(asks==Inf)] = 0

    bids.pairs = cbind(reverse.pairs, bids)
    asks.pairs = cbind(pairs, asks)

    graph = rbind(asks.pairs, bids.pairs)

    # return
    return(graph)
}
