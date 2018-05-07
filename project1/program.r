#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=T)

# TODO TEST

# ARGS
if (length(args) != 4) {
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
input.edges = read.table(args[1])
input.nodes = unique(matrix(input.edges[,1:2], ncol=1))

out.nodes = paste0("nodes_", args[2])
out.steps = paste0("steps_", args[2])
out.summary = paste0("summary_", args[2])

if (args[3] == 1) {
    weights = -log(as.numeric(as.character(input.edges[,3])))
    input.edges.adapted = cbind(input.edges[,1:2], weights)

    # RUN
    ret = fw.find(input.edges.adapted, input.edges)

    # READY OUTPUT
    # TODO
    # TODO
    # TODO
} else if (args[3] == 2) {
    # part1
    weights = -log(as.numeric(as.character(input.edges[,3])))
    input.edges.adapted = cbind(input.edges[,1:2], weights)

    # part2
    voids = cbind(rep("VOIDCURRENCY", NROW(input.nodes)),
                  input.nodes, rep(0, NROW(input.nodes)))

    voids = as.matrix(voids)
    input.edges = rbind(voids, input.edges)
    input.edges.adapted = rbind(voids, input.edges.adapted)

    # RUN
    ret = bf.find(input.edges.adapted, input.edges)

    # READY OUTPUT
    # TODO
    # TODO
    # TODO
} else if (args[3] == 2) {
    # part1
    weights = -log(as.numeric(as.character(input.edges[,3])))
    input.edges.adapted = cbind(input.edges[,1:2], weights)

    # part2
    voids = cbind(rep("VOIDCURRENCY", NROW(input.nodes)),
                  input.nodes, rep(0, NROW(input.nodes)))

    voids = as.matrix(voids)
    input.edges = rbind(voids, input.edges)
    input.edges.adapted = rbind(voids, input.edges.adapted)

    # RUN
    ret = bf.spfa(input.edges.adapted, input.edges)

    # READY OUTPUT
    # TODO
    # TODO
    # TODO
} else {
    stop("No such algorithm implemented\n", call.=F)
}
