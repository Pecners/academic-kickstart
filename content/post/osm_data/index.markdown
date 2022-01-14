---
title: Make Minimalist Street Maps in R
author: admin
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
  preview_only: yes
projects: []
draft: true
---

# TL;DR 

* I used R to access the OpenStreetMap API and create a minimalist street map of Milwaukee, WI
* After I made the city map, I thought it would be cool to make one for each distinct neighborhood
* Maps and code can be found here: https://github.com/Pecners/milwaukee_streets

## Introduction

I'm sure you've seen city maps that only include minimalist features, with simple lines representing streets, and that's it -- no labels, no coloring, no borders, just the streets. These are more works of art than functional maps, but I think they're pretty cool. So of course when I discovered the [osmdata](https://github.com/ropensci/osmdata) package in R, my first thought was, *I wonder if I can make one of those street maps for Milwaukee.*

![Milwaukee Streets](https://raw.githubusercontent.com/Pecners/milwaukee_streets/master/Milwaukee%20City%20Streets.svg)

Thus was the inspiration for this project. Once I made the map for the city, my thoughts then turned to neighborhoods. If you aren't familiar with Milwaukee, it is a city with pretty distinct neighborhoods. In fact, in addition to neighborhoods being fairly well-known by the general public, there was also a project to create accepted spacial boundaries (i.e. polygons) of the neighborhoods. With the polygons, I knew it was possible to then effectively splice the streets to produce a map for each neighborhood. 

## Accessing the Data

The first step in this process is to read the data into R. As I stated above, I'm using the `osmdata` package to accomplish this, which is a wrapper around the OpenStreetMap Overpass API. If you're unfamiliar, [OpenStreetMap](https://en.wikipedia.org/wiki/OpenStreetMap) is an open source geographic database of the world. As the name implies, it includes geographic data for streets, but additionally, it includes many other data features, which I won't get into here. (For more information on all features, visit the [OpenStreetMap Wiki](https://wiki.openstreetmap.org/wiki/Map_features).)

After reviewing the OSM documentation, we see there are many levels of street features, including motorways, primary roads, residential roads, etc. It might not be intuitive at first what the difference in all these features looks like, so lets get plotting. We'll start with the highest level -- motorways.


```r
# We'll be using several {tidyverse} packages throughout
library(tidyverse)

# If you havn't installed the {osmdata} package yet, 
# run `install.packages("osmdata")`
library(osmdata)

# Query motorway data with bounding box set around "Milwaukee, WI"
motorways_mke <- opq("Milwaukee, WI") %>%
  add_osm_feature(key = "highway", value = "motorway") %>%
  osmdata_sf()
```

After loading the `tidyverse` and `osmdata` packages, we have a few lines of code that makes our query. Let's break it down, line by line: 

* First, `opq("Milwaukee, WI)` sets up our Overpass query. Basically, we stating what our bounding box will be (i.e. Milwaukee), with the bounding box being the limits of data returned. For instance, here we will be pulling all data for motorways withing the Milwaukee area
* Next, we have `add_osm_feature(key = "highway", value = "motorway")`. OSM data is broken up into key-value designations, with keys having many potential values. Roads fall under the *highway* key, and *motorway* is just one potential value, as we'll see further down.
* Finally, the chain ends with `osmdata_sf()`. Ending with this line transforms the returned data to an object in `sf` format. This is necessary for the plotting we will do shortly.

Now that we know how to access the OSM data, let's take a look at what is actually returned. You can run `glimpse(motorways_mke)` yourself and inspect the output, but I'm not including it here because the output is extensive. This gist is that the returned object is a list with several elements, including several geometric elements named `osm_points`, `osm_lines`, `osm_polygons`, etc.  Basically, if there is data of these different geometric types, it will be returned. If there isn't, then those elements will be null. For our purposes, we'll be looking at `osm_lines`.

## Plotting the data

Now that we have the data loaded into R, we can get to work actually plotting it. Below, we have plotted the Milwaukee motorways returned by our Overpass query. If you're familiar with Milwaukee, you recognize the shape of the city, where the shore of Lake Michigan would be on the far right side of the plot. 


```r
# Save lines element for ease of use
lines <- motorways_mke$osm_lines

lines %>%
  ggplot() +
  geom_sf() +
  labs(title = "Milwaukee Motorways")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/motorways_plot-1.png" width="672" />

A keen eye will also notice that the lines don't seem to connect cleanly, or at all in some cases. This is because OSM also tracks what it calls *link* highways. For every *value* level that can follow the *highway* key, there is a corresponding *value* for link roads of that level. There is the *motorway* value, for instance, and there is the corresponding *motorwaylink* value. 


```r
motorway_links_mke <- opq("Milwaukee, WI") %>%
  add_osm_feature(key = "highway", value = "motorway_link") %>%
  osmdata_sf()

links <- motorway_links_mke$osm_lines

links %>%
  ggplot() +
  geom_sf() +
  labs(title = "Milwaukee Motorway Links")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-1-1.png" width="672" />

Well that's unexpected. There's way more there than would be needed just to connect the motorways, so what's going on? To get a better idea, let's zoom in a bit.

{{% alert note %}}
In practice, I don't usually bother with zooming in on plots like this. Rather, I prefer to export the plot to PDF, which is vectorized and allows for zooming. You can even just preview the PDF without having to worry about saving. Using our map example, the line strokes are probably too thick for that, so I'd then make them much smaller, i.e. geom_sf(size = .1). 
{{% /alert %}}


```r
links %>%
  ggplot() +
  geom_sf() +
  coord_sf(ylim = c(43.00, 43.05), xlim = c(-87.90, -87.95))
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-2-1.png" width="672" />

Aha! What was hard to see in the first plot was that there are actually MANY distinct lines included here, but our line stroke size was too large for that level of discernment.

test test
{{% alert note %}}
I think of the `st_intersection` operations as cookie cutters. In our example, you have the cookie dough (all streets in the whole city) rolled out, and then you use a cookie cutter (the distinct neighborhood boundary) to cut only those portions of the streets that fall within the neighborhood.
{{% /alert %}}
