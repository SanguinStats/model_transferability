# GitHub repository to accompany the paper "Predicting haemoglobin deferral using machine learning models: can we use the same prediction model across countries?”

## General

In this repository, you will find the scripts used to produce the results and figures of this study. This research was conducted by the SanguinStats group, a group of statisticians and epidemiologists from blood establishments and universities.

## Guide

In the [source](/src) folder, scripts for producing the results and figures can be found. The script for the manuscript figures specifically can be found [here](/src/Plots_manuscript.Rmd). 

In the [figures](/figures) folder, the figures produced in this project can be found. There is a specific folder for the figures in the manuscript, where you can find [Figure 1](figures/Manuscript_plots/AUPRadj_forestplot.png) and [Figure 2](figures/Manuscript_plots/SHAP.png). 

We conducted a simulation that is included in the supplemental materials of the paper. The files for the simulation are also located in the [simulation](/simulation) folder, for example the [Quarto file](/simulation/01_Analysis.qmd) of the simulation. The results can be viewed [here](https://sanguinstats.github.io/model_transferability/)

## Abstract

_Background and objectives_

Personalised donation strategies based on Hb prediction models may reduce Hb deferrals and hence costs of donation, meanwhile improving commitment of donors. We previously found prediction models perform better in validation data with a high Hb deferral rate. We therefore investigate whether models trained on data with high deferral rates improve the prediction of Hb deferral in other blood establishments.

_Methods_

Donation data from the past five years from random samples of 10,000 donors from Australia, Belgium, Finland, the Netherlands and South Africa were used to fit random forest models for Hb deferral prediction. Trained models were extracted and exchanged between blood establishments, and the performance of all models on all validation datasets was evaluated. 

_Results_

Exchanged models perform similarly within blood establishments, irrespective of the origin of the training data. Apart from subtle differences, the importance of most predictor variables is similar in all trained models.

_Conclusion_

Our results suggest that Hb deferral prediction models learn similar associations in different training datasets and that their performance is rather determined by the characteristics of the validation dataset.
