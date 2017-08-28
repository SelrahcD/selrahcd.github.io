---
layout: "post-no-feature"
title: Naming collision
description: "Use the same word everywhere and enjoy the mess."
category: articles
tags:
 - Dev
 - DDD
published: true
comments: true
---

## The context
I don't know if I already shared that I work at [Evaneos](http://www.evaneos.fr), a travel market place. Our job is to interconnect future travelers with travel agencies all over the world so they can benefit a trip tailor made by someone on site with a good knowledge of the destination. The agency's first job is to respond to a potential traveler request with a travel proposition after discussing the traveler's wishes.

Lately, I've been working on a rewrite of our routing system which for a given request selects the appropriate agency.

A request can be in one of these 3 forms - here I keep the common vocabulary shared in the company:
From itinerary: The traveler selects an example itinerary she is interested in. We route the request to the agency which created that itinerary.
From agency: The traveler decides to talk directly with an agency. I bet you guessed which agency will receive the request.
From scratch: The traveler indicates which destination she would like to travel to and we match her with the agency which can provide what we believe to be the best travel proposition according to the few information we have on what she wants to do.

The collision
During the rewrite we decided to provide some key insights to the people dealing with the settings of the from scratch algorithm.

One of this insights is the sales rate for the requests made from scratch.

During a meeting with business people when we were presenting that new tool someone noted that the sales rates shown were not the same as the one in the tool they were already using. As she pointed out, in the precedent tool what was considered from scratch were what the new tool was naming from scratch and from agency.

Boom.

We talked about it a few minutes but as this was not the point of the meeting we decided to postpone that discussion and to come back to it later.

## The feeling
This left me with the feeling of something wrong going on and as I kept working on the project that discussion was coming to my mind from time to time.
It made no sense to me that what we were considering as from scratch could also include from agency request type.

It took me a while, some sleepless nights, a lot of [showers](https://twitter.com/giorgiosironi/status/752091661795229700), and a week of holidays to finally get it.

We were simply not talking about the same thing. At all.

The old tool shows the sales rate for a travel proposition - which is different thing than a request for a travel proposition - that isn't based on an preexisting itinerary, hence "from scratch".
It makes sense to take into account what we call from scratch and from agent in the routing system to compute the sales rate of propositions made from scratch.

On one side we are talking about requests and on the other  about the resulting proposition.

## The history behind
It's been only a few months since we started to separate the concept of request from the one of proposition. Before that, and still now because of old habits, we were referring to this concepts as "a quote". This is a good example of Developper/Database Driven Design with all the [associates problems](https://twitter.com/cyriux/status/857877532779139072).

After all what is the difference between a request and a proposition if not a status changing from one integer to the other in a table row?

You can imagine the fun we had when we decided to track all propositions made for a given request. Yes, the first one isn't always the good one and there is some back and forth between the traveler and the agency.

I truly believe that sharing a word for this two different concepts is one of the main reasons behind the misunderstanding.

## The future forward
I think the solution is pretty straightforward. First, we really need to focus on using the appropriate names, request or proposition, when talking to each other.

I think we should also, at least, rename "from scratch" to "from destination" in the routing context. This would prevent the confusion and is coherent with naming pattern used by the two others which represent the page on the website where the request was made.

I said "at least" because I'm not convinced we should tie the domain logic to the graphic interface and I believe we can come up with something better than a word such as meaningless as from is.

As a start a request is not made from a destination but by someone who want to go to that destination. "A traveler makes a request for a trip to Italy", "For"*1 isn't a great word either but the direction seems to be correct at least. This needs some more digging.

Note that using "from" when talking about the proposition seems legitimate, the action direction is ok. "A proposition is built/prepared/conceived from an itinerary", "a proposition is built/prepared/conceived from scratch". Because an action takes a verb I think we would be better with including it in our discussions and in the code. This would add meaning and reduce the risk of another collision*2.

The next step is to work on the naming with the business people, trying to find something that makes sense and provide meaning. This will probably require to use verbs alongside preposition but this is for the best and that will reduce the risk of future collisions.

*1 I hesitated with going with "to" instead of "for". None of them are really convincing. Looks like a good warning that they probably aren't the best suited for the job.

*2 "That proposition built **from** scratch and travel starts **from** Paris". Not the best example ever but you get my point.

Hey! I'm on [Twitter](https://twitter.com/selrahcd) and if you feel like playing the "Jeu des mots" with me I promise we'll have some fun! You can comment below as well.
