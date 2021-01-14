---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Game logic"
description: "Introduction to the serie about building an event-sourced game with Phoenix Liveview"
category: articles
tags:
 - "Event sourcing"
 - Elixir
 - DoctorP
published: false
comments: true
---

This article on the series of building an event-sourced game with Elixir Phoenix and LiveView is focused on the game logic.

## An event-sourced model

Prior to discussing the architecture of the game logic we need to understand what event sourcing is.

As [summarized by Martin Fowler](https://martinfowler.com/eaaDev/EventSourcing.html), it means that we "Capture all changes to an application state as a sequence of events."

In an event-sourced system when something occurs an event, or a list of events, is produced. It differs from more traditionally designed system where the new state is returned.

To get the current system state we go through all past events and apply them one by one to rebuild the state incrementaly.

This is the basic understanding we'll need to continue but I invite you to read Martin's article if you want to get all advantages and difficulties related to this pattern.

The game is event-sourced which means that when something happens events are produced and stored somewhere. Next time we want to act on the game we'll get all events and apply them one by one to rebuild current state before applying the action.


## Game states

The design of the game logic was heavily inspired by [Scott Wlaschin](https://twitter.com/scottwlaschin)'s book [Domain Modeling Made Functional](https://fsharpforfunandprofit.com/books/). The book examples are written in F#, a language I haven't got the chance to play with yet, but delivers interesting points applicable to Elixir nevertheless. It can also serve as a lightweight introduction to Domain Driven Design and it's worth a read.

The main point Scott makes is that by [modeling using the type system](https://fsharpforfunandprofit.com/series/designing-with-types.html) we are able to create a robust and documented system expressed in the language of the business.

One example of modeling with types is creating different types for different states. For instance an email address could be validated or unvalidated, leading to the creation of an `UnvalidatedEmailAddress` and a `ValidatedEmailAddress` types, and probably a workflow able to transform an `UnvalidatedEmailAddress` to a `ValidatedEmailAddress`.

Our game can be seen has a state machine, either waiting for players to register, waiting a round to start, or in a round. Instead of having one type, materialized by an Elixir module with a struct containing a lot of attributes to represent all states, Scott's advice leads us to create 3 types, `BetweenRound`, `InRound`, `Waiting`.

IMAGE OF STATE TRANSITION

I admit having been lazy here and could probably have given longer and more explicit names...

The three modules:

```elixir
defmodule DoctorP.Game.States.Waiting do

  # aliases and includes ommitted

  defstruct [
    teams: Teams.new()
  ]
end

defmodule DoctorP.Game.States.InRound do

  defstruct [
    :blue_deck,
    :red_deck,
    :teams,
    :scoreboard,
    :dictionary,
    timer: Timer.round_time()
  ]
end

defmodule DoctorP.Game.States.BetweenRound do

  defstruct [
    :blue_deck,
    :red_deck,
    :teams,
    :scoreboard,
    :dictionary
  ]
end
```

As you can see some structure attributes are coming with default values. Every time the game arrives in that state we want that value to be reset.
The best example is the `timer` in the `InRound` states: when a round starts the timer is always set to the expected round duration.

You can as well notice that `InRound` and `BetweenRound` states share a lot of attributes as we want to preserve the game data while doing back and forth between these two states. When moving from `InRound` to `BetweenRound` we want to keep each team score.

# Acting on a state

In order to keep it simple for now we'll be looking at acting on one game state and we'll look at game state transitions later.

Each of the game state modules contains a set of `handle\3` functions. They are used to act on the game by receiving the current state and a command, and they return some events to register the decision taken by the system. The third parameter will be discussed in another article later when we'll come to testing.

Here is an example of the `InRound` module which deals with action during the game:

```elixir
  def handle(%InRound{} = game, %Tick{}, \\ []) do
    Timer.decrement_time(game.timer)
  end

  def handle(%InRound{} = game, %MarkWordAsGuessed{}, opts) do
    current_team_id = Teams.current_team(game.teams)

    ActionResult.new()
    |> ActionResult.add(Dictionary.give_word_to_player(game.dictionary, Teams.current_player(game.teams), opts))
    |> ActionResult.add(Scoreboard.increment_team_score(game.scoreboard, current_team_id))
  end
```

The first function handles a `Tick` message, which is an elixir module with a struct, and delegates to the `Timer` module to take the correct action based on the current `game.timer`. `Timer.decrement_time` returns some events in an `ActionResult` structure.

```elixir
defmodule DoctorP.Game.Commands.Tick do
  defstruct []
end

defmodule DoctorP.Game.Timer do

  # ...
  @round_time 40
  @one_second 1000

  def decrement_time(1), do:
    ActionResult.new([%RoundEnded{}])

  def decrement_time(current_time) do
    time = current_time - 1
    ActionResult.new(
      [RoundTimeTicked.with(remaining_time: time, remaining_time_as_percent: time |> as_percent)]
    )
  end

  defp as_percent(time), do: time / @round_time

end
```

The second handle is here to deal with a `MarkWordAsGuessed` command. As we can see some of the logic is delegated to the `Dictionary` and `Scoreboard` modules and events are collected in an `ActionResult` structure here as well.




# Transition
Here is the code creating `BetweenRound` while transitioning from `InRound`. Don't bother too much the function name and parameters as we'll discuss them later.

```elixir
def apply_event(%InRound{} = state, %RoundEnded{}) do
    %BetweenRound{
      blue_deck: state.blue_deck,
      red_deck: state.red_deck,
      dictionary: state.dictionary,
      teams: state.teams,
      scoreboard: state.scoreboard
    }
  end
```

Each of the value here is a structure in its own module, `state.blue_deck` is a `BlueDeck` struct, `state.scoreboard` is a `Scoreboard` struct.

I've decided to keep each value as it was while moving from one step to the other but I could have gone one step further and add more types here to increase the robustness of the system and avoid programming errors later on. While in between rounds the scoreboard shouldn't be modified and I could have introduced a `LockedScoreboard` struct to make it clearer.

The code then would have looked like this:

```elixir
def apply_event(%InRound{} = state, %RoundEnded{}) do
    %BetweenRound{
      blue_deck: state.blue_deck,
      red_deck: state.red_deck,
      dictionary: state.dictionary,
      teams: state.teams,
      scoreboard: state.scoreboard |> Scoreboard.lock()
    }
  end
```

with `Scoreboard.lock` a function taking a `Scoreboard` and returning a `LockedScoreboard`.

# Going to the current state

Ok, this is nice, we are able to transition from one game state to the other, but we don't know yet how to get to the current state before 