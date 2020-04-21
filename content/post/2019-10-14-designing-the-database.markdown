---
title: Designing the Database
author: Spencer Schien
date: '2019-10-14'
slug: designing-the-database
categories:
  - Database Design
tags: []
subtitle: ''
summary: 'Setting up the initial database schema'
authors: []
lastmod: '2019-10-14T14:09:45-05:00'
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

# Starting with a Unique List of Schools

The purpose of this database is to analyze *school* data.  So, it would make sense that we would start with schools.  

As I mentioned in my [previous post](https://spencerschien.info/post/building-a-relational-database-in-r/), my first step down the path to any sort of relational database was in Power BI.  Basically, I would load into Power BI an Excel file of school data downloaded from the Wisconsin Department of Public Instruction's website, and I would connect that table to a table of our own program data -- for instance, I connected School Report Card data tables with our own data tables of schools to which we provided services.  

In order to connect the tables like this in Power BI (or any relational setup), you need to have columns by which you will match the data.  For my example, this meant matching schools from the state's report card table with schools from my program table.  I will explain in detail how I ended up with the unique ID that I call the `dpi_true_id` in my post on the `schools` table, but for now suffice it to say that the optimal solution to matching records was across all tabls was to formulate my own ID based on a combination of the `School Code` and `District Code` given to each school by the state.

