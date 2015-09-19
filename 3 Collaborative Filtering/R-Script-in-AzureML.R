# Map 1-based optional input ports to variables
dataset1 <- maml.mapInputPort(1) # class: data.frame

ItemsBasket = read.csv("src/ItemsBasket.csv")
library (arules)
library(arulesViz)

tr <-read.transactions("src/ItemsBasket.csv", format="basket", sep = "," )

rules <- apriori(tr, parameter = list(supp = 0.001, conf = 0.8))
rules <- sort(rules, by="confidence", decreasing=TRUE)

dataset1 <- as.vector(t(dataset1))
rulesMatchLHS <- subset(rules,lhs %ain% dataset1)
OutputClient =data.frame(  lhs = labels(lhs(rulesMatchLHS))$elements,
                           rhs = labels(rhs(rulesMatchLHS))$elements,
                           rulesMatchLHS@quality)

# Select data.frame to be sent to the output Dataset port
maml.mapOutputPort("OutputClient");