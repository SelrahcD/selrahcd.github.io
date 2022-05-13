---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Introduction"
description: "Introduction to the serie about building an event-sourced game with Phoenix Liveview"
category: articles
tags:
 - "Event sourcing"
 - Elixir
 - DoctorP
 - Liveview
 - Phoenix
published: true
comments: true
---

<div class="series">
    <p>This article is part of a series on building an event-sourced game in Elixir with Phoenix Liveview. Other articles are:</p>
    <ul>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-intro">Introduction</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-architecture">Architecture</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-event-sourced-model">Game logic: an event sourced model</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-handling-errors">Game logic: handling errors</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-expressing-domain-concepts-in-code">Game logic: Expressing domain concepts</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-game-server">Game Server</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-acting-on-the-game-from-the-views">Views: Acting on the game from the views</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-building-views-states-and-reacting-to-changes">Views: Building the view's states from the events and reacting to changes</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-building-decrementing-the-timer">Decrementing the timer</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-unit-testing-patterns">Unit testing patterns</a></li>
    </ul>
</div>

I've been playing with Elixir for a while now. I've [created a Twitter bot](http://schtroumpsify.selrahcd.com), but I wanted to explore further what Elixir and Phoenix could help build for real-time collaboration between people. I was also curious about building a domain model with a functional programming language.

During the first French lockdown, I had the idea of a project that could be a good experiment: a game. As we had some fun playing [Doctor Pilule](https://www.docteurpilule.com/), a French board game, I decided to build a digital version helping us to play with friends and family remotely.

## Doctor Pilule

The game is quite simple. Players are split into several teams, and each round, one player tries to make her other team members guess as many words as possible. The trick is that all players are given two uncommon handicaps, one spoken (ex: start all sentences by "I might sound crazy but...") and one driving actions (ex: you think you are the Eiffel tower).
The first team to reach 20 guessed words wins.

## Why this game?

First, as I said, it's fun to play, and we needed some fun this year. It also comes with some interesting challenges to deal with, which are making for a good experiment:
it's real-time
it needs to deal with a timer
all players don't see the same thing at the same time (ex: the word to be guessed)
it's better if you play it with video
game's logic is complex enough to tinker with building a model with functional programming way without being overwhelming

## And then?

I felt I could build something relatively quickly, helped by Phoenix Liveview and be able to play with friends after a few weeks. 

Of course, it didn't work out as expected.

As with many side projects, the fun part is not in delivering something but in learning. I spent a lot of time playing around, trying stuff, and being stuck and stubborn about solving problems not providing real value in the end—things we should probably avoid while at work; however, not so bad in a side project.

I still didn't reach the video part and still have things I'd like to play with. Nevertheless, I managed to build the game logic, display relevant information to players in real-time, event-sourced the system, and learn a few things along the way. This blog post series is about some of these learnings.

