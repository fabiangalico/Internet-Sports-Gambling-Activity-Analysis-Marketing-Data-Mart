# Shiny-App-Internet-Sports-Gambling-Activity-Analysis

## Project Goal

The goal of this project is to explore an online gambling website dataset for the period February - September
2005, creating an interactive shiny app to get marketing insights. Firstly, we created a basetable with one
row per customer and different metrics; for example, the sum and mean amount of money each customer bet
or how many days the customers have been active in the website and the frequency. Secondly, we created
a shiny app where the user can filter by different metrics and explore various marketing insights from the
different plots by themselves.

## Data Manipulation

**The following raw datasets were used for the project:**

* **Demographics** - Contains demographic information per user; `Country`, `Gender` and `First Active Date`. 

* **UserDailyAggregation** - Contains the actual betting information associated with each product for each participant for each calendar day. Some variables are `Betting Product` and `Stakes`.

* **PokerChipConversions** - Contains the actual poker chip transaction information, with variables like `Transaction Type` (buy or sell) and `Transaction Amount`.

* **Analytic Dataset** - Contains actual betting behavior data for both fixed-odds and live action sports book betting for each user. Some variables included in this dataset are `FOTotalStakes` and `LATotalWinnings`.

For manipulating the data, we used the haven, dplyr, tidyverse and lubridate packages. We will mention the main steps performed for the data preparation, which includes cleaning the data, create new variables and merge the tables to get a basetable that contains all the information for each customer.

**The main steps performed:**

* Import tables 'Demographics' and 'Analytic Dataset', clean them and merge them by `UserID`.

* Import 'Poker Chip Conversions' table, make some data cleaning, manipulation and create some new variables like `Prod3_TotalDays` (number of days the user has been active) and `Buy_Prod3_Max` (the maximum amount spent by the user on a single transaction). To do this, we first perform group by `UserID` and aggregate the columns.This table will be merged with other products in the end.

* Import 'UserDaylyAggregation' table. Then we filter by product ID (from 1 to 8) and store each product in a different dataframe, using a for loop and filter function.

* Create a transform function to aggregate all the data for each product ID by one observation per customer, creating aggregated variables; for example, `Prod1_mean_Stakes` (mean stakes for product one by each user) and `Prod1_TotalDaysActive` (representing length of relationship per user). The function also includes merging the different dataframes created for each product into a unique dataframe, using a left join. It also includes some data cleaning like changing data type from character to date format for date columns.

* Apply the transform function for each product ID with a for loop. Then we create the final basetable with all the aggregated tables (not only the ones for each product but also the tables created before).

* Create new columns with the Country Names, Languages and webiste used for each transaction. Discretize age into different ranges and label gender. The resulting variables are `Country_Name`, `Language_Description`, `Application_Description`, `Age_Range` and `Gender_Label`.

* Finally, we exported the basetable in SAS format and Rdata to be used after for the shiny app.

## Shiny App

The idea was to create an interactive platform so users can choose different products and then explore by selecting different variables by themselves. The basetable created above is used as the data source. 

**The overview structure of the Shiny platform:**

**Side Panel:**
The side panel is on the left and includes different filtering options. Some of the filters are interdependent, which means that by selecting a first option (for example a specific product) then other filter options are updated for that specific product. We also included a download option to extract the selected data in csv format. 

The set of filters that can be applied are the following selections:

* Product Type
* Application Type
* Country
* Gender
* Language
* Age Range

The options for select plots:

* Selection for X and Y to be plotted
* Option to select the plot scale
* Download option - allowing user to download filtered table


**Tabs:**
There are 4 different tabs that allow the user to explore different insights from the data described below:

* 2 histograms that can be plotted by selecting the variables on the sidebar panel.

* A scatterplot were the user can plot the relationship between different variables for the x and y axis for any selected product. 

* 2 bar charts were other relationships can be plotted in different ways.

* A table that contains the data for the selected product. This data can be filtered by the different variables and also can be extracted as  mentioned before.

## Insights

* **Number of users by age**

<center>
![*Number of users in Germany by Gender*](C:\Users\fgalicojustitz\Documents\GitHub\Open-Source-Group-11\Graphs\hist_age.png){ width=80% }
</center>

We observe that the age of 50% users are in between 24 and 37 years, and also half of the users are younger
or equal than 29 years. It is also interesting to see that the minimum age is 16 years, which means that in
some countries is allowed the young teens to access betting at this young age.

* **Number of users in Germany by gender**
Germany is by far the country with the most users in this dataset, representing more than half of the sample
dataset. It is also interesting to notice the huge difference by gender (not only in Germany but also overall).

* **Distribution of Users Active Days by Product**
Bets in ‘Sports book fixed-odd’ (first graph) follow a distribution characterized by two peaks, one where the
number of active days is the lowest (around 0) and other where the number of active days is around 225. For
the ‘Sports book live-action’ bets (second graph), there are more active users either for a short or a long
active time and the distribution is much smoother, and for the other products they are even less visible (or
not at all).
It means that the ‘Sports book fixed-odd’ product is the one with more loyal customers on average. It is also
the product with the most active users.

* **Gain and Loss (Net Profit) by Gender**
The graph above shows the total gain and loss (net profit) for each user for Product 1, by gender. We can
clearly see that the variance for males is bigger than for females, which means that on average males take
more risk (they bet more). We can also see that in relative terms, the losses are more for males than for
females. We can see the same pattern for other products as well.

* **Gain and Loss (Net Profit) by Product**
In the graphs above, we can see that Cassino BossMedia is the product with the lowest net profit on average,
with the mean of USD -311. On the other hand, Supertoto is the product with the highest mean, which is
around USD -4.
Besides, there are two interesting patterns that we can observe for every product. The first one is that all of
them have a negative mean and median net profit, with the mean less than the median. The second pattern
related with this one, is that maximum losses are much higher than maximum gains, and that is why the
mean is lower than the median.

## Suggestions

The goal of the project was to create a datamart and build an interactive shiny app. There is still room for
further improvement in different aspects. Firstly, it would be useful to have a function to group by directly in
the Shiny app. Secondly, the user interface and plots were kept simple and clean. The main reason was to
make faster loading time for plots, as with other packages, such as Plotly is taking too much time to render
the interactive plots online. Finally, the basetable created in the project can be used to build a prediction
model in the future along with insights gained from the Shiny dashboard for variable selection process.

Shiny App Link: https://ekapopev.shinyapps.io/Open-Source-Group-11/
