---
title: The UK Crowd Forecasting Challenge
subtitle: Win a prize for your insights!
layout: page
---

<br> 

## Overview and summary

From **May 24th 2021** until **August 16th 2021** we will collect and score forecasts of Covid-19 case and death numbers of Covid-19 in the United Kingdom. The best forecasters will receive a prize of

1. prize: 100 GBP
2. prize: 50 GBP
3. prize: 25 GBP

All forecasts will be made using the crowdforecastr platform ([app.crowdforecastr.org](https://app.crowdforecastr.org) or [rt-app.crowdforecastr.org](https://rt-app.crowdforecastr.org))

## Study period
- 12 weeks
- first forecast date: 2021-05-24
- last forecast date: 2021-08-16  

## Forecast targets
Forecasters are asked to predict 
- the number of Covid-19 case numbers and 
- death numbers 
- in the United Kingdom 
- on a 1 to 4 week ahead horizon

## Eligibility
Everyone who submits *at least one* forecast for both targets (cases and deaths in the UK) is eligible to win a prize.

In order to receive a prize, you must make your contact details known to the organisers (either by providing your email address in the app user account, or by sending a message to epiforecasts@gmail.com)

## Making a forecast
Forecasts will be made through the crowdforecastr platform. 
Individuals can make a forecast using either the regular forecasting app (app.crowdforecastr.org) or the Rt forecasting app (rt-app.crowdforecastr.org)
Forecasters can make as many forecasts as they like - only the latest one will be counted

### The regular forecast app
- app.crowdforecastr.org 
- Forecasters are asked to give the median and width of a chosen predictive distribution for each target

### The Rt forecast app
- rt-app.crowdforecastr.org
- Forecasters are asked to give the median and width of a chosen predictive distribution for Rt values
- These Rt values then get mapped to cases as well as deaths using a renewal equation as implemented in the R package EpiNow2
- Users can visualise case forecasts, but will not be able to see corresponding death forecasts and have to trust the renewal equation to produce sensible results. 

## Evaluation
A ranking will be based on relative skill scores that are obtained using pairwise comparisons between forecasters: 
- Every forecast will be scored using the weighted interval score (WIS). Scores will be computed based on the log of the forecasts and truth data. This preserves the incentive of the forecasters to give their best forecast, while at the same time giving a more equal weight to death and case forecasts. 
- for every possible pair of forecasters, a mean score ratio will be computed. The mean score ratio is the mean WIS achieved by forecaster 1 over the mean WIS achieved by forecaster 2 based on the overlapping set of prediction targets for which both forecasters have made a forecast
- For every forecaster, a relative skill score will be computed as the geometric mean of all mean score ratios involving that forecaster

If you miss a forecast date you will be assigned the median score that was achieved on that date by all forecasters who have made a forecast


