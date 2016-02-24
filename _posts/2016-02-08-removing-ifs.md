---
layout: post-no-feature
title: Removing ifs
description: "What if we remove some if statements ?"
category: articles
tags:
  - Dev
  - OOP
published: false
comments: true

---

I'm not a big fan of if statements.

They make source code harder to reason about, force us to write more test cases and increase [cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity)...

We even debated with some colleagues on the way to lunch if it would be possible to make an application without any one of them. We finally agreed that it would be very difficult if the application had to enforce some business rules. Anyway, that's not the point.

In some cases it's totally doable to remove some if statements. Here are a few options.

## Keeping them outside of the application

The application I work on has to be integrated with some external services. Some of them ping us on an a callback URL with an Http call. This is a fairly common scenario.

I had to work on the controller action dealing with those callback calls. **The controller action**. Yep. We have only one action for several externals services. Therefore the major part of the code is dealing with trying to recognize who is calling, base on the shape of the message. Coming with a lot of ifs.

A simpler solution would have been to create one action for each external service, pushing the if statements outside of our code directly into the service configuration.

## Depency inversion principle

## Null object pattern

outside
DI
null object



Hey! I'm on [Twitter](https://twitter.com/selrahcd), if you want to discuss about OOP feel free to come by and say hi! You can comment below as well.


