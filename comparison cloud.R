library(XML);library(tm);library(wordcloud);library(plyr)
#read the data and subset
b <- read.csv('./Final BR.csv')
b2 <- subset(b,author %in% c('Brett Gurewitz','Greg Graffin'))
b2 <- b2[c(4,5)]
b2$lyrics <- as.character(b2$lyrics)
b2$author <- factor(b2$author)

greg <- subset(b2, author =='Greg Graffin')
brett <- subset(b2, author =='Brett Gurewitz')

greg2 <- as.data.frame(paste(unlist(greg$lyrics),collapse=' '),colnames='lyrics',rownames='Greg')
brett2 <- as.data.frame(paste(unlist(brett$lyrics),collapse=' ',colnames='lyrics',rownames='Brett'))
colnames(greg2) <- 'lyrics'
colnames(brett2) <- 'lyrics'
final <- rbind(greg2,brett2)



#make a corpus out of it
ds <- DataframeSource(final)
corp <- Corpus(ds)
corp <- tm_map(corp, removePunctuation)
corp <- tm_map(corp, tolower)
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp, function(x){removeWords(x,stopwords())})
corp <- tm_map(corp, function(x){removeWords(x,c('�???~','�???o','�','???','T','�???~'))})
corp <- tm_map(corp, function(x){removeWords(x,c('lyrics','greg','brett','just','dont','like','can','cant','theres','know'))})
term.matrix <- TermDocumentMatrix(corp)
term.matrix <- as.matrix(term.matrix)
colnames(term.matrix) <- c('greg','brett')
colnames(term.matrix)
head(term.matrix)


#basic wordcloud
freqs <- sort(rowSums(term.matrix), decreasing=T)
dm <- data.frame(word=names(freqs), freq = freqs)
wordcloud(dm$word,dm$freq,random.order=F,max.words=500)



#comparison and commonality cloud
png(file="Greg v Brett.png",height=600,width=1200)
par(mfrow=c(1,2))
comparison.cloud(term.matrix,max.words=300,random.order=FALSE,colors=c("#1F497D","#C0504D"),main="Differences Between Greg and Brett's Lyrics")
commonality.cloud(term.matrix,random.order=FALSE,color="#F79646",main="Commonalities in Greg and Brett's Lyrics")
dev.off()

























i <- 0 
corp <- tm_map(corp, function(x){
  i <<- i + 1
  meta(x, 'Author') <- b2[i,2]
  x
})
DublinCore(corp[[233]])

