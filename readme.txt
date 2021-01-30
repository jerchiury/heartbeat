classification of hearbeat

Note: The data cuts the heart beat starting from the highest peak (R), so look at the start of the graph to about midway of the graph, the rest
of the graph (including the central R peak) is simply by-product of the data cleaning done by the publisher at kaggle.

the dynamic time warping time series clusteering was not put into final result
due to it taking too long (calculating distance matrix with DTW with
just 1000 rows of data takes about 10 mins).
I did try with a few hundred beats with DTW and the result is very poor (about 55% balanced accuracy) which I think is due to the nature of the 
cleaned data. The cleaned data is paddeed with 0's on regions outside of a pre-defined window of a hearbeat (1.2 times the average heart 
beat period) in order to fill the predetermined 187 samples per heart beat. The start of the padding is determined by the
previous heart beat which is not present in the beat by beat data. 

I did finish a random forest multiclass model trained and tested with down-sampled balanced data (I down-sampled class=0 from 82% of total
data to just 7% of total data, more or less the same level as other classes)

I also retrained the neural net with the same balanced data (accuracy is still about 95%)

I did try to do fourier transform but the data is so noisy and the cut-off point (start of 0 paddings) is so unpredictable that
FFT yielded no solid results. 

Shiny app is built on saved models. I saved all the models in h5 or rds format and recalled them in the app.

Shiny app at:  https://jerrychiu.shinyapps.io/project3/