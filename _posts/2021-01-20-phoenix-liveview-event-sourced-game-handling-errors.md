---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Handling errors"
description: "In this article we'll see how I decided to deal with errors in the event-sourced model for a game."
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

In the previous article, we've set-up everything required for a basic event-sourced model.

We can:
* record the decisions taken by the game logic in the form of events
* rebuild the current game state from a list of past events
* handle a command that triggers game logic

So far, every command we've talked about was accepted by the game logic, processed, and events were produced. But sometimes, things are not going as expected, and the command is rejected.

One example, we don't accept several players with the same name. When a player tries to register, but another player is already there with the name selected, we need to refuse the command and obviously inform the player.

## Rebuilding the state and our memory
First, as a refresher, let's see how the state is built.

Let's pretend that a player named Jack wants to register.

An `AddPlayer` command is issued by the UI:

```elixir
history = //... list of past events
command = %AddPlayer{player_name: "Jack"}

action_result = GameState.handle_message(history, command)
```

The command is dispatched to the correct handler, the game logic produces a `PlayerJoinedTeam` event we would find in the `action_result` variable in the snippet above:

```elixir
def handle(state, %AddPlayer{player_name: name}) do
  [
    PlayerJoinedTeam.with(player: name)
  ]
end
```

This event joins the others in history, the list of past events.

When we want to add a second player, we need to rebuild the state.

As seen in the previous article, `GameState` module contains an `apply_event` function with a clause matching against `%PlayerJoinedTeam{}` :

```elixir
 def apply_event(state, %PlayerJoinedTeam{} = event) do
    %{state | players: [event.data.player | state.players]}
  end
```
When a `PlayerJoinedTeam` event is applied, the player is inserted into the list of players.

## Hi! I'm Jack!

Jack #1 is already in, some other player wants to join as well, and is named Jack too, Jack #2.

A business rule disallows two players to share the same name, so we'll need to reject Jack #2 attempt to register as Jack, and we'll ask him to pick another name.

The traditional way of dealing with errors in Elixir code is the OK/Error tuple.

When something is going OK, the function returns a tuple in the form 

```elixir
{:ok, result}
```

and when something failed

```elixir
{:error, the_error}
```

This is the path I decided to go with, but I made a slight twist and introduced an `ActionResult` module.

```elixir
defmodule DoctorP.Game.ActionResult do

  alias __MODULE__

  defstruct [
    events: [],
    error: nil
  ]

  def new(), do:
    %ActionResult{}

  def new(events), do:
    %ActionResult{events: events}

  def error(error), do:
    %ActionResult{error: error}

  def add(%ActionResult{error: error}, %ActionResult{}) when not is_nil(error), do:
    %ActionResult{error: error}

  def add(%ActionResult{}, %ActionResult{error: other_error}) when not is_nil(other_error), do:
    %ActionResult{error: other_error}

  def add(%ActionResult{events: events}, %ActionResult{events: other_events}), do:
    %ActionResult{events: events ++ other_events}

end
```

This module is a glorified OK\Error tuple but has functions that will come in handy later. They allow us to combine multiple `ActionResult` together, concatenating events list when everything is right, returning an error when something went wrong.

Armed with this module, let's see how we can implement the business rule.

First, we add a private `has_player_named` function that returns true when we already know a player with the name given in arguments and false otherwise.

```elixir
defp has_player_named(state, player_name) do
  state.players
  |> Enum.any?(fn x -> x == player_name)
end
```

We can now change the `handle` function to

```elixir
def handle(%{} = state, %AddPlayer{player_name: player_name}) do
  cond do
    has_player_named(state, player_name) -> ActionResult.error(:player_name_not_available)
    true -> ActionResult.new([PlayerJoinedTeam.with(player: player_name)])
  end
end
```

When a player tries to register with a name already taken by someone else, the function produces an `ActionResult` with an error `:player_name_not_available`. That same `ActionResult` is then returned by the `GameState.handle_message` function called with the command at the beginning of the process. 

That's it!

And that's a lot... We'll keep for a following article how to deal with the `ActionResult` once it's returned from `GameState.handle_message`.