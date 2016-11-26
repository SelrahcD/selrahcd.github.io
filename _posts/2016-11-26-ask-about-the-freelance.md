---
layout: post-no-feature
title: Ask about the freelance
description: "You don't know the full story until the end of it."
category: articles
tags:
  - Dev
published: true
comments: true

---

A few days ago I was involved in a [discussion on twitter about a modeling problem](https://twitter.com/webdevilopers/status/798566284615094272). As a support for the discussion we were talking about a time tracking system and the concept of time sheet. I proposed two ways I would model the requirements. I indicated that I would choose one solution over the other if the concept of time sheet was really relevant for tracking, and that I couldn't find an example where it would be the case.

A few hours later I thought that a freelance would need to have more than one time sheet opened at the same time if she worked for several clients.

At work we also have a concept of freelances that wasn't really taken into account during the creation of the model which forces us to do some workarounds in order to deal with them.

This two things in mind it stroked me that freelances make for great personas when you're speaking with business people and trying to find out the properties of a system. 

Freelances have two really interesting properties:

* The can work for several companies/groups at the same time.
* It's easy to think they'll leave.

This two properties open for really insightful discussions:

* What should happen when a user leaves the system?
* Is something owned by the user or the group she's belonging to?

I have the impression that the leaving property all by itself helps discovering corner cases in the domain and prevents making modeling mistakes. 

It's never just someone who stops using the system. 

For instance we probably have to transfer something linked to a leaving person to someone else in the same group. Does it means that this thing is owned by the group and is taken care of by a member of the group at a given moment? Therefore should we model explicitly the relation between that thing and the group (the thing is owned by the group and taken care of by that person) or is the relation between the thing and the person enough (the thing is owned by the group because the thing is taken care of by the person who belongs to the group)?

Asking about what happen in the end can help understand what are the true relationships between domain concepts.

I guess that this observation can be generalized to all model objects, not only to person.

> Asking for what happen to something reaching an end-of-life state leads to better insights as you don't know the full history until you know the end of it.


Hey! I'm on [Twitter](https://twitter.com/selrahcd) and if you don't want to consider this as a finished thing I'll be happy to talk with you about it there! You can comment below as well.