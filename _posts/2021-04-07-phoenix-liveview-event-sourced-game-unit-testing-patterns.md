---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Unit testing patterns"
description: "This article is an overview of some useful patterns when testing event-sourced application."
category: articles
tags:
 - "Event sourcing"
 - Elixir
 - DoctorP
 - Liveview
 - Phoenix
 - Testing
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

We've seen a lot about the game but haven't talked yet about testing. When dealing with event-sourced system testing comes with some interesting patterns. We'll see some of them in this article.

## Testing in event-sourced system

As with everything else with an event-sourced system, testing is based on events. The three tests parts, arrange, act and assert, can be mapped as follow:

*Arrange:*  Create a history of events

*Act:*  Recreate state from events and dispatch a command

*Assert:*  Ensure the system produced some events

Here is an example of a test ensuring that the second player is enlisted in the second team.

```elixir
defmodule WaitingRoomTest do
  use ExUnit.Case, async: true

  describe "Add player" do

    test "adds second players to the second team" do
    # Arrange: create a history where a player already joined the first team
	  history = [
      PlayerJoinedTeam.with(player: %{name: :player_1}, team: 1)
    ] 
      
    # Act: Dispatch a command to add a second player based on the history
    # Rebuilding state from history is dealt with by GameState module
    %ActionResult{events: events} = GameState.dispatch_message( %AddPlayer{player_name: :player_2}, history)

    # Assert: Ensure that an event indicating that the second player joined the second team was produced
    assert Enum.member?(events, PlayerJoinedTeam.with(player: %{name: :player_2}, team: 2))

    end
  end
end
```

I like my tests to read easily and decided to introduce a new module to take advantage of Elixir's piping to improve expressiveness. We can build on top of the fact that `GameState.dispatch_message` returns an `ActionResult`.

The first function in the new module checks if an event was published.

```elixir
defmodule ActionResultHelper do

  def published_event?(%ActionResult{events: events}, event), do:
    Enum.member?(events, event)

end
```

We can rewrite the previous test with this in place once we've imported the `ActionResultHelper` module.

```elixir
test "adds second players to the second team" do
  history = [
    PlayerJoinedTeam.with(player: %{name: :player_1}, team: 1)
    ] 
      
  assert dispatch_message( %AddPlayer{player_name: :player_2}, history)
	  |> published_events?(PlayerJoinedTeam.with(player: %{name: :player_2}, team: 2))

end
```

The separation between the act and the test's assert parts is more blurry, but I think the test better conveys what the system does, so I'm ok with that.

## Verify that an error is returned

We can add more functions to the `ActionResultHelper` module to verify that the game's behavior is as expected.  One case is ensuring that the game correctly returns an error when needed.

First, let's add a function.

```elixir
defmodule ActionResultHelper do

def errored_with?(%ActionResult{error: error}, expected_error), do:
  error == expected_error

end
```

Then, in the tests, we can write something like

```elixir
test "refuses a player with a name already taken" do
  player_name = :same_player_name

  history = [
    PlayerJoinedTeam.with(player: %{name: player_name}, team: 3),
  ]

  assert %AddPlayer{player_name: player_name}
         |> dispatch_message(history)
         |> errored_with?(:player_name_not_available)
end
```

Again, this reads very well!

## Ensuring that a message is scheduled

We've seen that the application sometimes needs to [schedule a message that it would like to receive in the future](/articles/phoenix-liveview-event-sourced-game-building-decrementing-the-timer). We can follow the same pattern to verify that the game logic well produces these messages.

Introduce a new function to the helper module

```elixir
defmodule ActionResultHelper do

def scheduled_message_in?(%ActionResult{scheduled_messages: scheduled_messages}, message, time), do:
  Enum.member?(scheduled_messages, {time, message})

end
```

And write a test. Here we ensure that when a `Tick` message is dispatched the next one is scheduled for one second later.

```elixir
test "schedules a tick message for 1 second later" do
  
  history = ...

  assert %Tick{}
         |> dispatch_message(history)
         |> scheduled_message_in?(%Tick{},  :timer.seconds(1))
end
```

## Being lazy

Sometimes a command creates a lot of events, and it is painful to manually build them all to create a history of a game after several rounds.
We can streamline the arrange part of tests if we use commands to create the history. In that case, we need to collect the events produced when the command is dispatched and add them to the current list of events to complete the history.

```elixir
defmodule ActionResultHelper do

  def start_history(), do:
    ActionResult.new()

  def dispatch_and_collect_events(%ActionResult{} = history, message) do
      history
      |> ActionResult.add(GameState.dispatch_message(message, history |> event() , opts))
  end

  def events(%ActionResult{events: events}), do: events

end
```

Here I've added a few more functions to the helper module. `StartHistory` returns an empty `%ActionResult{}` structure. The `dispatch_and_collect_events` function dispatches a message to the game using the events stored in an `ActionResult` and adds events resulting from the dispatch to it. `Events` function returns the events contained in the `ActionResult`.

We can use these functions to build history. For instance, in the next snippet, we build the history up to after the game starts.

```elixir
history = start_history()
  |> add([  #ActionResult.add
   PlayerJoinedTeam.with(player: player(:player_A1), team: 1),
   PlayerJoinedTeam.with(player: player(:player_A2), team: 1),
   PlayerJoinedTeam.with(player: player(:player_B1), team: 2),
   PlayerJoinedTeam.with(player: player(:player_B2), team: 2)
  ])
  |> dispatch_and_collect_events(%StartGame{blue_deck: blue_cards, red_deck: red_cards, dictionary: words})
  |> events()
```

Another instance where it's super helpful is for the last tick of round, where many things are going on.

With the three following lines, we're now able to start a round, fast-forward to the penultimate tick and trigger one last tick.

```elixir
|> dispatch_and_collect_events(%StartRound{})
|> add([RoundTimeTicked.with(remaining_time: 1)])
|> dispatch_and_collect_events(%Tick{})
```

## Being super lazy

When a player marks a word as guessed, the game produces a lot of events. We've seen how the introduction of the `dispatch_and_collect_events` can help here. One last issue persists when testing that the game correctly ends after 20 words guesses; we need to copy-paste `dispatch_and_collect_events(%MarkWordAsGuessed{})` a lot.

We can fix this by adding an extra, optional parameter to `dispatch_and_collect_events`, which states how many times we want to repeat the message.

```elixir
def dispatch_and_collect_events(%ActionResult{} = history, message, opts \\ []) do
  repeat = Keyword.get(opts, :repeat, 1)

  Enum.reduce(1..repeat, history, fn _x, %ActionResult{events: events} = result ->

    result
    |> ActionResult.add(GameState.dispatch_message(message, events, opts))

  end)
end
```

This change allows reducing the amount of typing necessary to build the history.

Here we build a history where a player marked 20 words as guessed.

```elixir
history
|> dispatch_and_collect_events(%MarkWordAsGuessed{}, repeat: 20)
```

That the last one of the helpful patterns for testing applications built using event-sourcing I've introduced in this project. I hope they can give you some ideas for your own projects!
