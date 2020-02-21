---
title: Creating an Amortization Calculator in R
author: Spencer Schien
date: ''
slug: creating-amortization-tables-in-r
categories:
  - Mortgage Calculator
tags:
  - Shiny
  - Rmarkdown
  - R
subtitle: ''
summary: 'Learn how to build an amortization calculator in R.'
authors: []
lastmod: '2020-02-09T21:35:57-06:00'
featured: no
image: 
  caption: ''
  focal_point: ''
  preview_only: yes
projects: []
math: true
---

```r
knitr::opts_chunk$set(message=FALSE, warning=FALSE)
```

{{% alert note %}}
This post only applies to fixed-rate loans.
{{% /alert %}}

Last year, I bought my first house (huzzah!), and as any respectable R developer, I decided I had to create my own amortization tables in R.  Taking it a step further, I really wanted to know what the effect of extra payments would be.  

Now, I was sure there must be a package already developed to do exactly this, but some quick searching online came up with a lot of web app calculators.  I gave up pretty quickly and turned to the learning opportunity that would be writing my own script to accomplish this task.

The project expanded on me a bit, and in the end, I wrote the script, created a parameterized Rmarkdown document, and wrote a Shiny app.  Over the next three posts, I provide a how-to for each step.

## What the Heck is Amortization, Anyway?

Okay, let's start out with a big 'ol COA disclaimer right here -- I'm no financial advisor, banker, CPA, or even that savvy of an investor.  So, I will only provide basic descriptions of financial concepts necessary for us to accomplish the task at hand.

You want to buy a home, but you only have a portion of the total price.  So, you go to a bank to get a loan.  The bank will give you all the money to buy the home now if you promise to pay that amount -- the principal -- plus interest in a certain amount of time.  You will make monthly payments that are part interest and part principal payments until the full amount of principal is repaid.

If you follow the payment schedule, you will pay a certain amount in interest.  This interest rate is variable depending on the amount of outstanding principal, which means if you make extra payments towards principal, there is less interest to be paid.

So, how do you know how much interest you're paying and how much principal each month?  That's where the amortization table comes in -- the table provides the breakdown of interest to principal for each payment.  That means our first task is to translate the table calculation into our R script.

## Doing the Math

### Total Monthly Payments (Principal + Interest)

The following formula calculates the monthly mortgage payment, which includes both the principal and interest:

<div>$$LoanAmount\times\frac{(MonthlyRate\times(1+MonthlyRate)^{\text{term}})}{(1+MonthlyRate)^{\text{term}}-1}$$</div>

The code below is the equation translated to R.  I've also defined the other variables we'll need with default values.


```r
# Define the variables

term <- 360 # 30 years in months
original_loan_amount <- 150000 # $150,000 loan
annual_rate <- 0.04 # 4% interest rate
monthly_rate <- annual_rate/12 # rate converted to monthly rate

# Formula to calculate monthly 
# principal + interest payment

total_PI <- original_loan_amount * 
   (monthly_rate * (1 + monthly_rate) ^ term)/
   (((1 + monthly_rate) ^ term) - 1)
```

In this example, the total monthly payment (i.e. `total_PI`) is $\$716.12$, which when multiplied by the term of the loan results in a total payment amount of $\$257,804.26$ -- in other words, over the life of this loan, we'll be paying $\$107,804.26$ in interest.

{{% alert note %}}
Additional monthly payment items such as PMI and escrow are excluded here.
{{% /alert %}}

### Breakdown of Principal and Interest in Each Payment

The portion of each payment that goes towards the principal -- or the original loan amount -- is what pays down your loan and builds equity. The portion that goes to interest is the cost you pay for the bank to give you the loan.  Basically, the amount of interest you pay each month is determined by multiplying the `monthly_rate` by the remaining balance of the loan.  This number will be less than the `total_PI`, and whatever the difference is between the two will be the principal portion of the payment.

Since `total_PI` is fixed and the interest portion of the payment is a function of the remaining loan balance, as you pay down the loan, the portion that goes to interest decreases, which results in a comparable increase in the portion that goes to principal.

