# ai
:thought_balloon: Studies on artificial intelligence

## Market arbitrage detection on cryptocurrency pairs
Market arbitrage detection using search algorithms. Market summaries are
translated to weighted, directed graphs, and then we try to exploit the
resulting topology. A "summary" file should be structured just like
a regular edge list, with actual market rates as edge weights. (In typical trading
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


### Datasets
The sample datasets  are real and obtained from bittrex' open
API. The following call will provide full market summaries:
https://bittrex.com/api/v1.1/public/getmarketsummaries


### Requirements
You should have R installed already. In case you dont, we use the Case Western
institute CRAN in our project, it's pretty reliable. You can download it from there:
https://cran.case.edu/


Also, we use a few additional packages in our project. You can install them
as a regular user (no admin rights) by running the `install-packages.r` script:
```
Rscript --vanilla install-packages.r
```


### Running examples
Calling some `--help` or just running `main.r` without arguments will display
info on how what should be passed provided:
```
Rscript main.r --help
```

Run cycle detection on `summary_btx_30-04.txt` dataset using Floyd-Warshall
Algorithm, with output files beginning with "out":
```
Rscript --vanilla main.r -i datasets/summary_btx_30-04.txt -o out -a fw
```

Run cycle detection on `summary_btx_30-04.txt` dataset using Bellman-Ford
Algorithm, with output files beginning with "out":
```
Rscript --vanilla main.r -i datasets/summary_btx_30-04.txt -o out -a bf
```

Run cycle detection on `summary_btx_30-04.txt` dataset using SPFA
Algorithm, with output files beginning with "out":
```
Rscript --vanilla main.r -i datasets/summary_btx_30-04.txt -o out -a spfa
```

Benchmark all cycle detection algorithms on `summary_btx_30-04.txt` dataset,
with output files (mean runtimes, runtimes sd, plot) beginning with "out":
```
Rscript --vanilla main.r -i datasets/summary_btx_30-04.txt --benchmark
```
