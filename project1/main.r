#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=T)

# TODO TEST

# ARGS
if (length(args) != 3) {
    stop("Usage is: program <input-file> <output-file> <algorithm>\n
         \twhere algoritm is either 1, 2 or 3:\n
         \t1: Floyd-Warshall\n
         \t2: Classic Bellman-Ford\n
         \t3: Bellman-Ford with SPFA (with SLF) optimizations\n", call.=F)
}

# SCRIPTS
source("fw-arbitrate.r")
source("bf-arbitrate.r")

# READ INPUT
input.edges = as.matrix(read.table(args[1]))
input.nodes = unique(matrix(input.edges[,1:2], ncol=1))

out.nodes = paste0(args[2], ".nodes")
out.cycle = paste0(args[2], ".cycle")
out.summary = paste0(args[2], ".summary")

# ADAPT WEIGHTS
weights.new = -log(as.numeric(as.character(input.edges[,3])))
weights.new[which(weights.new==-Inf)] = 0 # cleaning -logs
input.edges.new = cbind(input.edges[,1:2], weights.new)

# store return
ret = NULL

if (args[3] == "fw") {

    # RUN
    ret = fw.find(input.edges.new, input.edges)

} else if (args[3] == "bf") {

    # ADD DUMMY NODE
    voids = cbind(rep("VOIDCURRENCY", NROW(input.nodes)),
                  input.nodes, rep(0, NROW(input.nodes)))
    input.edges = rbind(voids, as.matrix(input.edges))
    input.edges.new = rbind(voids, input.edges.new)

    # RUN
    ret = bf.find(input.edges.new, input.edges)

} else if (args[3] == "spfa") {

    # ADD DUMMY NODE
    voids = cbind(rep("VOIDCURRENCY", NROW(input.nodes)),
                  input.nodes, rep(0, NROW(input.nodes)))
    input.edges = rbind(voids, as.matrix(input.edges))
    input.edges.new = rbind(voids, input.edges.new)

    # RUN
    ret = bf.spfa(input.edges.new, input.edges)

} else {

    stop("No such algorithm implemented\n", call.=F)
}

# WRITE
cycle = cbind(ret$cycle[1:(NROW(ret$cycle)-1)], ret$cycle[2:NROW(ret$cycle)])
write.table(ret$nodes, out.nodes, row.names=F, col.names=F, sep="\t", quote=F)
write.table(cycle, out.cycle, row.names=F, col.names=F, sep="\t", quote=F)

line = paste0("Starting from 1 unit of ", cycle[1,1], ", performing these transactions
(or, in stock terms, SELLING or BIDDING these PAIRS) can
possibly grant you ", ret$profit, " ", cycle[1,1], ":\n")

write(line, out.summary)
write.table(cycle, out.summary, row.names=F, col.names=F, sep="/", quote=F, append=T)