Now we're getting very close to being able to create our amortization table. We know what our `total_PI` is, so now we just need to write code that will calculate the interest and principal portion of each payment, and then calculate the remaining principal.  

The following code will create numberic vectors for each value, with the length of each being set to the term of the loan.


```r
# Initialize the vectors as numeric with a length equal
# to the term of the loan.

interest <- principal <- balance <- date <- vector("numeric", term)

loan_amount <- original_loan_amount
# For loop to calculate values for each payment

for (i in 1:term) {
   intr <- loan_amount * monthly_rate
   prnp <- total_PI - intr
   loan_amount <- loan_amount - prnp
   
   interest[i] <- intr
   principal[i] <- prnp
   balance[i] <- loan_amount
}

# Throw vectors into a table for easier use

library(tidyverse) # for data manipulation going forward

standard_schedule <- tibble(payment_number = 1:term,
                            interest,
                            principal,
                            balance)

# Print head of standard_schedule

library(knitr) # both libraries for printing tables
library(kableExtra)

standard_schedule %>%
  
  # Format columns to display as dollars
  
  modify_at(c("interest", "principal", "balance"), scales::dollar,
            largest_with_cents = 1e+6) %>%
  
  # Limit to first 10 payments
  
  head(10) %>% 
  kable(booktabs = T) %>%
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> payment_number </th>
   <th style="text-align:left;"> interest </th>
   <th style="text-align:left;"> principal </th>
   <th style="text-align:left;"> balance </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> $500.00 </td>
   <td style="text-align:left;"> $216.12 </td>
   <td style="text-align:left;"> $149,783.88 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> $499.28 </td>
   <td style="text-align:left;"> $216.84 </td>
   <td style="text-align:left;"> $149,567.03 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> $498.56 </td>
   <td style="text-align:left;"> $217.57 </td>
   <td style="text-align:left;"> $149,349.47 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> $497.83 </td>
   <td style="text-align:left;"> $218.29 </td>
   <td style="text-align:left;"> $149,131.18 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> $497.10 </td>
   <td style="text-align:left;"> $219.02 </td>
   <td style="text-align:left;"> $148,912.16 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> $496.37 </td>
   <td style="text-align:left;"> $219.75 </td>
   <td style="text-align:left;"> $148,692.41 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> $495.64 </td>
   <td style="text-align:left;"> $220.48 </td>
   <td style="text-align:left;"> $148,471.93 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> $494.91 </td>
   <td style="text-align:left;"> $221.22 </td>
   <td style="text-align:left;"> $148,250.71 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> $494.17 </td>
   <td style="text-align:left;"> $221.95 </td>
   <td style="text-align:left;"> $148,028.76 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> $493.43 </td>
   <td style="text-align:left;"> $222.69 </td>
   <td style="text-align:left;"> $147,806.06 </td>
  </tr>
</tbody>
</table>

With our payments now calculated for the full term of the loan, we can visualize the interest and principal portions in a line graph.  


```r
# Pivot longer makes it easier to visualize,
# but isn't totally necessary

standard_schedule %>%
  pivot_longer(cols = c("interest", "principal"), 
               names_to = "Payment Portion", 
               values_to = "amount") %>%
  ggplot(aes(payment_number, amount, color = `Payment Portion`)) +
  geom_line() +
  
  # '#85bb65' is the color of $$$
  
  scale_color_manual(values = c("red", "#85bb65")) +
  
  # Change the theme for better appearance
  
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Payment Portions of Monthly Mortgage")
```

<img src="/post/amortization_calculator/initial_post/index_files/figure-html/unnamed-chunk-4-1.png" width="672" />

Judging from this visual, we can estimate that the portion of each payment going to principal will exceed the portion going to interest at about the 150th payment.  To be exact, we can filter the amortization table to find where `principal` exceeds `interest` for the first time.


```r
# Filter for interest less than principal

