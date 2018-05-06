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


Summary and graph files with "virtual" in their names have an extra false node,
with edges going out of it towards all other nodes, which we named "VOIDCURRENCY".
It is necessary to use these in the Bellman-Ford version (and disallowed in others).
Using this extra node as source assures we're able to reach cycles starting
from any other node, and because the edges leaving this source have 0 weight, no new
negative cycles are introduced (i.e. the original graph topology is unperturbed).


We've yet to implement automation of the scraping/file-build process. A current
example use case would be (Bellman-Ford application):
```
source("bf-arbitrate.r")
market.graph = read.table("graph_btx_virtual_30-04.txt")
market.summary = read.table("summary_btx_virtual_30-04.txt")
ret1 = bf.find(market.graph, market.summary)
```
Or, equivalently, for the Floyd-Warshall application:
```
source("fw-arbitrate.r")
market.graph = read.table("graph_btx_real_30-04.txt")
market.summary = read.table("summary_btx_real_30-04.txt")
ret2 = fw.find(market.graph, market.summary)
```