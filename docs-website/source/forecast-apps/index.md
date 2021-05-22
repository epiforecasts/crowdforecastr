---
title: The Crowdforecastr App(s)
subtitle: make a forecast
layout: page
---

<br> 

## Quick Links

- [Forecast app](http://app.crowdforecastr.org)
- [Rt forecast app](http://rt-app.crowdforecastr.org)

## The (Classical) Forecast App 

The app allows you to make a direct forecast of Covid-19 case and death numbers. Simply log in (or create an account), drag the points and specify the amount of uncertainty around your predictions. 

This video gives you a quick introduction to the app and how to make a forecast: 

<iframe height = 400, width = "100%" allowfullscreen="allowfullscreen" mozallowfullscreen="mozallowfullscreen" msallowfullscreen="msallowfullscreen" oallowfullscreen="oallowfullscreen" webkitallowfullscreen="webkitallowfullscreen" src="https://www.youtube.com/embed/NzZkNxXFgm8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen fullscreen></iframe>

<br>

## The Rt Forecast App

Instead of making a direct forecast, you can harness the power of epidemiological modelling and make a forecast using the effective reproduction number Rt (the average number of people every infected person will infect in turn). 

Instead of specifying an exact case or death forecast, you simply forecast a trajectory: will future cases / deaths decrease, increase or stay unchanged? 
This trajectory will be mapped to cases and deaths using the R package EpiNow2 which in turn uses the so-called 'renewal equation'. Based on your forecast of how many future cases every infected person will generate, the algorithm computes how many future cases and deaths will occur in the following weeks. Instead of two separate forecasts (for deaths and cases) you only have to make one. 

This approach is potentially very powerful, as humans are good at predicting general trends, but can't compute all the epidemiological dynamics in their heads. Especially for forecasting deaths, this may be very useful. 


