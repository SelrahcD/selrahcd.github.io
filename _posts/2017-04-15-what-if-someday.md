---
layout: post-no-feature
title: What if someday...
description: "Don't pretend you know what will come next"
category: articles
tags:
  - Dev
published: true
comments: true

---

"What if someday..."

These three words are probably one of the main causes of accidental complexity and late delivery in the software industry. As software developers we always try to guess what the future will be, to anticipate future needs, in order to be prepared. The issue is that it's something we suck at.

We try to predict what will be the next features needed and doing so we add a lot of complexity to the software we build and maintain.

Nothing comes for free. Adding that new frontend framework, that queuing system or that cool design pattern you just learned about to the project has a cost and the team will have to support it in the long run. Building it this way will probably be longer than a simpler solution. You'll need to have someone around able to understand it and to maintain it. You might have to adapt your tooling for deployment, testing and logging. You may see your build time increase. You can expect to deal with some new failures you weren't aware of. This are a few examples but I'm sure we can find some others.

So, here a few other questions, as valid as the previous one:

What if the day we have to scale for a large number of users never comes?

What if by the day we actually have to offer offline service we can use some other tool better suited for that need?

What if we've imagined all the possible future requirements and made a system that can deal with them all except one  That one we have to implement after all, than one we can't introduce because we've been too clever and have created a system locked by its abstractions.

Sounds familiar?

Deciding to implement something based on assumption is basically taking a bet, which means there is probabilty to lose something, probably time and/or money. Our job as software developper is to reduce the risk of building something wrong or useless and to minimize the loss in case we built it wrong after all.

Using a simple solution, or even a boring one, will allow to deploy the feature earlier than trying to build a full system able to cope with everything.
This means we'll deliver value earlier, possibly making money earlier. This also means we'll have user feedback earlier and we'll be able to take advantage of the feedback loop to test our assumptions and see if we're building the right thing. This is where the heart of agile is.
We've also saved some time we can use to build something else on another part of the system or building a prototype of the more complexe solution and learn about it.

Striving for simplicity is a good way to maximise the value of our system.

Next time you have to choose whether you should introduce a new tool to your stack please take the time to think and reflect on all the tradeoffs coming along.

Hey! I'm ranting on [Twitter](https://twitter.com/selrahcd) too and you can come and tell me I'm wrong over there if you want to! You can comment below as well.