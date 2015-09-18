# Recommender-in-Azure
Accompanying material to the course [Building Recommendation Systems in Azure](https://www.microsoftvirtualacademy.com/en-us/training-courses/building-recommendation-systems-in-azure-13765) in the Microsoft Virtual Academy.

The course is built as follows:

1. **Machine Learning & Recommenders**: This module gives a short introduction in machine learning and recommendation systems. It particularly highlights the two main approaches of recommendations - collaborative and content-based filtering.
2. **Targeted Marketing**: Before digging into recommendation systems, we look into the most simple form of machine learning problems - binary classification. Classification in general could be used as a basis for recommendations, too.
3. **Collaborative Filtering: Association Rules in R & AzureML**: Here, we go through one common recommendation approach using RStudio. Then we integrate the R script into [Azure Machine Learning](http://studio.azureml.net)
4. **Content-Based Filtering & Hybrid: Matchbox Recommender**: We use the built-in machine learning algorithm in AzureML (short for Azure Machine Learning) - MatchBox recommender. In its basic form it is a rating-based/content-based recommendation approach. This can be extended to a hybrid recommender by integrating user as well as item features.
5. **Recommendations API (Azure ML Marketplace)**: What to do if I cannot be bothered to build a machine learning model but still want to give personalised recommendations? Don't despair - this is where machine learning APIs, such as the [Recommendations API](http://gallery.azureml.net/MachineLearningAPI/Recommendations-2) are provided.
