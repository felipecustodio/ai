library(tm)
library(SnowballC)

doc1 <- "Mia Thermopolis has just found out that she is the heir apparent to the throne of Genovia. With her friends Lilly and Michael Moscovitz in tow, she tries to navigate through the rest of her sixteenth year."
doc2 <- "Danny Ocean and his eleven accomplices plan to rob three Las Vegas casinos simultaneously."
doc3 <- "A Lion cub crown prince is tricked by a treacherous uncle into thinking he caused his fathers death and flees into exile in despair, only to learn in adulthood his identity and his responsibilities."
doc4 <- "When his secret bride is executed for assaulting an English soldier who tried to rape her, Sir William Wallace begins a revolt against King Edward I of England."
doc5 <- "The aliens are coming and their goal is to invade and destroy Earth. Fighting superior technology, mankinds best weapon is the will to survive."
doc6 <- "The cross-country adventures of two good-hearted but incredibly stupid friends."

query <- "my alien stupid friends"

docList <- list(doc1, doc2, doc3, doc4, doc5, doc6)
nDocs <- length(docList)
names(docList) <- paste0("doc", c(1:nDocs))

# A vector source interprets each element of the vector x as a document.
docs <- VectorSource(c(docList, query))
docs$Names <- c(names(docList), "query")

# Corpora are collections of documents containing (natural language) text.
corpus <- Corpus(docs)
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation,preserve_intra_word_dashes = TRUE)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, stripWhitespace)

tdm <- TermDocumentMatrix(corpus)
inspect(tdm)
m <- as.matrix(tdm)

computeTFIDF <- function(row) {
        df = sum(row[1:nDocs] > 0)
        w = rep(0, length(row))
        w[row > 0] = (1 + log2(row[row > 0])) * log2(nDocs/df)
    return(w)
}

n <- t(apply(m, 1, FUN=computeTFIDF))
colnames(n) <- colnames(m)

# # Vetor de normas
escala <- sqrt(colSums(n^2))

# Função scale aplicada na matriz
n <- scale(n, center=FALSE, scale=escala)

# Ranqueamento via produto escalar (assumindo vetores já normalizados)
query <- n[, nDocs+1]
n <- n[, 1:nDocs]

scores <- t(query) %*% n

results <- data.frame(doc = names(docList), score = t(scores))
results <- results[order(results$score, decreasing = TRUE),]

print(results)
