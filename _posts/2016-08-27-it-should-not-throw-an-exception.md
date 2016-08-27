---
layout: post-no-feature
title: It should not throw an exception
description: "Trying to find better names for test methods"
category: articles
tags:
  - Dev
  - tests
published: true
comments: true
---

I'm very interested in living documentation because it provides some great values. First, you finally have documentation, which is up to date and under version control. The other great thing about it is that it forces to look at the code through another perspective : through the eyes of a non developer person.

A few weeks ago I experimented and extracted documentation from code and tests. Tests were used to describe an object properties, its business rules. Some test method names were feeling a bit to technical to me and were not making sense to business people.

In the case of a DatePeriod object two tests names were odd :

* it is initializable
* it throws an exception if end date precedes start date

The first one is created automatically by PhpSpec in order to ensure the DatePeriod class is created. This test case should be removed as soon as another test case is created as it doesn't provide value anymore.

The second one is more interesting. It doesn't describe what the DatePeriod does but how it does it. This is a form of coupling between the test case and the implementation. [As seen before](testing-for-behaviour-not-for-implementation) coupling between the two of them is not a good idea because it makes harder for coming up with another implementation. In that case throwing an exception is probably the best implementation though.

What could be a better name then? We're looking for something that speaks to business people. "It doesn't allow end date to precede start date" does the job here.

I think looking at the code through the prism of documentation really helps making it better. I'm always amazed to see how business understanding, modeling, testing and documentation really fit together - 4 sides of the same coin (Sorry).

Hey! I'm on [Twitter](https://twitter.com/selrahcd) I only throw some bad jokes but no exception. Feel free to comment below as well