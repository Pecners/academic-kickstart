---
title: Amortization Calculator Shiny App
author: Spencer Schien
date: '2020-03-16'
slug: shiny_app
categories:
  - Mortgage Calculator
tags:
  - Shiny
subtitle: ''
summary: 'Create a Shiny App mortgage calculator.'
authors: [admin]
lastmod: '2020-03-16T21:18:18-05:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
draft: true
---

{{% alert note %}}
This post follows the [Amortization CalculatoR](https://spencerschien.info/post/amortization_calculator/initial_post/creating-amortization-tables-in-r/) post, which describes in detail the R script used in the Shiny App described in this post.
{{% /alert %}}

# Introduction

Now that we've successfully created our amortization tables in R for both the standard schedule and the updated schedule, we can set our sights a little higher -- an interactive Shiny App.

A Shiny App is composed of a user interface (`ui`) script and a `server` script.  These can both be in a single file, or they can be in separate files -- I prefer the latter.

Put simply, everything will be wrapped in functions for `ui` and for `server`-- this means our R script written in the previous posts to calculate tables will need to be updated to fit the Shiny framework.

{{% alert note %}}
Since a Shiny App needs to be served, I will not be able to run the code included in the post.
{{% /alert %}}
