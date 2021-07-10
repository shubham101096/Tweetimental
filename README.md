# Tweetimental
An iOS app to tell us about the current sentiment of a keyword on Twitter. 
1. I have used the dataset from Kaggle website (https://www.kaggle.com/crowdflower/twitter-airline-sentiment) to train my model using CreateML. 
2. The I imported the ml model into my Xcode project.
3. The user types a keyword for which he wants to know the current sentiment. The latest tweets containing that keyword are fetched from Twitter using its API. 
4. Then all the tweets are classified into 3 categories: positive, negative and neutral using CoreML. Based on the number of tweets in each category, an emoji is displayed to the user.


Screenshots from the app:

![](https://github.com/shubham101096/Tweetimental/blob/master/screenshots/IMG_0037.jpg)

![](https://github.com/shubham101096/Tweetimental/blob/master/screenshots/IMG_0038.jpg)

![](https://github.com/shubham101096/Tweetimental/blob/master/screenshots/IMG_0039.jpg)

![](https://github.com/shubham101096/Tweetimental/blob/master/screenshots/IMG_0040.jpg)
