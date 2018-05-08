# ai
:thought_balloon: Studies on artificial intelligence

### Market arbitrage detection on cryptocurrency pairs
Market arbitrage detection using search algorithms. Input graphs are
read as edge lists. A "summary" file should be structured just like
an edge list, with actual market rates as edge weights. (In typical trading
notation, the weight between each pair would be the "bid" or "sell", with the
base currency being the first of the two.)


This implementation follows the solution idea to problem 7.1 proposed in
https://courses.csail.mit.edu/6.046/spring04/handouts/ps7sol.pdf - and then we
extend it. Applying the Floyd-Warshall method shows how slow the solution could
become if we consider a regular APSP algorithm. Applying the Bellman-Ford
algorithm shows how this solution can be improved with a __single source
shortest paths__ strategy. Then, lastly, we optimize on it as proposed by
the __Shortest Paths Fast Algorithm__ method, which greatly improves the
Bellman-Ford average case performance.


The sample datasets  are real and obtained from bittrex' open
API. The following call will provide full market summaries:
https://bittrex.com/api/v1.1/public/getmarketsummaries


Necessary packages can be installed by running the `install-packages.r` script:
```
R CMD BATCH install-packages.r  # output can be checked in the generated install-packages.r.Rout
```

Calling some `--help` or just running `main.r` without arguments will display info on how what
should be passed provided:
```
Rscript main.r --help
```


Additionally, the following are example use cases for each of the algorithms
```
Rscript --vanilla main.r -i datasets/summary_btx_30-04.txt -o out.txt -a fw # Floyd-Warshall

Rscript --vanilla main.r -i datasets/summary_btx_30-04.txt -o out.txt -a bf # classic Bellman-Ford

Rscript --vanilla main.r -i datasets/summary_btx_30-04.txt -o out.txt -a spfa # SPFA with SLF improvements
```
