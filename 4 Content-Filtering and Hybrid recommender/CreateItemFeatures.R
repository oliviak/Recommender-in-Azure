itemFeatures <- maml.mapInputPort(1)
itemFeatures$Property <- 1
OutputClient =data.frame( itemFeatures$Model, itemFeatures$Property )
maml.mapOutputPort("OutputClient");