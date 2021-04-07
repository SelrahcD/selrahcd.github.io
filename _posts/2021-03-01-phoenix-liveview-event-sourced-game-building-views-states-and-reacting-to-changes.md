---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Building the view's states from the events and reacting to changes"
description: "This article shows how events are used to build the views states and to communicate changes in the game in realtime."
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
         <li><a href="/articles/phoenix-liveview-event-sourced-game-building-decrementing-the-timer">Decrementing the timer</a>
        </li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-unit-testing-patterns">Unit testing patterns</a></li>
    </ul>
</div>

In [the last article](/articles/phoenix-liveview-event-sourced-game-acting-on-the-game-from-the-views), we've seen how the view communicates with the `GameServer` to send commands and act on the game. This article focuses on how the views construct their states.

The game being event-sourced its state is derived from the list of past events, and view states are not going to be different. In CQRS-ES language, they are called projections.

The first mode of building the view is rebuilding. When the view is loaded, we want it to represent the current state of the game. For example, when the game is waiting to start, some players might join while others are still not on the view. When a new player arrives, we want to display the list of all previously registered players.

The second mode is the running mode of building the view: when something occurs in the game, we want displayed information to change if necessary. 

## Rebuilding the view

First, let's introduce the `EventSourcedLiveView` module that will encapsulate logic commons to all event-based views.

```elixir
defmodule DoctorPWeb.EventSourcedLiveView do

  @callback view_init( Phoenix.LiveView.unsigned_params() | :not_mounted_at_router,
              session :: map(),
              socket :: Phoenix.LiveView.Socket.t()) :: {integer(), map()}

  defmacro __using__(opts \\ []) do

    quote do

      use DoctorPWeb, :live_view

      @impl true
      def mount(params, session, socket) do

        {game_id, init_state} = view_init(params, session, socket)

        socket = socket
                 |> assign(init_state)

        {:ok, socket}
      end
    end
  end
end
```

The module declares a macro that allows creating a specific type of LiveView, the event-sourced ones.

When the view is mounted, the `init_view` function is called and is expected to return a tuple containing the game ID and a map used as the initial state. 

We can remove the `mount` function from the `WaitingRoomLive` we've seen in the previous article and instead write:

```elixir
defmodule DoctorPWeb.WaitingRoomLive do
  use DoctorPWeb.EventSourcedLiveView

  def view_init(%{game_id: game_id}, session, socket) do
    {
      game_id,
      %{
        changeset: RegisterPlayer.changeset(%RegisterPlayer{}),
        game_id: nil,
      }
    }
  end
end
```

To rebuild the state from past events, we'll modify the `EventSourcedLiveView` module.

The `mount` function fetches all known events from the `GameServer` and passes them to `set_states`, with the `init_state` we have from the previous call to `init_view`.

```elixir
events = GameServer.get_events(game_id)
socket = socket
         |> assign(set_state(init_state, events))
```

`set_state` function goes through all events and looks for a clause of the `apply_event` matching each one of them. This is the same mechanism as for rebuilding the state we've seen when [introducing event-sourced systems](/articles/phoenix-liveview-event-sourced-game-event-sourced-model).

```elixir
defp set_state(state, history), do:
  Enum.reduce(history, state, fn e, state -> apply_event(e, state) end)
```

With this in place, let's see how we can display the teams as an example. We've seen before that [the game dispatches a `PlayerJoinedTeam` event when a player registers](/articles/phoenix-liveview-event-sourced-game-handling-errors), and we can use these events to achieve what we want.

First, we add an empty list as the list of teams in the initial state:

```elixir
def view_init(%{game_id: game_id}, session, socket) do
    {
      game_id,
      %{
        changeset: RegisterPlayer.changeset(%RegisterPlayer{}),
        game_id: nil,
	teams: []
      }
    }
end
```

Then, we add the `apply_event` function clause matching with the `PlayerJoinedTeam` event.

