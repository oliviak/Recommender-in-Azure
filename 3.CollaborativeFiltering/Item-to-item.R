# Contents of optional Zip port are in ./src/
# source("src/yourfile.R");
# load("src/yourData.rdata");
# ItemsBasket=read.csv ("src/ItemsBasket.csv")
dataset1 <- read.csv("")
ItemsBasket = read.csv("ItemsBasket.csv")
library (arules)
library(arulesViz)

print("Description of the tractions")
tr <-read.transactions("ItemsBasket.csv", format="basket", sep = "," )
tr
summary(tr)
itemFrequencyPlot(tr, topN=20, type="absolute")

rules <- apriori(tr, parameter = list(supp = 0.001, conf = 0.8))
rules <- sort(rules, by="confidence", decreasing=TRUE)
inspect(rules)

InputClient<-as.vector(t(InputClient))
rulesMatchLHS <- subset(rules,subset=lhs %ain% InputClient)
OutputClient =data.frame(  lhs = labels(lhs(rulesMatchLHS))$elements,
                           rhs = labels(rhs(rulesMatchLHS))$elements,
                           rulesMatchLHS@quality)

# You'll see this output in the R Device port.
# It'll have your stdout, stderr and PNG graphics device(s).

# Select data.frame to be sent to the output Dataset port
# maml.mapOutputPort("OutputClient");