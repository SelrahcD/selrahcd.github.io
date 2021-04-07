---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Game Server"
description: "This article starts looking at the game's runtime characteristics and shows how a game server can be implemented with a GenServer to store events and handle new commands."
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
        <li><a href="/articles/phoenix-liveview-event-sourced-game-building-decrementing-the-timer">Decrementing the timer</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-unit-testing-patterns">Unit testing patterns</a></li>
    </ul>
</div>


In the previous articles, we've looked at the design of the game's rules. Now is an excellent time to focus on the runtime perspective of the application.

We've seen that we can interact with a game via the `GameState` module by providing a list of events and a command. We still need some way to store the events, and for this, we'll use a GenServer.

## Skeleton of `GameServer`

`GameServer` module is a `GenServer` which allows keeping track of the events in a process.

```elixir
defmodule DoctorP.GameServer do
  use GenServer

def start_link(args) do
  game_id = Keyword.get(args, :game_id)
  GenServer.start_link(__MODULE__, args, name: process_name(game_id))
end

def init(args) do
  game_id = Keyword.get(args, :game_id)
  {:ok, %{game_id: game_id, events: []}}
end

def process_name(game_id), do:
  {:via, Registry, {DoctorP.GamesRegistry, game_id}}

end
```

We can start a `GameServer` using the `start_link` function, passing a keyword list containing a game id. The server's initial state is a map containing the game id and an empty list of events.

We also want to keep track of several games at the same time and to be able to interact with them using their game id. I've decided to use the via tuple method to link a game id and the server PID in a Registry. `process_name` returns a tuple that indicates which registry and key to use to find the server.

## Playing

The next thing to do is to be able to act on the `GameServer`.

All actions follow the same patterns. For the sake of brevity, let's focus solely on adding a player.

First, I've introduced a client side function. It allows for an easy to use interface for other modules:

```elixir
def add_player(game_id, player_name), do:
  GenServer.call(process_name(game_id), {:add_player, player_name})
```

When called, `add_player` issues a call to the server, using the process_name based on the game_id and asking to add a player with the provided player name.

Its server-side counterpart is more interesting as it is responsible of dispatching a command to the game, storing the events, and replying to the caller.

```elixir
def handle_call({:add_player, player_name}, _from, state), do:
  %AddPlayer{player_name: player_name}
  |> handle_command(state)
  |> reply()
```

First, the [`AddPlayer` command](/articles/phoenix-liveview-event-sourced-game-event-sourced-model#producing-events) is built and piped into to a private `handle_command` function, alongside the state . The result of this call is, in turn, piped into a private `reply` function.

Let's dive into these!

### Handling the command

```elixir
defp handle_command(command, state), do:
  command
    |> dispatch_command(state)
    |> build_new_state(state)

defp dispatch_command(command, state), do:
  GameState.dispatch_message(command, state.events)

defp build_new_state(%ActionResult{events: events} = result, state), do:
  {result, %{state | events: state.events ++ events}}
```

`handle_command` is made of two parts, each one in its function.

First, we use the `GameState` module to dispatch the command. We can see that all previous events, currently stored in the state, are passed as a second parameter. It ensures the [command handler knows the current state](/articles/phoenix-liveview-event-sourced-game-event-sourced-model#producing-events#rebuilding-the-state).

Secondly, the command dispatch result, an `ActionResult` is piped into `build_new_state`. Here the new state is created by appending the news events to the events currently stored. Note that `build_new_state` returns a tuple containing the result of the dispatch and the new state.

### Replying to the caller

Once the command is dispatched, the game logic applied and, the new state created we need to reply to the caller.

This is the job of the `reply` function we've seen in the `handle_call` function.

`build_new_state` returns a tuple containing an `ActionResult` and the desired state after the command handling, which serves as a parameter for our new `reply` function.

```elixir
defp reply({ %ActionResult{}, new_state}), do:
  {:reply, :ok, new_state)
```

Here we simply reply with the `:ok` tuple and use the second part of the tuple for the new server's state.

The first part of the tuple seems useless by now, but it's actually important.

We've seen in [the article about error handling](/articles/phoenix-liveview-event-sourced-game-handling-errors) that part of `ActionResult`'s job is to keep track of errors. So far, `reply` only handles the positive cases.

I've decided to communicate errors to the caller by responding with a tuple starting with the `:error` atom and containing the error provided by the game.

To do this we need to add a clause for the `reply` function matching with `ActionResult` containing errors:

```elixir
defp reply({ %ActionResult{error: error}, new_state}, state) when not is_nil(error), do:
  {:reply, {:error, error}, new_state)
```

The `GameServer` can now deal with both positive outputs, made of new events and errors, and communicates them to callers.

There are still exciting things to say about the `GameServer`, from how it communicates with the Liveviews, to stopping them and more. These are the things we'll cover in the next articles!


