---
title: Forecasting
subtitle: Getting started and getting better
layout: page
---

<br> 

In the following we give an overview of how to get started and provide some useful information about how to make a good forecast. 

## Becoming a forecaster 

You can become a forecaster by opening the [crowdforecastr app](https://cmmid-lshtm.shinyapps.io/crowd-forecast/) and creating an account. 

This video gives you a quick introduction to the app and how to make a forecast: 

<iframe height = 400, width = "100%" allowfullscreen="allowfullscreen" mozallowfullscreen="mozallowfullscreen" msallowfullscreen="msallowfullscreen" oallowfullscreen="oallowfullscreen" webkitallowfullscreen="webkitallowfullscreen" src="https://www.youtube.com/embed/NzZkNxXFgm8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen fullscreen></iframe>

<br>

## Becoming a good forecaster

Improving your forecasting skill takes some time and effort. Here are some tips that may help you. 

1. Always look at the [evaluation](https://epiforecasts.io/europe-covid-forecast) of past forecasts. This gives you helpful information about any systematic biases you may have. This could be things like
    - underestimating exponential growth
    - being to quick to interpret noisy data as a change in trend, or being to slow to adapt to new trends
    - being overly (un-)certain. To check this, check the WIS decomposition tab in the evaluation. This gives you an overview of how much of the penalties your forecasts get come from being too uncertain (a high sharpness value) or for being wrong and not uncertain enough (over- and underprediction)
2. Make use of the log view. A straight line on the log view corresponds to exponential growth or decline, which is a good starting point in many (although not all) situations
3. Increase your uncertainty over time. You should be much less sure about your forecast 4 weeks into the future than you predictions for next week
4. Look at how quickly cases have fallen / risen in the past? Past growth rates may give an indicator for what kind of growth / decline may be likely in the future. 
5. Use additional information
    - A high Case Fatality Rate, for example, can be indicator that states don't test enough and a lot of transmissions aren't detected. This makes continued future growth more likely
    - How are testing efforts evolving over time? This may influence reported case numbers even if infections aren't rising
    - Stringency of policy and implemented measures like lock-downs or school re-openings usually have an impact of future cases. Anticipating these may be helpful in forecasting. 
    - Known reporting artifacts. For example, around Christmas reported cases and deaths were artifically low in many regions. 
6. Think about counteracting trends that occur at the same time. For example, vaccinations may push cases down, while new variants may make an increase more likely. Which of these effects does a higher influence on the growth rate over the next 4 weeks?