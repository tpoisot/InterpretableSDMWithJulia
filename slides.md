---
author: "Timothée Poisot"
institute: "Université de Montréal"
title: "Interpretable ML for biodiversity"
date: "\\today"
subtitle: "An introduction using species distribution models"
---



## Main goals

1. How do we produce a model?
2. How do we convey that it works?
3. How do we talk about how it makes predictions?
4. How do we use it to guide actions?

## The steps

1. Get data about species occurrences
2. Build a classifier and make it as good as we can
3. Measure its performance
4. Explain some predictions
5. Generate counterfactual explanations
6. Briefly discuss ensemble models

## But why...

... think of SDM as a ML problem?
: Because they are! We want to learn a predictive algorithm from data

... the focus on explainability?
: We cannot ask people to *trust* - we must *convince* and *explain*

# Problem statement

## The problem in ecological terms

We have information about a species

## The problem in other words

We have a series of observations $y \in \mathbb{B}$, and predictors variables $\mathbf{X} \in \mathbb{R}$

We want to find an algorithm $f(\mathbf{x}) = \hat y$ that results in the distance between $\hat y$ and $y$ being *small*

## Setting up the data for our example

The predictor data will come from CHELSA2 - we will start with the 19 BioClim variables





We will use data on observations of *Turdus torquatus* in Switzerland, downloaded from the copy of the eBird dataset on GBIF





## The observation data

![](figures/slides_4_1.png)\ 




## Problem!

We want $\hat y \in \mathbb{B}$, and so far we are missing \alert{negative values}

## Solution!

pseudo-absences

what are the assumptions we make




## The (inflated) observation data

![](figures/slides_6_1.png)\ 




# Training the model

## The Naive Bayes Classifier

$$P(+|x) = \frac{P(+)}{P(x)}P(x|+)$$

$$\hat y = \text{argmax}_j \, P(\mathbf{c}_j)\prod_i P(\mathbf{x}_i|\mathbf{c}_j)$$

$$P(x|+) = \text{pdf}(x, \mathcal{N}(\mu_+, \sigma_+))$$

## Setup




## Cross-validation

Can we train the model

assumes parallel universes with slightly less data

is the model good?

## Null classifiers

coin flip

no skill

constant

## Expectations

| **Model**        | **MCC**   | **PPV**  | **NPV**  | **DOR**  | **Accuracy** |
|-----------------:|----------:|---------:|---------:|---------:|-------------:|
| noskill          | 0.0       | 0.338178 | 0.661822 | 1.0      | 0.552373     |
| coinflip         | -0.323643 | 0.338178 | 0.338178 | 0.261102 | 0.338178     |
| constantpositive | 0.0       | 0.338178 | NaN      | NaN      | 0.338178     |
| constantnegative | 0.0       | NaN      | 0.661822 | NaN      | 0.661822     |




## Cross-validation strategy

k-fold

validation / training / testing




## Cross-validation results

| **Model**        | **MCC**   | **PPV**  | **NPV**  | **DOR**  | **Accuracy** |
|-----------------:|----------:|---------:|---------:|---------:|-------------:|
| noskill          | 0.0       | 0.338178 | 0.661822 | 1.0      | 0.552373     |
| coinflip         | -0.323643 | 0.338178 | 0.338178 | 0.261102 | 0.338178     |
| constantpositive | 0.0       | 0.338178 | NaN      | NaN      | 0.338178     |
| constantnegative | 0.0       | NaN      | 0.661822 | NaN      | 0.661822     |
| Validation       | 0.285042  | 0.573912 | 0.739042 | 3.97394  | 0.698661     |
| Training         | 0.287722  | 0.57633  | 0.73963  | 3.869    | 0.699451     |




## What to do if the model is trainable?

train it!

re-use the full dataset




## Initial prediction

![](figures/slides_12_1.png)\ 




## How is this model wrong?

![](figures/slides_13_1.png)\ 




## Can we improve on this model?

variable selection




data transformation

hyper-parameters tuning

will focus on the later (same process for the two above)

## Moving theshold classification

p plus > p minus means threshold is 0.5

is it?

how do we check this




## Learning curve for the threshold

![](figures/slides_16_1.png)\ 




## Receiver Operating Characteristic

![](figures/slides_17_1.png)\ 




## Precision-Recall Curve

![](figures/slides_18_1.png)\ 




## Revisiting the model performance

| **Model**        | **MCC**   | **PPV**  | **NPV**  | **DOR**  | **Accuracy** |
|-----------------:|----------:|---------:|---------:|---------:|-------------:|
| noskill          | 0.0       | 0.338178 | 0.661822 | 1.0      | 0.552373     |
| coinflip         | -0.323643 | 0.338178 | 0.338178 | 0.261102 | 0.338178     |
| constantpositive | 0.0       | 0.338178 | NaN      | NaN      | 0.338178     |
| constantnegative | 0.0       | NaN      | 0.661822 | NaN      | 0.661822     |
| Previous         | 0.285042  | 0.573912 | 0.739042 | 3.97394  | 0.698661     |
| Validation       | 0.65469   | 0.682064 | 0.940772 | 38.1561  | 0.825594     |
| Training         | 0.658932  | 0.686247 | 0.941019 | 34.9715  | 0.827627     |




## Updated prediction


![](figures/slides_21_1.png)\ 




## How is this model better?

![](figures/slides_22_1.png)\ 




## Revisiting assumptions

- pseudo-absences
- not just a statistical exercise

## Variable importance

| **BIO** | **Import.** |
|--------:|------------:|
| 11.0    | 0.342392    |
| 5.0     | 0.292015    |
| 10.0    | 0.254812    |
| 1.0     | 0.110781    |




# But why?

## Intro explainable

## An ecology tool: partial response curves

## Example with temperature

![](figures/slides_24_1.png)\ 




## Example with two variables

![](figures/slides_25_1.png)\ 




## Spatialized partial response plot

![](figures/slides_26_1.png)\ 




## Spatialized partial response (binary outcome)

![](figures/slides_27_1.png)\ 




## Inflated response curves

Averaging the variables is \alert{masking a lot of variability}!

Alternative solution:

1. Generate a grid for all the variables
2. For all combinations in this grid, use it as the stand-in for the variables to replace

In practice: Monte-Carlo on a reasonable number of samples.

## Example

![](figures/slides_28_1.png)\ 




## Limitations

- partial responses can only generate model-level information
- they break the structure of values for all predictors at the scale of a single observation
- their interpretation is unclear

## Shapley

## Example




## Response curves revisited

![](figures/slides_30_1.png)\ 




## On a map

![](figures/slides_31_1.png)\ 




## Variable importance revisited

| **BIO** | **Import.** | **Shap. imp.** |
|--------:|------------:|---------------:|
| 5.0     | 0.292015    | 0.358287       |
| 11.0    | 0.342392    | 0.317696       |
| 1.0     | 0.110781    | 0.163154       |
| 10.0    | 0.254812    | 0.160862       |




## Most important predictor

![](figures/slides_33_1.png)\ 




# What if?

## Intro to counterfactuals

what they are

# Ensemble models

# Conclusions