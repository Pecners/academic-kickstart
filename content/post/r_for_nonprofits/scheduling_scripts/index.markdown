---
title: Schedule R Scripts with Windows 10 Task Scheduler
author: admin
date: '2020-07-28'
slug: scheduling_scripts
categories:
  - R for Nonprofits
tags:
  - R
  - Workflow
subtitle: ''
summary: ''
authors: []
lastmod: '2020-07-28T16:28:31-05:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
draft: true
---


{{% alert note %}}
The posts in the *R for Nonprofits* series are written for the R user who doesn't have computer science or coding background before R.
{{% /alert %}}

Here's a common scenario -- you write an Rmarkdown report that will need to be rendered at regular intervals as the underlying data is updated.  In my role, this happens a lot with forms.  We put out A LOT of forms to survey participants in our programs, get feedback on our services, etc.  Some of these surveys may stay live for the entire year, while others have a very specific timeline, and in both cases, it is beneficial to run the R script that compiles the results into a report at regular intervals.

If you're on a Windows machine like I am (specifically Windows 10), a little bit of Googling will lead you to the Windows Task Scheduler (and also the `taskscheduleR` package, to be discussed below).  Task Scheduler allows you to schedule tasks (e.g. running an R script) with a range of settings.

Now, full disclosure: I stumbled my way through Task Scheduler before I learned of the `taskscheduleR` package, and so I will treat the two in that order. This also makes sense because  `taskscheduleR` is doing the same thing, just within RStudio.

## Getting Set Up

To begin, let's create a reproducible example so we can walk through the process with the same code. 

First, we will want to set up a project directory with the following steps:

1. Within RStudio, choose File > New Project.
1. Select New Directory.
1. Select New Project.
1. Enter a *Directory name:* -- this will be the folder name. For consistency I'm going to use `task_scheduler_example`, which I will reference throughout this post.

If you were successful, RStudio should have opened up a fresh session for you with an empty environment and a *Files* tab with a single item, `task_scheduler_example.Rproj`.

{{% alert note %}}
When I was getting started, I didn't organize my work into Projects, and it bit me in the end.  Don't make the same mistake.  Organize your work with Projects (and also Git, but more on that in future posts).
{{% /alert %}}

## The Task Scheduler Way

Probably the easiest example we can use is to create a log that records every time the script runs.  Depending on your project and infrastructure, there are many ways to do this that might make more or less sense given different specifications.  For our purposes here, I will write our log to a CSV file.

### Creating Our Script

First, create a new R Script file and save it as `schedule_script.R`.  

The code below will get us started, but it won't work as we want quite yet -- see if you can spot why.


```r
# Capture the time the script runs

last_run <- Sys.time()

# To write to a CSV file, we need a dataframe

log <- data.frame(last_run)

# Write to CSV file "log.csv"

write.csv(log, file = "log.csv")
```

This simple code will record the time the script runs and assign it to the variable `last_run`.  Then, the dataframe `log` is created from `last_run` -- log is a dataframe of one variable and one observation.  Finally, `log` is written to a CSV file in our directory called `log.csv`.

This script won't work for a log yet because it only records a single time, the last time the script was run.  What we will want instead is to record the time and append that to our running `log`.  

To achieve this, we can expand on our starter script above.  First, since our log will be stored in the CSV file, the first thing our script should do is check for the file in our directory.  If it finds the file, we can move on, but if it doesn't, that means we'll be starting a new log and won't need to append to an existing log.


```r
# Check if "log.csv" exists

if(file.exists("log.csv")) {
  
  # Read in current log and assign to `log`
  
  log <- read.csv("log.csv")
  
  # Capture the time
  
  last_run <- Sys.time()
  
  # Add a row to our one-column dataframe
  # Assign it the value held in `last_run`
  
  log[nrow(log) + 1, 1] <- last_run
  
  # Re-write "log.csv"
  
  write.csv(log, file = "log.csv")
  
  
} else {
  
  # This is case where "log.csv" doesn't exist
  # So, we're starting a new log
  
  # Capture the time the script runs
  
  last_run <- Sys.time()
  
  # To write to a CSV file, we need a dataframe
  
  log <- data.frame(last_run)
  
  # Write to CSV file "log.csv"
  
  write.csv(log, file = "log.csv")
  
}
```

Now our script is first checking if `log.csv` exists in the directory -- if it does, then the log is read in as `log`, a new run time is captured in `last_run`, the new time is added after the last row in `log`, and then `log.csv` is overwritten with the new data.  If `log.csv` isn't found, then the original script will be run, and `log.csv` will be created.