```elixir
defp apply_event(%PlayerJoinedTeam{data: %{player: player, team: team_id}} = event, state) do
  state
  |> Map.put(:teams, add_player_to_teams(state.teams, player, team_id))
end

defp add_player_to_teams(teams, player, team_id) do
  team = teams
         |> Enum.at(team_id, [])
         |> (fn t -> List.insert_at(t, length(t), player) end).()

  if Enum.at(teams, team_id, nil) == nil do
    List.insert_at(teams, team_id, team)
  else
    List.replace_at(teams, team_id, team)
  end
end
```

This function, alongside the private `add_player_to_teams` function, adds the player to the indicated team in the list in the LiveView state. 



## Modifying the state while the game is running

We've seen just above how the view state is built from the already known events when the view is mounted, but we haven't touched the funnier part yet, modifying the view when something occurs in the game. We'll see this in that second section.

To communicate between the `GameServer` and the LiveViews, we'll use the Phoenix PubSub system.

We introduce a `GamePubSub` module. Its role is to make it convenient to publish and subscribe to message for a specific game.

```elixir
defmodule GamePubSub do

  def subscribe(game_id), do:
    Phoenix.PubSub.subscribe(DoctorP.PubSub, game_topic(game_id))

  def publish(game_id, message), do:
    Phoenix.PubSub.broadcast(DoctorP.PubSub, game_topic(game_id), message)

  def game_topic(game_id), do: "game_#{game_id}"

end
```

Next, the `GameServer` we've worked on [in a previous article](/articles/phoenix-liveview-event-sourced-game-game-server) can be modified to dispatch events:

```elixir
defmodule GameServer
#...
defp handle_command(command, state), do:
  command
    |> dispatch_command(state)
    |> dispatch_events(state)
    |> build_new_state(state)
end

defp dispatch_events(%ActionResult{events: events} = result, state) do
  for event <- events, do: GamePubSub.publish(state.game_id, event)

  result
end
```

The `handle_command` now pipes the result of `dispatch_command` into `dispatch_events` function. 

`dispatch_events` calls the `publish` function of the newly created `GamePubSub` module for each event. The function returns its first parameters, the `ActionResult` coming from `dispatch_command`, which allows continuing to pipe into `build_new_state`.

Every time a command is dispatched and the game produces events, the `GameServer` broadcasts them via PubSub. That means we can subscribe and wait for events.

The `EventSourcedLiveView` module will precisely do this.

The `mount` function is changed to

```elixir
def mount(params, session, socket) do

  {game_id, initial_state} = view_init(params, session, socket)

  if connected?(socket) do
    GamePubSub.subscribe(game_id)
  end

  socket = socket
           |> assign(set_state(initial_state, GameServer.get_events(game_id)))

  {:ok, socket}
end
```

When the view is connected, we subscribe for new events about the game.

For every message broadcasted by the PubSub system, the `handle_info` function is called and calls the` apply_event` function, hoping that a matching clause for the event exists. In that case, the state is modified and assigned to the socket.

```elixir
@impl true
def handle_info(event, socket) do
  state = apply_event(event, socket.assigns)
          |> clean_assigns()

  {:noreply, socket |> assign(state)}
end

defp clean_assigns(assigns) do
  {_, clean_assigns} = Map.pop!(assigns, :flash)
  clean_assigns
end
```

A note here: I had to add the `clean_assigns` function to prevent LiveView assigns' error for the `:flash` reserved keys.

The `apply_event` function called in `handle_info` is the same one used when the view is mounted. It means the logic we created for building the list of teams is already working!

That's it! We've seen everything needed for our views to display the correct information when they are mounted or when something occurs in the game. 

In the next article, we'll see the part I enjoyed the most coding in this project, as it forced me to rethink some pieces and improve the design, which is [dealing with the timer](/articles/phoenix-liveview-event-sourced-game-building-decrementing-the-timer).