standard_schedule %>%
  filter(interest < principal) %>%
  
  # Include only the first observation
  
  head(1) %>%
  
  #  Prettify for table
  
  modify_at(c("interest", "principal", "balance"), scales::dollar,
            largest_with_cents = 1e+6) %>%
  kable(booktabs = T) %>%
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> payment_number </th>
   <th style="text-align:left;"> interest </th>
   <th style="text-align:left;"> principal </th>
   <th style="text-align:left;"> balance </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 153 </td>
   <td style="text-align:left;"> $357.72 </td>
   <td style="text-align:left;"> $358.41 </td>
   <td style="text-align:left;"> $106,956.13 </td>
  </tr>
</tbody>
</table>

So payment number 153 is the first payment where the portion going to principal is greater than the portion going to interest.

### Adding Dates

Now, a natural follow-up question is when will the 153rd payment take place? This is actually an easy question to answer -- all we need to do is add a date vector to our table. We will create a variable with the date of the first monthly payment, and then the vector will be a sequence of dates by month for the term of the loan.  The following code accomplishes this task.


```r
library(lubridate)

# Set first payment date

first_payment <- "2020-01-01"


# Add vector as variable to standard schedule

standard_schedule <- standard_schedule %>%
  mutate(date = seq(from = ymd(first_payment), by = "month",
            length.out = term)) %>%
  select(date, everything())

standard_schedule %>%
  modify_at(c("interest", "principal", "balance"), scales::dollar,
          largest_with_cents = 1e+6) %>%
  head(10) %>%
  kable(booktabs = T) %>%
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> date </th>
   <th style="text-align:right;"> payment_number </th>
   <th style="text-align:left;"> interest </th>
   <th style="text-align:left;"> principal </th>
   <th style="text-align:left;"> balance </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2020-01-01 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> $500.00 </td>
   <td style="text-align:left;"> $216.12 </td>
   <td style="text-align:left;"> $149,783.88 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-02-01 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> $499.28 </td>
   <td style="text-align:left;"> $216.84 </td>
   <td style="text-align:left;"> $149,567.03 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-03-01 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> $498.56 </td>
   <td style="text-align:left;"> $217.57 </td>
   <td style="text-align:left;"> $149,349.47 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-04-01 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> $497.83 </td>
   <td style="text-align:left;"> $218.29 </td>
   <td style="text-align:left;"> $149,131.18 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-05-01 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> $497.10 </td>
   <td style="text-align:left;"> $219.02 </td>
   <td style="text-align:left;"> $148,912.16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-06-01 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> $496.37 </td>
   <td style="text-align:left;"> $219.75 </td>
   <td style="text-align:left;"> $148,692.41 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-07-01 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> $495.64 </td>
   <td style="text-align:left;"> $220.48 </td>
   <td style="text-align:left;"> $148,471.93 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-08-01 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> $494.91 </td>
   <td style="text-align:left;"> $221.22 </td>
   <td style="text-align:left;"> $148,250.71 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-09-01 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> $494.17 </td>
   <td style="text-align:left;"> $221.95 </td>
   <td style="text-align:left;"> $148,028.76 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-10-01 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> $493.43 </td>
   <td style="text-align:left;"> $222.69 </td>
   <td style="text-align:left;"> $147,806.06 </td>
  </tr>
</tbody>
</table>

Now when we look at the 153rd payment, we see the date is September 01, 2032.

## Creating an Adjusted Schedule

Next, we will create an adjusted schedule that accounts for both extra monthly and one-time payments towards principal.  With these extra payments, the principal will be paid off before the full term of the loan, and you will therefore pay less interest.

To accomplish this, we will create new variables in our schedule for both extra monthly payments and extra one-time payments.  Additionally, we will want to save our adjusted schedule as a different object than `standard_schedule` so we can compare it to the standard schedule.


```r
# Create new variables for updated schedule

loan_amount1 <- original_loan_amount

interest1 <- principal1 <- extra <- xtra <- balance1 <- bonus <- NULL

