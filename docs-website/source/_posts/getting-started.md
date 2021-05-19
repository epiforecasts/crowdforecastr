---
title: How to Become a (Good) Forecaster
subtitle: Getting started and getting better
date: 2021-03-15
---

![$cover](/images/jhu-dashboard.png)

<br> 

This post gives an overview of how to get started with the [crowdforecastr app(s)](/forecast-apps) and provides some useful information about how to make a good forecast and improve

## Becoming a forecaster 

You can become a forecaster by opening the [crowdforecastr app](https://cmmid-lshtm.shinyapps.io/crowd-forecast/) and creating an account. 

This video gives you a quick introduction to the app and how to make a forecast: 

<iframe height = 400, width = "100%" allowfullscreen="allowfullscreen" mozallowfullscreen="mozallowfullscreen" msallowfullscreen="msallowfullscreen" oallowfullscreen="oallowfullscreen" webkitallowfullscreen="webkitallowfullscreen" src="https://www.youtube.com/embed/NzZkNxXFgm8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen fullscreen></iframe>

<br>

## Becoming a good forecaster

Improving your forecasting skill takes some time and effort. Here are some tips that may help you.

1.  Always look at the [evaluation](https://epiforecasts.io/crowd-evaluation) (outcome) of past forecasts. This gives you helpful information about any ‘systematic biases’ you may have. A bias means that you e.g. have a tendency to always over- or underpredict the true observed values. This could be things like
	-   underestimating ‘exponential growth’. Exponential growth is multiplicative, so a value in the future is always the current value times some value (the growth rate). Exponential growth is usually slow in the beginning and then explodes rapidly. 
	-   being too quick to interpret ‘noisy’ data as a change in trend, or being too slow to adapt to new trends. Public health reporting is often messy. Sometimes numbers don’t get reported because it is a Sunday. Sometimes mistakes happen that should best be understood as ‘noise’. Correctly identifying noise is hard. If numbers go down one week, is that just a random fluke, or does it indicate that something has fundamentally changed and numbers will continue to go down in the future?
	-   being overly (un-)certain. The ‘weighted interval score’ that is used to score the forecasts has three components: “overprediction”, “underprediction” and “sharpness”. Overprediction and underprediction are penalties that occur if the true observed value falls outside of the range of values deemed plausible by your forecast. If you make a very uncertain forecast, the range of plausible values is larger and you are less likely to get penalties for over- and underprediction. The “sharpness” term on the other hand penalises you for being overly uncertain. This means that you need to finely balance the line between being too uncertain (where you get a sharpness penalty) and too confident (where you get over- and underprediction penalties if your forecast is off). To check this, you can look at the three components in the [evaluation](https://epiforecasts.io/crowd-evaluation) of your forecasts. 
    
2.  Make use of the log view. In the app, you can visualise the forecast on a logarithmic scale. A straight line on the log scale means  exponential growth or decline, which is a good starting point for a forecast in many (although not all) situations
    
3.  Increase the uncertainty of your forecast over time. You should be much less sure about your forecast 4 weeks into the future than your forecast for next week
    
4.  Look at how quickly cases of Covid-19 infection have fallen / risen in the past. Growth rates in the past may give an indication about how cases can be expected to rise or fall in the future.
    
5.  Use additional information:
	-   How are testing efforts for Covid-19 changing over time? More testing may lead to more reported COVID-19 cases, even if infections aren’t rising
    -   On the other hand, a high Case Fatality Rate (a high number of deaths resulting from Covid-19) might indicate that countries aren’t testing for Covid-19 enough which means that infections are being missed. This makes a rise in COVID-19 cases more likely.
   	-   The introduction of, or changes to, policy measures like lockdowns or school reopenings, which can have an impact on  future cases. 
    -   Quirks in reporting. Sometimes countries report lots of cases on a single day that have been missed previously or correct their reported numbers
    
6.  Think about balancing out trends that occur at the same time. For example, vaccinations may push cases down, while new variants of Covid-19 may mean a rise in cases is more likely. Which of these factors do you think will have the bigger impact on COVID-19 spread over the next 4 weeks?
