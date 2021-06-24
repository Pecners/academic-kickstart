---
title: "Salesforce for Nonprofits: Improved Affiliation Tracking"
author: admin
date: '2021-06-24'
slug: []
categories: [Salesforce]
tags: []
subtitle: ''
summary: ''
authors: []
lastmod: '2021-06-24T14:35:24-05:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
draft: true
---

## Introduction

Let me start by stating that I am writing under the assumption that you, the reader, are familiar with Salesforce and the Nonprofit Success Pack (NPSP) implementation. NPSP is a fantastic resource for nonprofits, which combined with the 10 free licenses make Salesforce an extremely powerful and low-cost solution for CRM needs. One of the main drawback -- at least in my experience -- is that it is much more difficult to track the employment of your Contacts.

In a standard Salseforce implementation, every Contact would be linked to an Account, the place where they work. In NPSP, Contacts are linked to Household Accounts, a change made to facilitate donation tracking. Since the associated Account is no longer the Contact's employer, the Affiliation object was created to keep track of relationships between Contacts and Accounts, including employment but also volunteer positions, board service, etc.

The problem with this ostensible solution is that the Affiliation object is not at all intuitive to use for ordinary Users. First of all, it is what's known as a *junction object* that connects two other objects in a many-to-many fashion. This means that every Affiliation record will have an Account lookup field and a Contact lookup field, resulting in each Contact potentially having multiple Affiliations, and the same for Accounts. If a User then wants to update the employment of a Contact, they would have to create a new Affiliation record with employment information, and they would have to update the old Affiliation record that represented the previous employment of the Contact to indicate that it was not active (otherwise you would have multiple records of employment for the Contact).

This is too cumbersome a process for staff of a small nonprofit to keep up with, so one work-around is simply to create two text fields on the Contact object -- one for the employer, and one for the position title. Being text entry fields, however, invites data inconsistencies whereby the same organization will be listed many different ways, and as will the same position. Further, without field tracking set up, there is no historical record of employment, no indication of start or end dates.

Here's a specific example of the problem with this work-around, taken from my own experience. We track Contact employment as I described above with two text fields on the Contact object. We also track engagement in our programs by adding Contacts as Campaign members. Often I am asked to then break down the organizations served by us, which requires me to draw from our *Current Employer* field on the Contact object, but since it's a simple text field, there is no standardization for organization names, and thus no automatic method for grouping Contacts by their employer. Instead, I have to embark on a manual process of bucketing records by hand, which is less than ideal. Furthermore, when I report retrospectively on past programs, there is no way for me to link the Contact's employer at that time of the program because all I have is the current title and employer.