# Set the extra monthly payment amount

for (i in 1:term) {
  
  # Stop the for loop when blance is paid off
  # Otherwise, loop will keep making monthly payments
  # Also must be sure to round values to 0.00
  
  if(loan_amount1 > 0.00) {
    intr1 <- (loan_amount1 * monthly_rate) %>%
      
      # Round to 0.00 for payments
      
      round(2)
    
    # Last payment won't be in full
    
    prnp1 <- ifelse(loan_amount1 < (total_PI - intr1),
                    loan_amount1,
                    total_PI - intr1) %>% round(2)
    
    # Last payment won't need extra payment
    
    xtra <- ifelse(loan_amount1 < (total_PI - intr1), 0, 100)
    
    loan_amount1 <- (loan_amount1 - prnp1 - xtra) %>%
      round(2)
  
    extra[i] <- xtra
    interest1[i] <- intr1
    principal1[i] <- prnp1
    balance1[i] <- loan_amount1
  }
}

# Set new term length 

new_term <- length(balance1)

# Combine in single table

updated_schedule <- tibble(date = seq(from = ymd(first_payment), by = "month",
                                      length.out = new_term),
                          payment_number = 1:new_term,
                          interest = interest1,
                          principal = principal1,
                          extra,
                          balance = balance1)
```

The code above creates the `updated_schedule` table for us.  We can inspect the first ten payments just like we did with the `standard_schedule`, with the addition of our extra monthly payment.


```r
updated_schedule %>%
  modify_at(c("interest", "principal", "extra", "balance"), scales::dollar,
          largest_with_cents = 1e+6) %>%
  head(10) %>%
  kable(booktabs = T) %>%
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> date </th>
   <th style="text-align:right;"> payment_number </th>
   <th style="text-align:left;"> interest </th>
   <th style="text-align:left;"> principal </th>
   <th style="text-align:left;"> extra </th>
   <th style="text-align:left;"> balance </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2020-01-01 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> $500.00 </td>
   <td style="text-align:left;"> $216.12 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $149,683.88 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-02-01 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> $498.95 </td>
   <td style="text-align:left;"> $217.17 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $149,366.71 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-03-01 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> $497.89 </td>
   <td style="text-align:left;"> $218.23 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $149,048.48 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-04-01 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> $496.83 </td>
   <td style="text-align:left;"> $219.29 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $148,729.19 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-05-01 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> $495.76 </td>
   <td style="text-align:left;"> $220.36 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $148,408.83 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-06-01 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> $494.70 </td>
   <td style="text-align:left;"> $221.42 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $148,087.41 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-07-01 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> $493.62 </td>
   <td style="text-align:left;"> $222.50 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $147,764.91 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-08-01 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> $492.55 </td>
   <td style="text-align:left;"> $223.57 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $147,441.34 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-09-01 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> $491.47 </td>
   <td style="text-align:left;"> $224.65 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $147,116.69 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-10-01 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> $490.39 </td>
   <td style="text-align:left;"> $225.73 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $146,790.96 </td>
  </tr>
</tbody>
</table>

We can look at the last ten rows as well to see how our code above works for the last payment.


