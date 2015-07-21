---
layout: "post-no-feature"
title: Why are 404 pages still a thing ?
description: "Caches, 404 and missed business oportunities"
category: articles
tags:
  - Dev
  - Business
  - Web
published: true
comments: true
---

In this article every time you'll see "a 404 page" please read "The dumb 404 page with an apologize and a link to the home page". This doesn't concern 404 in other contexts, please keep - or start - using them in you APIs, for instance.

## Context

I had a very intersting discussion with [Rémi](https://twitter.com/remisan) and [Matthieu](https://twitter.com/maffpool), two of my coworkers, today about caching. We encounter some performances issues on the [Evaneos.com website](http://www.evaneos.com/) and were arguing about the fact to place some cache between our API and our frontend.

For the sake of the argument we took the example of our itinerary list. View it as a product list on some other online store.

As we all agreed that setting a cache-control header stating that the current list of products will greatly improve performance issue because a copy could be kept in memory in the frontend website two points were made against having a cache.

First one is that the user adding the product to the list might want to see it right away on the website. Funny thing is that this type of user is also interested in having a really fast website and as we are working in the same office we probably can come to an arrangement balancing time before display and performances.

Second one is the one I want to tackle down here : "What if a user clicks on the link in the list and arrives on a 404 page because the product is no longer available?"

Note : I'm not taking Etag system into account here because they are slower - you still need to make a call to the API - and as you'll see after don't help in anything anyway.

## You already have this problem
So, what happened?

A potential client sees a *cached* list of products. One item has been removed from the list, but the cache has not been updated yet because of the cache policy. The client finds her dream product, unfortunately that is the one we just removed, and clicks on it.
Let's simplify here and say we are caching lists and not individual items, but this changes almost nothing. We now have the information that this product is not available - API returned 404/410 for instance - and our front website displays a 404 page to our client. This is bad UX.

Let's try without cache.

A potential client sees a *non cached* list of products. She browses the list looking for her dream product. While she's looking at the list someone using our backend removes a product. Finaly she founds the product she wants - guess which one? - clicks on it and arrives on a 404 page. This is bad UX.

We already have this issue.

We can pretend that the time between product list presentation and the client choosing a product is so short that the chances that we are removing a product during this time are low and decide not to care, but we will probably have an issue later anyway (ex: when the user adds the product to the basket).

Matthieu made an interesting observation when I bothered him later with all this, the website is not the only access to a product page : even when we don't display a product in the list, search engines are still showing them anyway.

## What do we do now?

We have a problem. Facing it is a good starting point.

In my point of view I don't see why this second point should take us away from a massive performance boost because the problem is still here anyway without cache.

### What about that 404 page?

We probably can do something cleverer than just showing a 404 page. We know what the customer was looking for, why not display to her similar products for instance?

We should go to business people and ask them what business oportunity we could take on this page instead of having a stupid 404 error.

Saying all this I don't see why any online store would like to have dumb 404 pages and this is why I wonder why they are still a thing?

We can do better, improve UX, and as a business make more revenue.

This makes me think a lot about this quote by [Udi Dahan](https://twitter.com/udidahan) :

> "If you think you have a race condition, you don’t understand the domain well enough. These rules didn’t exist in the age of paper, there is no reason for them to exist in the age of computers. When you have race conditions, go back to the business and find out actual rules"

Race conditions are a hint that we probably don't know enough and should ask more questions to business people, in order to come up with a better solution.

Hey ! I'm on [Twitter](https://twitter.com/selrahcd) too, if you want to chat about this or something else. Feel free to comment below as well.
