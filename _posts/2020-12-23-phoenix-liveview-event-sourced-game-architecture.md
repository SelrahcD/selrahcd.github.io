---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Architecture"
description: "Overview of the architecture for DoctorP, an event-sourced game built on top of Phoenix LiveView"
image: /images/2020-12-22-phoenix-liveview-event-sourced-game-architecture/doctorp_macro.png
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
        <li><a href="/articles/phoenix-liveview-event-sourced-game-making-game-states-explicit">Game logic: Making game states explicit</a></li>
    </ul>
</div>

In this article, we'll cover the macro architecture of the DoctorP project.

The application is split into three parts: game logic, execution, and views.

## Game logic
Game logic is pure business logic and is not concerned with the runtime properties of the system. Here seats the code expressing the game's rules, written as much as possible using game terminology.

It's written following the functional core imperative shell pattern, which means that all the code here is pure.

Game logic receives a command, the current game state, and everything else it might need to do its work.
The game rules are applied, returning the result without producing any side effects. In a non-event-sourced system, the result would be the new game state. Here, as we are doing event sourcing, the code returns a list of events.

Separating the game logic from the execution keeps our business logic free from runtime considerations. We can defer decisions on how we want our system to run to a later point. It also provides the ability to write fast-running unit tests without messing with processes.

## Execution
In the execution part, we specify the runtime properties of the system.
I've decided that a GenServer, `GameServer,` will back each game room. 

`GameServer` serves different purposes:
It manages all commands and queries related to one game room. Having one process for each game room improves reliability. A game room can't be blocked by something taking time in another game room, and in case of a crash, only one game room is affected.
It stores all events produced by the actions taken in the game room. As this is a game and keeping all the data is not adding a lot of value, I've decided to store events in the process. One major downside to this solution is that we cannot get back to where the game was in case of a crash or server restart. Everything is lost.

`GameServer` are supervised using a dynamic supervisor. Because multiple `GameServer` can be up simultaneously, a registry keeps the relation between game id and process id using the "via tuple mechanism."

## Views
Views use Phoenix Liveview, which provides the real-time capabilities needed for the game with server-rendered HTML. No need to write a single line javascript.

I've created a view for each phase of the game: waiting for players to arrive, playing the game, and displaying the result. An additional view seats on top of them and decides which one to show.
I've had difficulties trying to use LiveView components in place of the game phase views, but I guess an alternative implementation could use them.

All views use events produced by the game logic to decide what to show.
When a view is mounted, it fetches all past events from the `GameServer,` builds its own data structure of what to present, and renders. During the game events are published by the `GameServer'via the PubSub mechanism offered by Phoenix. Each view subscribes to the game channel and waits for new events to arrive. Once an event is received, the data structure is updated, and the view is modified accordingly.

Here is a sketch of the macro architecture of the project, summing up what was said so far.

![Architecture sketch](/images/2020-12-22-phoenix-liveview-event-sourced-game-architecture/doctorp_macro.png)

We'll cover some parts of this project more in-depth in other articles of this series. Let me know if you'd like me to cover some specific aspects.

## Bibliography

- [To spawn, or not to spawn ? - Saša Jurić](https://www.theerlangelist.com/article/spawn_or_not): Saša's blog post is one of the main sources of inspiration for the architecture of this project.