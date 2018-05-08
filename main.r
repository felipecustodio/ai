#!/usr/bin/env Rscript
options(warn=-1)

# CLI args
library("optparse")

# Set opts
opt.list = list(make_option(c("-i", "--input"), type="character", default=NULL,
                            help="input dataset file name", metavar="character"),
                make_option(c("-o", "--output"), type="character", default="out.txt",
                            help="output file set base name [default = %default]", metavar="character"),
                make_option(c("-a", "--algorithm"), type="character", default=NULL,
                            help="search algorithm to be used [fw | bf | spfa]", metavar="character"),
                make_option(c("-b", "--benchmark"), type="logical", action="store_true", default=FALSE,
                            help="benchmark the chosen algorithm and show metrics (suppresses debug output)")
)

# Parse opts
opt.parser = OptionParser(option_list=opt.list)
opt = parse_args(opt.parser)

# Treat errors
if (is.null(opt$input)) {
    print_help(opt.parser)
    stop("Input dataset file must be specified\n", call.=F)
}
if (is.null(opt$algorithm)) {
    print_help(opt.parser)
    stop("A search algorithm must be chosen\n", call.=F)
}

# Source scripts
source("fw-arbitrate.r")
source("bf-arbitrate.r")

# Read input data
input.edges = as.matrix(read.table(opt$input))
input.nodes = unique(matrix(input.edges[,1:2], ncol=1))

# Adapt edge weights
weights.new = -log(as.numeric(as.character(input.edges[,3])))
weights.new[which(weights.new==-Inf)] = 0 # cleaning -logs
input.edges.new = cbind(input.edges[,1:2], weights.new)

ret = NULL
if (opt$algorithm == "fw") {

    # Just run
    ret = fw.find(input.edges.new, input.edges)

} else if (opt$algorithm == "bf") {

    ## Include the dummy node every possible
    ## negative cycle is made reachable from it
    voids = cbind(rep("VOIDCURRENCY", NROW(input.nodes)),
                  input.nodes, rep(0, NROW(input.nodes)))
    input.edges = rbind(voids, as.matrix(input.edges))
    input.edges.new = rbind(voids, input.edges.new)

    # Run
    ret = bf.find(input.edges.new, input.edges)

} else if (opt$algorithm == "spfa") {

    ## Include the dummy node every possible
    ## negative cycle is made reachable from it
    voids = cbind(rep("VOIDCURRENCY", NROW(input.nodes)),
                  input.nodes, rep(0, NROW(input.nodes)))
    input.edges = rbind(voids, as.matrix(input.edges))
    input.edges.new = rbind(voids, input.edges.new)

    # Run
    ret = bf.spfa(input.edges.new, input.edges)

} else {
    stop("No such algorithm implemented\n", call.=F)
}

if (opt$benchmark) {
    cat("Must do benchmark!\n")
}

# Ready output file names
out.nodes = paste0(opt$output, ".nodes")
out.cycle = paste0(opt$output, ".cycle")
out.summary = paste0(opt$output, ".summary")

# Write out everything
cycle = cbind(ret$cycle[1:(NROW(ret$cycle)-1)], ret$cycle[2:NROW(ret$cycle)])
write.table(ret$nodes, out.nodes, row.names=F, col.names=F, sep="\t", quote=F)
write.table(cycle, out.cycle, row.names=F, col.names=F, sep="\t", quote=F)

# This is ugly, sorry
line = paste0("Starting from 1 unit of ", cycle[1,1], ", performing these transactions
(or, in stock terms, SELLING or BIDDING these PAIRS) can
possibly grant you back", ret$profit, " ", cycle[1,1], ":\n")

write(line, out.summary)
write.table(cycle, out.summary, row.names=F, col.names=F, sep="/", quote=F, append=T)

# Final messages
cat("\n-> Graph nodes written to", out.nodes, "\n")
cat("-> Negative cycle edges written to", out.cycle, "\n")
cat("-> Execution summmary written to", out.summary, "\n")

# Reset warnings
options(warn=-1)