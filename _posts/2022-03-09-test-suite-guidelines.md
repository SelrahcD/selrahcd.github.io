---
layout: "post-no-feature"
title: "Test suite guidelines"
description: "When looking at a test harness, it's sometimes hard to decide which type of test to write, what it should cover, how we should write it. I believe we would stop losing time and remove frustration by adding guidelines for our test suites."
category: articles
tags:
 - Testing
 - Unit tests
published: true
comments: true
---
Yesterday I watched again the ["Breaking up (with) your test suite" talk](https://burritalks.io/talks/justin-searls-breaking-up-with-your-test-suite/?utm_medium=referral&utm_source=chorip.am&utm_campaign=choripam_test_suite_guideline_article) by [Justin Searls](https://twitter.com/searls), and it resonated with an idea I recently had while working on a project for one of my clients. I even suspect that my idea is actually Justin's one and that my brain conveniently remembered it when I needed it.

I planned to write about this for a while, and I guess it's a sign that I should stop postponing.

## Backstory

I worked with a colleague on the Angular front-end part of a project, adding a feature, and wanted to write some tests. I have been working on back-end stuff for some time now, and I'm not used to writing tests for components. We went around with my pair partner, looking at all the test files available, and they all looked quite similar and different at the same time. Some tests were exercising the kind of code we were about to implement but in a way that looked strange to us. It wasn't convincing, but we couldn't decide ourselves to write the tests differently. After all, we were just two back-end devs on a front-end codebase new to us. Who were we to change the way to test that code? We probably didn't understand the choices made by previous developers. Anyway, we were paralyzed.

We needed some sort of documentation explaining the rationale behind the different types of tests, a guide to select which one to write, some guidelines about how to write them.

Test suites were organized by directories, each containing some type of test. As expected, some tests weren't looking like the others in the same directory, but it was a start. We could have a README file in each directory explaining what tests should look like in there. This is the idea I wanted to talk about. It's relatively simple and can probably avoid losing time, improve team speed, and remove some frustration.

As an alternative, we could use [Architecture Decision Record](https://github.com/joelparkerhenderson/architecture-decision-record). In my opinion, having the description file closer to the tests is better because it makes it easy to find when needed.

## What should we find in the README file

The README file should be beneficial to newcomers, more junior developers, or even the ones who decided the test strategy, reminding us why we made these choices.

![Sandi Metz's SUT as a capsule](/images/2022-03-09-test-suite-guidelines/capsule.png)

I really like [Sandi Metz's](https://twitter.com/sandimetz) description of the [system under test as a capsule](https://burritalks.io/talks/sandi-metz-the-magic-tricks-of-testing/?utm_medium=referral&utm_source=chorip.am&utm_campaign=choripam_test_suite_guideline_article) we can send incoming commands and queries to and which, in turn, can send outgoing queries and commands to something else. I think the test suite guide should explain how incoming messages are generated:
* Are we allowed to call SUT methods directly?
* Or should we go through something that exercises the UI and help us pretend we're a real user acting on a component?
* Should we send an HTTP request to an endpoint?
* Should we use framework provided tool to pretend we've sent an HTTP request?
* Should we call a CLI?

The guide should probably tell us what we should do about the other side of the capsule. 
* Are we allowed to stub dependencies? If so, which ones?
* Should we only stub dependencies doing IOs?
* Should we allow some IOs? Are database queries allowed but HTTP calls disallowed?
* Should a controller test exercise the domain code, or is it sufficient to know that we called some method or fired some command?

You probably can imagine a lot of variations just around these two themes.

Justin Searl came up with other really interesting points we probably should include as well.

The first one is a description of the confidence each type of test should give us. For instance, end-to-end tests verify that all pieces of the software are working well together. Adapter tests let us know if a contract with a dependency is still respected after an upgrade. Consumption tests prove that the behavior we are responsible for works correctly.

Knowing the gained confidence of each test type helps decide which test to write. If we want to be confident about multiple things, maybe we need to use various kinds of tests.

Note that it also drives, or enforces, the architectural choices. Say you want to ensure that an adapter behaves appropriately. We could use an end-to-end to prove that, and it would be costly to write, maintain, probably slower than needed, and could fail for multiple reasons. Once we decide that we gain confidence around adapter behavior using adapter tests, we will need the adapter to be testable on its own. To do this, we will probably add some boundaries around it.

Another idea expressed in Justin's talk is to know which understanding each type of test gives us. Here we're more interested in feedback on the design of our application:
* If our end-to-end tests are individually slow, maybe workflows are too complex for our users. 
* If our consumption tests are hard to write, our service is probably hard to use, and we could improve the interface.
* If our contract tests with other teams are often failing, it might be a signal that our priorities aren't aligned.
* Adapter tests give us clues about our usage of third parties, which in turn help us know what we should look for if we want to switch to another provider.

Justin also talks about indicating who the "user" is in each test. Is it a real user, another piece of code, our application talking to a dependency?
It relates closely to the messages each test can send to the capsule.

He also shares some guidelines and warning about each type of test. These could probably be included in the readme file too.

Another valuable idea would be to keep one test always clean for each suite, following the rules and demonstrating the best practices. It would act as an exemplar we could refer to to get a better understanding of the content of the readme. Of course, the readme file links to this test file. This idea comes from the book "Living documentation" by [Cyrille Martraire](https://twitter.com/cyriux/).


## In short

The readme file should guide us when deciding which test to write and how to write them.
Some ideas of useful information to include are:
* Which confidence are we getting from it
* Who is the user
* What are the incoming and outgoing messages
* What understanding are we getting from the test
* An exemplar of what's considered a good test
