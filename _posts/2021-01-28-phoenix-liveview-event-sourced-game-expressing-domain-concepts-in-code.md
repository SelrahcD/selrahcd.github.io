---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Expressing domain concepts in the code"
description: "In this article, we'll see how we can express domain concepts in the code, and reduce the size of the GameState module."
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
        <li><a href="/articles/phoenix-liveview-event-sourced-game-game-server">Game Server</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-acting-on-the-game-from-the-views">Views: Acting on the game from the views</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-building-views-states-and-reacting-to-changes">Views: Building the view's states from the events and reacting to changes</a></li>
    </ul>
</div>



In the past few articles, we've put a lot of code in the `GameState` module. 

The module is responsible for state rebuilding and all the game logic. It knows all details of handling card decks, timer, scoreboard, players, ...

The module size keeps growing, and it's time to start splitting, keeping things maintainable.

This article describes one way of splitting the code. In the next article, we'll see the second one.

# Splitting up

So far, the `GameState` module contains all the information in a map and all the logic to deal with adding a player, dealing card to a player, starting the timer, ...

I decided to introduce several modules, each responsible for one concept in the game, `BlueDeck`, `RedDeck`, `Scoreboard`, `Teams`, `Timer`, ...

Adding modules helps in several aspects. First, each domain concept becomes more explicit and is encapsulated in one place. Secondly, it improves testability: we can test each concept independently without going through `GameState`.

Let's look at what changes when it comes to the scoreboard module but first, let's get back to how we handle the score in our current system.

When a game starts, we want every team score set to 0. Because we are in an event-sourced system, this logic occurs in the `apply_event` function, more precisely in the clause matching with the `GameStarted` event.

```elixir
def apply_event(%{} = state, %GameStarted{}) do
  %{state | scores: List.duplicate(0, Enum.count(state.teams))}
end
```

Introducing the `Scoreboard` module allows to encapsulate the logic elsewhere and to express the intent more clearly:

```elixir
def apply_event(%{} = state, %GameStarted{}) do
  %{state | scoreboard: Scoreboard.for_teams(state.teams)}
end
```

At this point, the `Scoreboard` module looks like the following:
```elixir
defmodule Scoreboard do

  defstruct [
    scores: []
  ]

  def for_teams(teams) do
    %Scoreboard{scores: List.duplicate(0, Enum.count(teams))}
  end

end
```

# Incrementing team score

When a team wins a point, we want to keep track of it by producing an event. The `Scoreboard` module is an excellent place to put this logic. It makes for a more cohesive base code: everything related to tracking points stays inside the same module.

```elixir
def increment_team_score(scoreboard, team) do
  current_score = Enum.at(scoreboard.scores, team)

  [TeamGotAPoint.with(team: team, new_score: current_score + 1)]
end
```

In the `GameState` module, we can use this function whenever we need to increment a team score.

Let's take a detour and add a new clause for the `add` function in the `ActionResult` module we've defined in [the previous article](/articles/phoenix-liveview-event-sourced-game-handling-errors).

```elixir
defmodule ActionResult do
  # ...

  def add(%ActionResult{events: events}, other_events) when is_list(other_events), do:
    %ActionResult{events: events ++ other_events}

end
```

We now can add a list of events to an `ActionResult` directly. It avoids needing to encapsulate every return value from the modules we'll create from now on in an `ActionResult`.

We can now increment team score in the GameState module when we mark a word as guessed.

```elixir
def handle(state, %MarkWordAsGuessed{}) do
  ActionResult.new()
  |> ActionResult.add(Dictionary.give_word_to_player(state.dictionary, state.current_player)
  |> ActionResult.add(Scoreboard.increment_team_score(state.scoreboard, state.current_team_id))
end
```

I've not simplified the code too much to show that sometimes multiple modules are called while handling a message. Here we want to increment a team score and give a new word to the current player.

The `ActionResult` module makes it convenient to group events coming from several modules.


# Rebuilding Scoreboard state

We've seen that state contains the scoreboard in previous snippets, but we haven't seen yet how the scoreboard state is maintained.

We keep track of teams' scores with events here as well. `Scoreboard` can be event-sourced too.

```elixir
defmodule Scoreboard do
  # ...
  def apply_event(%Scoreboard{} = scoreboard, %TeamGotAPoint{data: %{team: team, new_score: team_score}}), do:
    %Scoreboard{scores: List.update_at(scoreboard.scores, team, fn _ -> team_score end)}
  end
end
```

And in `GameState`

```elixir
def apply_event(%{} = state, %TeamGotAPoint{} = e), do:
  %{state | scoreboard: Scoreboard.apply_event(state.scoreboard, e)}
```

# Going further

During this article's redaction, an idea popped up in my head that I haven't tried but is worth sharing.

`GameState`'s `apply_event` function now does very little. It takes the state and an event as parameters and dispatches to another module.

Looking at the previous example close to other pieces of code we see an emerging pattern:

```elixir
def apply_event(%{} = state, %TeamGotAPoint{} = e), do:
 %{state | scoreboard: Scoreboard.apply_event(state.scoreboard, e)}

def apply_event(%{} = state, %DictionaryShuffled{} = e), do:
  %{state | dictionary: Dictionary.apply_event(state.dictionary, e)}

def apply_event(%{} = state, %GaveWordToPlayer{} = e), do:
  %{state | dictionary: Dictionary.apply_event(state.dictionary, e)}
```

We could avoid writing these pieces of code for each event by generalizing. Something like:

```elixir
def apply_event(%{} = state, e) do

  Enum.reduce(state, fn {key, value}, state ->
      module = value.__struct__

      Map.put(state, key, apply(module, :apply_event, [state, e]))
  end)
end

```

I haven't tried this code, I don't know if it works, nor it's even a good idea.

We've seen one way of breaking apart the `GameState` module. In the next articles, we'll see another decision I've made to reduce its size further down and improve communication around domain concepts.