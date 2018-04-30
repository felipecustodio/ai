# ai
:thought_balloon: Studies on artificial intelligence

## Project 1
Market arbitrage detection using search algorithms. Input graphs are
read as edge lists. A "summary" file should be structured just like
an edge list, with actual market rates as edge weights. A "graph" file
is pretty much the same, but with weights written as -log(OriginalWeight).


The prototype follows the solution idea to problem 7.1 proposed in:
https://courses.csail.mit.edu/6.046/spring04/handouts/ps7sol.pdf


Additionally, the sample file rates are real and obtained from bittrex' open
API. The following call will provide full market summaries:
https://bittrex.com/api/v1.1/public/getmarketsummaries


We've yet to implement automation of the scraping/file-build process. A current
example use case would be:
```
source("bf-arbitrate.r")
market.graph = read.table("graph_btx_30-04.txt")
market.summary = read.table("summary_btx_30-04.txt")
ret = bf.find(masket.graph, market.summary)
```
