---
title: Make Minimalist Street Maps in R
author: Spencer Schien
date: '2021-10-04'
slug: []
categories: []
tags: []
subtitle: ''
summary: ''
authors: []
lastmod: '2021-10-04T19:04:03-05:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

# TL;DR

* I used R to access the OpenStreetMap API and create a minimalist street map of Milwaukee, WI
* After I made the city map, I thought it would be cool to make one for each distinct neighborhood
* Maps and code can be found here: https://github.com/Pecners/milwaukee_streets

# Introduction

I'm sure you've seen city maps that only include minimalist features, such as lines representing streets, and that's it -- no labels, no coloring, no borders, just the streets. These are more works of art than functional maps, but I think they're pretty cool. So of course when I discovered the [osmdata](https://github.com/ropensci/osmdata) package in R, my first thought was, *I wonder if I can make one of those street maps for Milwaukee.*

![Milwaukee Streets](https://raw.githubusercontent.com/Pecners/milwaukee_streets/master/Milwaukee%20City%20Streets.svg)

Thus was the inspiration for this project. Once I made the map for the city, my thoughts then turned to neighborhoods. If you aren't familiar with Milwaukee, it is a city with pretty distinct neighborhoods. In fact, in addition to neighborhoods being fairly well-known by the general public, there was also a project to create accepted spacial boundaries (i.e. polygons) of the neighborhoods. With the polygons, I knew it was possible to then effectively splice the streets to produce a map for each neighborhood. 

{{% alert note %}}
I think of the `st_intersection` operations as cookie cutters. In our example, you have the cookie dough (all streets in the whole city) rolled out, and then you use a cookie cutter (the distinct neighborhood boundary) to cut only those portions of the streets that fall within the neighborhood.
{{% /alert %}}