We are now set up to capture every time the script runs, so we can move on to actually scheduling this bad boy. (Be sure to save `schedule_script.R`.)

### Scheduling the Script to Run

To open Task Scheduler, type *task scheduler* in the search bar next to the windows icon.

![Search for "task scheduler"](img/search_task_scheduler.PNG)

Once you have Task Scheduler open, you should see a pane on the right that has a list of Actions -- select *Create Basic Task...*.  The *Create Basic Task Wizard* should have popped up, and the first page is asking for a Name and Description -- Let's name it *Basic R Log Script* and give a short description.

When you're ready, click *Next*.

![Task Name and Description](img/gen_task_info.PNG)

The next page allows us to select Trigger settings -- these will tell the computer when you want the script to run. This is arbitrary for our purposes, but I'm selecting *Weekly*.  Once you've made your selection, click *Next*.

Now we are given settings that are specific to the *Weekly* cadence. When you select the *Start* date and time, that will be the time the script runs on each day that meets your other criteria.  I am writing this on 08/02/2020 at 3:20:08 PM, and I'm going to leave that as-is. I will also select *Monday* and *Wednesday*, so the script will run every week on Monday and Wednesday at 3:20 PM. Click *Next*.

The Action we want to perform is *Start a program* -- we will be starting R to run our scrip.  Click *Next*.

{{% alert note %}}
This was the most confusing part for me because I didn't understand the terminology of program, script, and arguments.
{{% /alert %}}

The *Program/script* you need to enter is the file path to your version of `Rscript.exe`, and if your path has spaces in it as mine does, you need to wrap the whole path in double quotes. You can see mine below:

![Rscript.exe File Path](img/gen_task_info.PNG)

The important thing to understand is that Rscript.exe is a program that runs an R script -- so, you need to pass the specific script as an argument. Just like we just did for `Rscript.exe`, we need to provide the full file path and wrap it in double quotes if there are spaces in the path. 

Click *Next* and review the information -- if everything looks good, click *Finish*.  Just like that, we have our script scheduled to run!

### Testing

Rather than wait for our next scheduled runtime to see if everything is working as we want, let's go ahead and manually run our task right now. 

First, find our new task within the *Task Scheduler Library* -- which you'll see in the left pane below the *File* menu. Once you click on the library, you should see a list of tasks scheduled to run on your machine.

Find our *Basic R Log Script* task, and click on it. With the task highlighted, on the right panel under Actions, click *Run*. You might see a Command Prompt window open briefly, and you'll see the Status of our script change from *Ready* to *Running*. You might not see it change off the *Running* status until you click *Refresh* on under actions.

Once you do that, you'll see a cryptic `(0x1)` under the *Last Run Result* for our task.  Now if you're like me, your first instinct is to start Googling for this code because you can see other tasts have the result `The operation completed succesffully. (0x0)`. So, this would imply we had an error since we didn't get that succesful message, and in fact `(0x1)` does indicate a function error in the task.

Your next instinct might be to open your script back up and inspect it for the faulty code, but let me stop you there.  It is often hard to find these errors in code because the code could perform perfectly as it is, but when called from Task Scheduler, it loses the environment in which we wrote and tested the code.  So, we would be best served by running the code in a similar method to how Task Scheduler runs the code -- and this can be accomplished with Command Prompt.

### Debugging

My greatest source of frustration in scheduling tasks by far had been identifying errors.  The "results" provided by Task Scheduler are incredibly cryptic and difficult to parse.  That said, Task Scheduler basically just runs scripts as we would from Command Prompt, and there we would at least see R error messages.

Open up Command Prompt by searching for it as we did with Task Scheduler.  If you're new to Command Prompt, don't worry, this will be simple.  We are going to run a single line of code and examine the output.  This line of code will consist of two things:

1. The Program we are going to run -- in this case, our `Rscript.exe` program.
1. The Argument that tells `Rscript.exe` which script to run -- this will be our `schedule_script.R` file.

You can write out the file paths, or you can go back into Task Manager and copy what you already entered there by double clicking on our task, clicking on the *Actions* tab, and double clicking on the single action we defined.

You will put the full `Rscript.exe` path first, followed by a space, and then the full path to your `schedule_script.R` file (and don't forget to enclose in double quotes if there are spaces in your path). 

Once you have those two paths completed, execute the command by hitting *Enter*.






## The *taskscheduleR* Way
