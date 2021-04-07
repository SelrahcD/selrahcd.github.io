---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Decrementing the timer"
description: "This article shows how to add a timer in an event-sourced game while keeping game logic decoupled from architecture concern using the send message to self pattern."
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
        <li><a href="/articles/phoenix-liveview-event-sourced-game-building-decrementing-the-timer">
        Decrementing the timer</a>
        </li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-unit-testing-patterns">Unit testing patterns</a></li>
    </ul>
</div>

One thing that always comes with challenges in applications is time. In Docteur Pilule, we have an instance of time in the form of a timer: a round is 40 seconds long.

When I started coding the game, I wanted to display the decrementing counter, changing every second, to players.

In this article, we'll see that thanks to Elixir, Liveview, and the design choices made so far, it's pretty easy to do.

## Sending a message to self

Here I propose a solution based on what Greg Young describes as "sending a message to self". 

The idea is that a component passes a message to a delivery mechanism with a date it would like to receive the message and goes back to its own business. When it's time, the delivery mechanism sends the message to the component to be handled as any other message.

## Future message container

We've seen in a previous article that [every action returns an `ActionResult` structure](/articles/phoenix-liveview-event-sourced-game-handling-errors#hi-im-jack). The `ActionResult` module is the mean of communication between the game rules and the game server. It can be extended to handle future messages.

First, we add a new key in the structure, `scheduled_messages`. That key points to a list of tuples containing a delay in milliseconds and a message.

```elixir
defmodule ActionResult do

  defstruct [
    events: [],
    scheduled_messages: [],
    error: nil
  ]
```

We can then complete the module with functions helping us deal with combining several `ActionResults` that may contain scheduled messages.

```elixir
def new(events, scheduled_messages), do:
  %ActionResult{events: events, scheduled_messages: scheduled_messages}

def add(%ActionResult{events: events, scheduled_messages: scheduled_messages}, %ActionResult{events: other_events, scheduled_messages: other_scheduled_messages}), do:
  %ActionResult{events: events ++ other_events, scheduled_messages: scheduled_messages ++ other_scheduled_messages}

def add(%ActionResult{events: events, scheduled_messages: scheduled_messages}, other_events) when is_list(other_events), do:
  %ActionResult{events: events ++ other_events, scheduled_messages: scheduled_messages}
```

## Decrementing the timer

Choosing to start, decrement, or stop the timer is a game rule and thus resides in the application's game logic part. [As seen previously](/articles/phoenix-liveview-event-sourced-game-expressing-domain-concepts-in-code), each concept in the game gets its module with functions acting as commands and the `apply_event` callback returning a new state when an event is applied.

Even if the `Timer` module needs to deal with scheduled messages, it is no different than other modules.

```elixir
defmodule Timer do
 # ...
  @round_time 40
  @one_second :timer.seconds(1)

  def start_time(), do:
    ActionResult.new(
      [
        RoundTimeStarted.with(
          remaining_time: @round_time
        ),
      ],
      [{@one_second, %Tick{}}]
    )

  def decrement_time(1), do:
    ActionResult.new([%RoundEnded{}])

  def decrement_time(current_time) do
    time = current_time - 1
    ActionResult.new(
      [RoundTimeTicked.with(remaining_time: time)],
      [{@one_second, %Tick{}}]
    )
  end

  def apply_event(_time, %RoundTimeTicked{data: %{remaining_time: remaining_time}}), do: remaining_time

  def apply_event(_time, %RoundTimeStarted{data: %{remaining_time: remaining_time}}), do: remaining_time

end
```

The module defines two module attributes, `@round_time` and `@one_second`, respectively describing the round duration in seconds and one second expressed in milliseconds.

The `start_time` function returns an `ActionResult` containing a `RoundStarted` event with a remaining time set to `@round_time`. The `ActionResult` also contains a scheduled message, `%Tick{}`, programmed to be received in one second.

