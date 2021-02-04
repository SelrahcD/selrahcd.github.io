---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Making game states explicit"
description: "Type system can help express a system capabilty, what can be done, or prevent from misusage. This article shows how theses ideas were applied to express the game states."
category: articles
image: /images/2021-02-04-phoenix-liveview-event-sourced-game-making-game-states-explicit/state_transitions.png
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



In [the last article](/articles/phoenix-liveview-event-sourced-game-expressing-domain-concepts-in-code), we've seen the first design choices I've taken to reduce the size of the `GameState` module. Now, it's time to see the second decision I've made.

During this project, I wanted to experiment with expressing business logic with the type system in a functional language.

## Business logic as types

While creating types to express business logic is something I've seen applied in OOP codebases, I've never played with that idea in a functional language.

This idea is presented in [Scott Wlaschin](https://twitter.com/scottwlaschin)'s book [Domain Modeling Made Functional](https://fsharpforfunandprofit.com/books/). The book examples are written in F#, a language I haven't got the chance to play with yet, but delivers interesting points applicable to Elixir nevertheless. It can also serve as a lightweight introduction to Domain Driven Design, and it's worth a read.

The main point Scott makes is that by [modeling using the type system](https://fsharpforfunandprofit.com/series/designing-with-types.html) we are able to create a robust and documented system expressed in the language of the business.

One example of modeling with types is creating different types for different states. For instance, an email address could be validated or not validated yet, leading to the creation of `UnvalidatedEmailAddress` and `ValidatedEmailAddress` types, probably a workflow, able to transform an `UnvalidatedEmailAddress` to a `ValidatedEmailAddress`.

The game can be seen as a state machine, either waiting for players to register, waiting for a round to start, or in a round. Instead of having one type, materialized by an Elixir module with a struct containing many attributes to represent all states, as we have so far, Scott's advice leads us to create three types, `BetweenRound`, `InRound`, `Waiting`.

I admit having been lazy here and could probably have given more extended and more explicit names.

The three modules:

```elixir
defmodule States.Waiting do

  # aliases and includes omitted

  defstruct [
    teams: Teams.new()
  ]
end

defmodule States.InRound do

  defstruct [
    :blue_deck,
    :red_deck,
    :teams,
    :scoreboard,
    :dictionary,
    timer: Timer.round_time()
  ]
end

defmodule States.BetweenRound do

  defstruct [
    :blue_deck,
    :red_deck,
    :teams,
    :scoreboard,
    :dictionary
  ]
end
```

Each module declares a structure with the precise information needed to do its job correctly. We can get rid of the permissive map we were using until now.

We see some structure attributes are coming with default values. Every time the game arrives in that state, we want to reset that value.
`timer` in the `InRound` state is probably the best example: when a round starts, the timer is always set to the expected round duration.

We can also notice that `InRound` and `BetweenRound` states share many attributes as we want to preserve the game data while doing back and forth between these two states. When moving from `InRound` to `BetweenRound` we want to keep each team score.

## Grouping behaviors into states

Now that we have three states, we can move functions related to each of them in the appropriate module.

The handle function matching with the `MarkWordAsGuessed` message can move to the `InRound` module, the one dealing with `AddPlayer` in `Waiting`, and so on.

```elixir
defmodule States.Waiting do
	# ...

  def handle(%Waiting{} = waiting_room, %AddPlayer{player_name: player_name}) do
  # ...
  end

end


defmodule States.InRound do
  #...

  def handle(%InRound{}, %MarkWordAsGuessed{}) do
  #...
  end

end
```

An interesting thing to note here is that thanks to the introduction of structures, we can pattern match the current state. It makes it more straightforward which actions can be taken on each state.

 Furthermore, it will prevent any action made against the wrong state. If `MarkWordAsGuessed` message were to be dispatched when we're in `Waiting` state, the application would crash. 

If we want to avoid crashing, we can add a clause, matching on all unmatched messages, that returns an error:

```elixir
def handle(%Waiting{}, _), do:
  ActionResult.error(:action_not_allowed)
```

We also have to group the state mutation functions.

```elixir
defmodule States.Waiting do

  def apply_event(%Waiting{} = state, %PlayerJoinedTeam{} = e), do:
    %Waiting{state | teams: Teams.apply(state.teams, e)}

  def apply_event(%Waiting{} = state, %PlayerLeftTeam{} = e), do:
    %Waiting{state | teams: Teams.apply(state.teams, e)}

end

defmodule States.InRound do

  def apply_event(%InRound{} = state, %TeamGotAPoint{} = e), do:
    %InRound{state | scoreboard: Scoreboard.apply_event(state.scoreboard, e)}

end
```

Here, we pattern match on the current state structure, and functions return a structure.


## Transition between states

We now have multiple states and cleaned up the `GameState` module.

All examples I've shared so far show events that, when applied, stay in the same state. This is great, but we still need to transition from state to state, going from `Waiting` to `BetweenRound` and doing back and forth between `BetweenRound` and `InRound`.

The solution is simple. When needed, the `apply_event` can return the structure of the next state.

```elixir

defmodule States.Waiting do

  def apply_event(%Waiting{} = state, %GameStarted{}), do:
    %BetweenRound{teams: state.teams, scoreboard: Scoreboard.for_teams(teams)}

end

defmodule States.BetweenRound do

  def apply_event(%BetweenRound{} = state, %RoundStarted{}) do
    %InRound{
      blue_deck: state.blue_deck,
      red_deck: state.red_deck,
      dictionary: state.dictionary,
      teams: state.teams,
      scoreboard: state.scoreboard
    }
  end

end

def module States.InRound do
  def apply_event(%InRound{} = state, %RoundEnded{}) do
    %BetweenRound{
      blue_deck: state.blue_deck,
      red_deck: state.red_deck,
      dictionary: state.dictionary,
      teams: state.teams,
      scoreboard: state.scoreboard
    }
  end

end
```

I'm still puzzled about directly using another module structure in a different module. For instance, I don't like that `Waiting` module knows how to create the `Scoreboard` for the `BetweenRound` structure. It would probably be better to introduce a function in each module,  some sort of constructor, dealing with all the details. For lack of a name I liked, I've decided to keep the code as is. If you have an idea, feel free to tell me!

Here is a schema of part of the state machine, with events leading to the same states and others occasioning transitions.

![State transitions schemas](/images/2021-02-04-phoenix-liveview-event-sourced-game-making-game-states-explicit/state_transitions.png)

## What's left to GameState

We've moved all the game logic away from the `GameState` module to the states modules. That improvement comes with an issue. We don't have one single entry point to dispatch messages. We need to know the current state before select which module's `handle` function to call.

We also still need someplace to put the logic of rebuilding the current state based on history. 

`GameState` is the perfect place for this!

```elixir
defmodule DoctorP.Game.States.GameState do

  alias States.Waiting

  def dispatch_message(message, history]) do
    build_state(history)
    |> handle(message)
  end

  def build_state(history) do
    List.foldl(history, %Waiting{}, fn event, state ->
      apply_event(state, event)
    end)
  end

  def handle(state, command) do
    state
    |> module()
    |> apply(:handle, [state, command])
  end

  def apply_event(state, event) do
    state
    |> module()
    |> apply(:apply_event, [state, event])
  end

  defp module(state), do: state.__struct__
end
```

This all that's left in the module.

The `dispatch_message` function stays the same, ensuring that the state is rebuilt before handling the message.

`build_state` is slightly changed to deal with states as structure instead of a map. The first value of the state is a `Waiting` structure. Indeed, each game starts by waiting for players to registers.

In `apply_event`, we need to know which state module is the good one based on the state before calling `apply_event` on it. This is done by the `module` function, which reads the `__struct__` key on the current state.

That's it!

We've separated all the game logic from the event-sourcing and message handling one.

Doing so, we've also improved the ability to understand our system: by looking at the list of modules, we're able to know that the game can be in three states.


Sure we're still far away from everything that using the type system to express business logic. It's only the first step. The same ideas could be applied to the modules we've seen in [the last article](/articles/phoenix-liveview-event-sourced-game-expressing-domain-concepts-in-code). Typespecs would also improve the documentation and express what can't be done by the system. It's not something I've worked on yet. Maybe later then.

In the next article, we'll probably start looking at the runtime characteristics of the game.



