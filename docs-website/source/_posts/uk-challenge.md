---
title: Introducing the UK Crowd Forecasting Challenge
date: 2021-05-11
---

![$cover](/images/Crowdforecasting-challenge-header.png)

<br>

On May 24th 2021 the official UK Crowd Forecasting Challenge, hosted by the Epiforecast group at the London School of Hygiene & Tropical Medicine will begin! Over the course of 12 weeks, we’ll collect and score your personal predictions of Covid-19 case and death numbers of Covid-19 in the United Kingdom. The best forecasters will receive a cash prize of up to 100 GBP.

Forecasts generated through this competition will contribute to an ongoing research project. An ensemble of all predictions (subject to a quality check) will also be submitted to the [European Forecast Hub](https://covid19forecasthub.eu/). Forecasters therefore have a chance to make a real world impact by providing valuable insights to policy makers and public health officials through the [European Forecast Hub](https://covid19forecasthub.eu/). You can learn more about the project in the [about section](#About-the-project) at the end of this document. 

## How to sign up

Visit either the [‘classical’ crowd forecasting app](http://app.crowdforecastr.org/) or the new [Rt forecasting app](http://rt-app.crowdforecastr.org/) (more on these two [below](#The-forecast-apps)) and create an account. You are automatically signed up once you submit your first forecasts for the UK. Note that forecasts should be submitted between Sunday 12pm UK Time and Monday 10pm UK time. 

  

## Competition summary

### Contest period

The UK Crowd Forecasting Challenge will run over the course of 12 weeks.

The first date to submit forecasts is 25th May 2021

The last date to submit forecasts is 16th August 2021

### What will I be forecasting? 

You will be asked to predict the number of Covid-19 case numbers and death numbers in the United Kingdom over a 1-4 week ahead horizon. 

### What could I win? 

-   1st prize: 100 GPB
    
-   2nd prize: 50 GPB
    
-   3rd prize: 25 GPB
    

### Can I join late?

Yes! The way we evaluate and score predictions (more on that [below](#How-are-forecasts-evaluated) incentivises regular participation while allowing participants to join late or even miss a forecast date. 

### Eligibility

Everyone who submits at least one forecast for both targets (cases and deaths in the UK) is eligible to win a prize.

In order to receive a prize, you must make your contact details known to the organisers (either by providing your email address in the app user account, or by sending a message to epiforecasts@gmail.com)

### The forecast apps

There are two forecast apps you can use. You may always switch between the two and can also submit multiple forecasts - we will only count the latest one. 

  

#### The ‘classical’ forecast app

Link: [app.crowdforecastr.org](http://app.crowdforecastr.org/)

  

Forecasters predict cases and deaths directly. To do so, you need to drag the points for (or manually specify) the median prediction. This is the value where you believe that there is exactly a 50:50 chance that the true value will be either higher or lower than that point. You also need to provide an estimate for the uncertainty around your forecasts (represented by the width value of the predictive distribution)

  

#### The Rt forecast app

Link: [rt-app.crowdforecastr.org](http://rt-app.crowdforecastr.org/)

  

Forecasters predict Rt (the average number of people every infected person will infect in turn) by specifying the median and width of a predictive distribution for Rt values. These Rt values then get mapped to cases and deaths using a renewal equation as implemented in the R package EpiNow2. You will be able to see case forecasts. However, the app won’t show you the corresponding death forecasts so you’ll have to trust the renewal equation to produce sensible results.

  

More information about the different forecast apps and a short instructional video can be found [here](https://www.crowdforecastr.org/forecast-apps). 

### What data can I use to make a forecast?

Any data you like! Forecasts will be evaluated using the ground truth data used by the European Forecast Hub. Currently, this data about reported cases and deaths is provided by Johns Hopkins University.

### When to make a forecast 

Data will be updated every Sunday at around 9am UK time. You can make your forecast at any point from then until 10pm UK time on Monday.

### Can I correct my forecasts? 

Yes! Simply make a new prediction. Forecasters can make as many forecasts as they like - only the latest one will be counted.

### I’m so happy about this competition I immediately created multiple accounts. Is that ok?

We very much appreciate your positive feelings, but unfortunately you can only have one account per person. 

  

### What if I forgot my password? 

Simply write an email with your username at epiforecasts@gmail.com

### How are forecasts evaluated?

The simple version is this: We use a scoring rule that guarantees that nobody can cheat and everyone is incentivised to provide their best possible forecast. We’ll evaluate case as well as death forecasts and combine your performance in both domains. 

  

The complicated and more detailed version: A ranking will be based on relative skill scores that are obtained using pairwise comparisons between forecasters:

-   Every forecast will be scored using the weighted interval score (WIS). Scores will be computed based on the log of the forecasts and truth data. This preserves the incentive of the forecasters to give their best forecast, while at the same time giving a more equal weight to death and case forecasts.
    
-   for every possible pair of forecasters, a mean score ratio will be computed. The mean score ratio is the mean WIS achieved by forecaster 1 over the mean WIS achieved by forecaster 2 based on the overlapping set of prediction targets for which both forecasters have made a forecast
    
-   For every forecaster, a relative skill score will be computed as the geometric mean of all mean score ratios involving that forecaster
    

### What if I miss a forecast date? 

If you miss a forecast date you will be assigned the median score that was achieved on that date by all forecasters who have made a forecast

## About the project

The challenge is part of an ongoing research project by the epiforecasts group the Centre for the Mathematical Modelling of Infectious Diseases @cmmid\_lshtm of the London School of Hygiene & Tropical Medicine in collaboration with Public Health England (PHE) and Imperial College

  

### Informing public health

Crowd forecasts have a strong track record and in the past were often able to beat model-based approaches when it comes to predicting Covid-19 case and death numbers. 

Over the past months we have collected crowd forecasts within our working group, first in Germany and Poland and now across 32 countries in Europe. These forecasts have been submitted to the [European Forecast Hub](https://covid19forecasthub.eu/) and the [German and Polish Forecast Hub](https://kitmetricslab.github.io/forecasthub/forecast). In both instances, our crowd forecasts were among the top models submitted  (see this [paper](https://www.medrxiv.org/content/10.1101/2020.12.24.20248826v2.full) about the German and Polish forecasts or the [evaluation](https://covid19forecasthub.eu/reports.html) of the European Forecast Hub forecasts). We therefore believe that crowd forecasts can be a valuable contribution to public policy and want to expand our approach to a larger set of participants.

The UK is of particular interest, as it is the European country furthest ahead in terms of vaccinations. How the gradual easing  of restrictions influences case numbers is of great interest to countries that have yet to take similar steps. New variants may still pose a threat and even though the UK is on a good path, the next few weeks will be crucial.

### Forecasting epidemics - an ongoing research project

While we know that crowd forecasts can provide immense value, there are also many open research questions we want to answer. 

What is the best way to combine individual forecasts to an ensemble that performs better than its individual parts? How consistent are forecasters in their performance?

In particular, we want to look into a radically new way of forecasting. In addition to forecasting deaths and cases directly, forecasters will have the option to use the new [Rt Crowd Forecast App](http://rt-app.crowdforecastr.org/). The app can be used to predict Rt, the average number of people a single infected individual will infect in turn. The trajectory of Rt gives an indication of whether cases will go up or down in the future. The predicted Rt trajectory will then be mapped to cases and deaths using a so-called ‘renewal equation’ that takes care of the epidemiological specifics. We hope this will be a way of combining the strengths of human forecasters (predicting a trend) with the benefits of computer models (dealing with the complex specifics of epidemiological modelling).

We look forward to your participation!

  

### Privacy

If you want to learn more about how we handle the data, you can have a look at our [privacy policy](/legal-privacy).