```r
updated_schedule %>%
  modify_at(c("interest", "principal", "extra", "balance"), scales::dollar,
          largest_with_cents = 1e+6) %>%
  tail(10) %>%
  kable(booktabs = T) %>%
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> date </th>
   <th style="text-align:right;"> payment_number </th>
   <th style="text-align:left;"> interest </th>
   <th style="text-align:left;"> principal </th>
   <th style="text-align:left;"> extra </th>
   <th style="text-align:left;"> balance </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2043-01-01 </td>
   <td style="text-align:right;"> 277 </td>
   <td style="text-align:left;"> $24.10 </td>
   <td style="text-align:left;"> $692.02 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $6,436.59 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-02-01 </td>
   <td style="text-align:right;"> 278 </td>
   <td style="text-align:left;"> $21.46 </td>
   <td style="text-align:left;"> $694.66 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $5,641.93 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-03-01 </td>
   <td style="text-align:right;"> 279 </td>
   <td style="text-align:left;"> $18.81 </td>
   <td style="text-align:left;"> $697.31 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $4,844.62 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-04-01 </td>
   <td style="text-align:right;"> 280 </td>
   <td style="text-align:left;"> $16.15 </td>
   <td style="text-align:left;"> $699.97 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $4,044.65 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-05-01 </td>
   <td style="text-align:right;"> 281 </td>
   <td style="text-align:left;"> $13.48 </td>
   <td style="text-align:left;"> $702.64 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $3,242.01 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-06-01 </td>
   <td style="text-align:right;"> 282 </td>
   <td style="text-align:left;"> $10.81 </td>
   <td style="text-align:left;"> $705.31 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $2,436.70 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-07-01 </td>
   <td style="text-align:right;"> 283 </td>
   <td style="text-align:left;"> $8.12 </td>
   <td style="text-align:left;"> $708.00 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $1,628.70 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-08-01 </td>
   <td style="text-align:right;"> 284 </td>
   <td style="text-align:left;"> $5.43 </td>
   <td style="text-align:left;"> $710.69 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $818.01 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-09-01 </td>
   <td style="text-align:right;"> 285 </td>
   <td style="text-align:left;"> $2.73 </td>
   <td style="text-align:left;"> $713.39 </td>
   <td style="text-align:left;"> $100 </td>
   <td style="text-align:left;"> $4.62 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2043-10-01 </td>
   <td style="text-align:right;"> 286 </td>
   <td style="text-align:left;"> $0.02 </td>
   <td style="text-align:left;"> $4.62 </td>
   <td style="text-align:left;"> $0 </td>
   <td style="text-align:left;"> $0.00 </td>
  </tr>
</tbody>
</table>

### The Effect of Extra Payments

For the last payment, the interest is calculated as normal, but the principal portion is only the remainder of the balance less the interest instead of the remainder of the `total_PI` we calculated in the beginning. The extra payment is lowered to zero as well, since it isn't necessary.

We now see that by making an extra monthly payment of $100, we will make 74 fewer payments and we will make our final payment on October 01, 2043 instead of December 01, 2049.

And finally, we will pay $25,205.42 less in interest over the life of the loan, while the amount of principal we pay will remain the same, of course.  

The visual below depicts the resulting savings.


```r
# Viz is easier if schedules are joined
# First, create matching variables 

ss <- standard_schedule %>%
  mutate(schedule = "standard",
         extra = 0)

us <- updated_schedule %>%
  mutate(schedule = "updated")

both_schedules <- bind_rows(ss, us)

both_schedules %>%
  group_by(schedule) %>%
  mutate(cum_int = cumsum(interest),
            cum_prnp = cumsum(principal)) %>%
  pivot_longer(cols = c("cum_int", "cum_prnp"), 
               names_to = "Payment Portion", 
               values_to = "amount") %>%
  filter(`Payment Portion` != "cum_prnp") %>%
  ggplot(aes(date, amount, 
             group = schedule)) +
  geom_line(aes(linetype = schedule), color = "red") +
  
  # Change the theme for better appearance
  
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar) +
  scale_linetype_discrete(labels = c("Standard Schedule", "Updated Schedule")) +
  labs(title = paste("Amount in Interest Saved: ", scales::dollar(sum(interest) - sum(interest1)), sep = ""),
       subtitle = paste("By Paying", scales::dollar(extra), "Extra Per Month", sep = " "),
       y = "Total Interest Paid",
       x = "Payment Date", linetype = "",
       caption = paste("Based on ", scales::dollar(original_loan_amount), " loan over " , (term/12), " years.", sep = "")) +
  guides(linetype = guide_legend(override.aes = list(col = "red")))
```

<img src="/post/amortization_calculator/initial_post/index_files/figure-html/unnamed-chunk-10-1.png" width="672" />


Stay tuned for my next post that will wrap the work done here into a Shiny App.