Similarly, `decrement_time` decrements the time, produces a `RoundTimeTicked` event, and schedules a `%Tick{}` for one second later.

If the timer's value is `1`, the first clause of `decrements_time` is selected. It produces an `%RoundEnded{}` event and doesn't schedule a `%Tick{}` as there is no need to decrement the timer anymore.

`apply_events` for `%RoundTimeTicked{}` and `%RoundTimeStarted` return the remaining time contained in the event as the new timer state.

The `InRound` module, [which encapsulates all game behaviors during a round](/articles/phoenix-liveview-event-sourced-game-making-game-states-explicit#business-logic-as-types),  stays simple.

When a player starts a round, the timer starts, and a word is distributed.

```elixir
def start_round(game), do:
  ActionResult.new()
  |> ActionResult.add(Timer.start_time())
  |> ActionResult.add(Dictionary.give_word_to_player(game.dictionary, Teams.current_player(game.teams)))
```

When a `%Tick{}` message is received, the timer is decremented.

```elixir
def handle(%InRound{} = game, %Tick{}) do
  Timer.decrement_time(game.timer)
end
```

The application of an event related to the timer is delegated to the `Timer module. The `apply_event` function returns the new timer state.

```elixir
def apply_event(%InRound{} = state, %RoundTimeStarted{} = e), do:
  %InRound{state | timer: Timer.apply_event(state.timer, e)}

def apply_event(%InRound{} = state, %RoundTimeTicked{} = e), do:
  %InRound{state | timer: Timer.apply_event(state.timer, e)}
```

The game logic now deals with the timer: it can decide when the timer must be started, schedule the timer to be decremented a second later, and decrement and stop it.

This is everything to know about changes in the game logic. We now need to talk about the delivery mechanism for the scheduled message.

## The `GameServer` as scheduled messages delivery mechanism

The part title totally spoiled it: we're going to use the `GameServer` as our delivery mechanism for scheduled messages.

Using `Process.send_after`, Elixir makes it very easy to send to a process a message in the future.

Let's add a private `schedule_messages` function in the module:

```elixir
defp schedule_messages(%ActionResult{scheduled_messages: scheduled_messages} = result) do
  for {delay, message} <- scheduled_messages, do:
    Process.send_after(self(), {:scheduled_message, message}, delay)

  result
end
```

This function looks for the scheduled messages inside an `ActionResult`, and for each one of them sends to `self()`, the current `GameServer` process,  a tuple message `{:scheduled_message, message}` delayed by the amount of time requested by the game logic. It conveniently returns the `ActionResult`, which means we can add this function to a chain of piped functions.

Once the delay is over, the `GameServer` process `handle_info` callback is called with the message. 

We can create a clause for `handle_info` and let it handle the message as a command and then store the state.

```elixir
def handle_info({:scheduled_message, message}, state), do:
  new_state = handle_command(message, state)
  {:noreply, new_state}
```

We've already seen the `handle_command` function. This is the function we call when the `GameServer receives a command`. As a reminder, the function [dispatches the command to the game logic](/articles/phoenix-liveview-event-sourced-game-game-server#handling-the-command), [broadcast events for the view](/articles/phoenix-liveview-event-sourced-game-building-views-states-and-reacting-to-changes#modifying-the-state-while-the-game-is-running), and collect events to store them in the state.

It's the perfect place to add `schedule_message`. Adding it here means that messages are scheduled when a command is handled and when a scheduled message is handled, precisely what we want. The first case takes care of starting the timer to tick when the round begins, and the second case deals with scheduling the next tick when a tick happens.

```elixir
defp handle_command(command, state), do:
  command
    |> dispatch_command(state)
    |> dispatch_events(state)
    |> schedule_messages()
    |> build_new_state(state)
```

With this in place, the game logic can express its need to be notified later to take decisions without being coupled to any infrastructure concerns. As promised, it required only a few code additions, no massive rework, and keeps the application well organized. 