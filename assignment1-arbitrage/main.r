#!/usr/bin/env Rscript
options(warn=-1)

# CLI args
library("optparse")

# Set opts
opt.list = list(
make_option(c("-i", "--input"), type="character", default=NULL,
            help="input dataset file name", metavar="character"),
make_option(c("-o", "--output"), type="character", default="output",
            help="output file set base name [default = %default]", metavar="character"),
make_option(c("-a", "--algorithm"), type="character", default="bf",
            help="search algorithm to be used [fw | bf | spfa]", metavar="character"),
make_option(c("-b", "--benchmark"), type="logical", action="store_true", default=FALSE,
            help="benchmark all algorithms and show metrics (makes -a irrelevant)")
)

# Parse opts
opt.parser = OptionParser(option_list=opt.list)
opt = parse_args(opt.parser)

# Treat errors
if (is.null(opt$input)) {
    print_help(opt.parser)
    stop("Input dataset file must be specified\n", call.=F)
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

# IF BENCHMARKING, measure all algorithms
if (opt$benchmark) {
    cat("\nRunning benchmark for all algorithms...\n")
    lines = c()
    nruns = 15

    # Message
    line = "Benchmarking Floyd-Warshall\n"
    lines = c(lines, line)
    cat("\n ", line)

    # Run FW
    times.fw = c()
    for (i in 1:nruns) {
        start = Sys.time()
        ret = fw.find(input.edges.new, input.edges, debug=F)
        time = Sys.time() - start

        # Record
        times.fw = c(times.fw, time)
        line = paste0("    Execution ", as.character(i), ": ", as.character(time), " seconds\n")
        lines = c(lines, line)
        cat(line)
    }

    ## Include the dummy node every possible
    ## negative cycle is made reachable from
    ## it (For the Bellman-Ford based algorithms)
    voids = cbind(rep("VOIDCURRENCY", NROW(input.nodes)),
                  input.nodes, rep(0, NROW(input.nodes)))
    input.edges = rbind(voids, as.matrix(input.edges))
    input.edges.new = rbind(voids, input.edges.new)

    # Message
    line = "Benchmarking Bellman-Ford\n"
    lines = c(lines, line)
    cat("\n ", line)

    # Run BF
    times.bf = c()
    for (i in 1:nruns) {
        start = Sys.time()
        ret = bf.find(input.edges.new, input.edges, debug=F)
        time = Sys.time() - start

        # Record
        times.bf = c(times.bf, time)
        line = paste0("    Execution ", as.character(i), ": ", as.character(time), " seconds\n")
        lines = c(lines, line)
        cat(line)
    }

    # Message
    line = "Benchmarking SPFA\n"
    lines = c(lines, line)
    cat("\n ", line)

    # Run SPFA
    times.spfa = c()
    for (i in 1:nruns) {
        start = Sys.time()
        ret = bf.spfa(input.edges.new, input.edges, debug=F)
        time = Sys.time() - start

        # Record
        times.spfa = c(times.spfa, time)
        line = paste0("    Execution ", as.character(i), ": ", as.character(time), " seconds\n")
        lines = c(lines, line)
        cat(line)
    }

    times.fw = as.numeric(times.fw)
    times.bf = as.numeric(times.bf)
    times.spfa = as.numeric(times.spfa)
    means = as.numeric(c(mean(times.fw), mean(times.bf), mean(times.spfa)))
    sdevs = as.numeric(c(sd(times.fw), sd(times.bf), sd(times.spfa)))

    # Prepare output
    out.summary = paste0(opt$output, ".summary")
    out.plot = paste0(opt$output, ".plot.png")

    # Output summary
    lines = c(lines, "\nAverage times and standard deviations:\n")
    timedata = as.matrix(cbind(means, sdevs))
    colnames(timedata) = c("Mean", "SD")
    rownames(timedata) = c("Floyd-Warshall", "Bellman-Ford", "SPFA")
    write(lines, out.summary)
    capture.output(print(timedata), file=out.summary, append=T)

    # Prepare plot
    png(out.plot)
    xaxis = 1:NROW(means)
    plot(xaxis, means, xlim=range(c(0, NROW(means) + 1)),
         ylim=range(c(means-sdevs, means+sdevs)), pch=20,
         xlab="Measures for FW, BF and SPFA respectively",
         ylab="Mean of 15 runs +/- SD in seconds",
         main="Algorithm performance measures")

    # Hachy arrows
    arrows(xaxis, means-sdevs, xaxis, means+sdevs, length=0.05, angle=90, code=3)
    text(x=xaxis, y=means, labels=c("Floyd-Warshall", "Bellman-Ford", "SPFA"), pos=4)
    dev.off()

    # OTHERWISE, run method specified via --algorithm
    cat("\n-> Execution summmary written to", out.summary, "\n")
    cat("-> Plot image written to", out.plot, "\n\n")
    browseURL(out.plot)
} else {

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

    # Ready output file names
    out.nodes = paste0(opt$output, ".nodes")
    out.cycle = paste0(opt$output, ".cycle")
    out.summary = paste0(opt$output, ".summary")

    # Write out everything
    cycle = cbind(ret$cycle[1:(NROW(ret$cycle)-1)], ret$cycle[2:NROW(ret$cycle)])
    write.table(ret$nodes, out.nodes, row.names=F, col.names=F, sep="\t", quote=F)
    write.table(cycle, out.cycle, row.names=F, col.names=F, sep="\t", quote=F)

    # This is ugly, sorry
    write(paste0("Starting from 1 unit of ", cycle[1,1], ", performing these transactions\n(or, in stock terms, SELLING or BIDDING these PAIRS) can\npossibly grant you back", ret$profit, " ", cycle[1,1], ":\n"), out.summary)
    write.table(cycle, out.summary, row.names=F, col.names=F, sep="/", quote=F, append=T)

    # Final messages
    cat("\n-> Graph nodes written to", out.nodes, "\n")
    cat("-> Negative cycle edges written to", out.cycle, "\n")
    cat("-> Execution summmary written to", out.summary, "\n\n")
}

# Reset warnings
options(warn=-1)
