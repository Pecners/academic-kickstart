---
title: School Dimensions Table
author: Spencer Schien
date: '2019-10-15'
slug: school-dimensions-table
categories:
  - Database Design
tags:
  - R
  - ETL
subtitle: ''
summary: ''
authors: []
lastmod: '2019-10-15T09:31:20-05:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
reading_time: false
share: false
draft: true
commentable: true
---


## Matching Observations Across Tables

The obvious field to map across the two tables is the school name field, but as anyone with database experience can attest, matching values based on any names is a fraught endeavor since names are so prone to typos, abbreviations, etc.  And in fact, this was my experience with school data -- the school names used by the state were rarely the same as the school names used in practice by the schools or the public (e.g. *Gwen T. Jackson School* is the same as *Jackson Elementary* in Milwaukee, and there are several *Jackson Elementary*'s in Wisconsin).  More frustrating, in some cases the school name used by the state would change from year to year.  If you don't account for these inconsistencies, Power BI will simply drop the non-matched values from your analysis.

The solution is to use the state's *School Codes* as unique identifiers, the field which will connect observations in one dataset to observations in another.  This solution proved to be flawed as well, though!  The problem was that school codes by themselves are not unique -- each school is also assigned a *District Code* that associates a school to its school district.  Now, the combination of a *District Code* and a *School Code* does turn out to be a unique identifier.  So, success!

Or not...  

As it turns out, Power BI does not allow you to match by two fields like this, so I decided to concatenate the two fields into a single field -- but still, I didn't have a unique identifier!  Now the problem was that you could have a *District Code* of `1` and a *School Code* of `11` that would have the same value when concatenated as a private school with a *School Code* of `111` (Private schools don't have a *District Code*).  In the end, the final solution to this that worked for me in Power BI was to concatenate with an underscore separator "_".  Now the first school mentioned above would be `1_11` and the second school would be `_111`.

The only problem with this solution is that the state has not been consistent over the years with padding the two codes or not.  For example, a school's *School Code* one year might be `23`, but the previous year it was `0023` (padded with zeroes on the left to be consistently four digits long).  Using our method described above would obviously create two separate codes for the same school that depended on the school year.  This is NOT what we want, as we want to be able to access school information over time.

The end-all answer I came up with was to pad these values myself with zeroes on the left so that each *District Code* and *School Code* is four digits long, which means our unique identifier will be nine digits long (counting the "_" separator).  Our school from the example above is now given the identifier of `0001_0111`.  And just for fun, let's call this identifier the `dpi_true_id`.  
