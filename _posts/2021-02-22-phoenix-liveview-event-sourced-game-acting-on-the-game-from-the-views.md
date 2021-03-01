---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: Acting on the game from the views"
description: "This article shows how the views send both simple commands and commands based on forms to the game server, and handle errors."
image: /images/2021-02-22-phoenix-liveview-event-sourced-game-acting-on-the-game-from-the-views/name_taken_error.jpg
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

In the last article, we've seen the [GameServer implementation](/articles/phoenix-liveview-event-sourced-game-game-server). It's now time to look at the views, specifically how players interact with the game.

# Starting the game from the LiveView

I decided to use LiveViews as they are convenient for real-time interactions without requiring any Javascript code.

In this article, we'll focus on the LiveView used for players to register as it exhibits handling form, sending messages to the `GameServer`, and handling potential errors.

Let's first create a new module for our LiveView. When the view is mounted, the `game_id` available in the route parameters is stored in the state.

```elixir
defmodule DoctorPWeb.WaitingRoomLive do

def mount(%{game_id: game_id}, _session, socket) do

 state = %{game_id: game_id}

  socket = socket
  |> assign(state)

  {:ok, socket}
end

end
```

The simplest case to handle in this state is handling the click on the "Start game" button. The LiveView receives an event without any parameters and sends a message to the `GameServer`.

```elixir
@impl true
def handle_event("start_playing", _params, socket) do
  GameServer.start_playing(socket.assigns.game_id)

  {:noreply, socket}
end
```

Thanks to the client function we've added to `GameServer` and being able to find it using the game ID, the implementation is easy. When a `start_playing` event is received by the LiveView process a call is issued to `GameServer.start_playing(socket.assigns.game_id)`.

# Registering a player from the LiveView

Registering a player is more complex because it involves a form for the player to specify her name.

Following ideas from [this article](https://www.amberbit.com/blog/2017/12/27/ecto-as-elixir-data-casting-and-validation-library/), I managed to use Ecto as a validation library to create a form that is not tied to a database.

We declare a module describing the form:

```elixir
defmodule RegisterPlayer do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:player_name, :string)
  end

  alias __MODULE__

  def changeset(register_player, params \\ %{}) do
    register_player
    |> cast(params, [:player_name])
    |> validate_required([:player_name])
    |> validate_length(:player_name, min: 1)
  end

  def apply_changes(changeset) do
    Ecto.Changeset.apply_changes(changeset)
  end

end
```

Once this module is created, we can use the form in the LiveView.
In the `mount` function we need to add the form changeset.

```elixir
state = %{game_id: game_id, changeset: RegisterPlayer.changeset(%RegisterPlayer{})}
```

And modify the template to display the form:

```elixir
<%= form_for @changeset, "#", [phx_submit: :register_player, id: "player_registration_form"], fn f -> %>

<%= label f, :player_name %>
<%= text_input f, :player_name, autofocus: true, placeholder: "What's your name?" %>
<%= error_tag f, :player_name %>

<%= submit "Register", phx_disable_with: "Registering..." %>
<% end %>
</form>
```

With this in place, the next step is to handle the form by creating a clause for `handle_event` matching the `register_player` event.

```elixir
def handle_event("register_player", %{"register_player" => register_player} = params, socket) do

  changeset =
    %RegisterPlayer{}
    |> RegisterPlayer.changeset(register_player)
    |> Map.put(:action, :insert)


 with true <- changeset.valid?,
                   registration <- RegisterPlayer.apply_changes(changeset),
                   :ok <- GameServer.add_player(socket.assigns.game_id, registration.player_name) do
    {:noreply, socket}
  else
    _ -> {:noreply, assign(socket, :changeset, changeset)}
  end

end
```

In the first part of the function, a new changeset for the form is created based on the form's data.

If the changeset is valid, the changes are applied to an empty `RegisterUser` structure. We access data from that structure to call `GameServer.add_player`.

If anything is not going as expected, we enter the `else` part of the `with` structure. The changeset is given back to the view, allowing to display form validation errors to the player.

![Name can't be blank error displayed](/images/2021-02-22-phoenix-liveview-event-sourced-game-acting-on-the-game-from-the-views/name_blank_error.jpg)


# Displaying errors from the `GameServer`

Another type of error is the ones returned by the GameServer when it cannot handle a command.

Let's take an example with the registration process. As seen in [the article about errors](/articles/phoenix-liveview-event-sourced-game-handling-errors), we disallow two players to share the same name. If a player tries to register with a name taken by another player, an `:player_name_not_available` is returned by `GameServer.add_player`.

Sure, we could add some logic in the `WaitingRoomLive` LiveView module to keep track of all registered players and prevent form submission if needed, but what if two players try to register with the same still available name at the exact same moment?

The `GameServer`, as the source of truth, will handle one command after the other and refuse the second one.

Let's see how to handle this.

First, we add the `add_player_name_already_taken_error` to the `RegisterPlayer` module, the one responsible for the registration form.

```elixir
defmodule RegisterPlayer do
	# ....
  @name_already_taken_error_message "This name is already taken by another player"

 def add_player_name_already_taken_error(changeset), do:
    changeset
    |> add_error(:player_name, @name_already_taken_error_message)
end
```

This function adds an error for the `:player_name` field to the changeset.

Then, we can modify the `with` structure we've seen previously to use that function when needed.

```elixir
with true <- changeset.valid?,
                 registration <- RegisterPlayer.apply_changes(changeset),
                 :ok <- GameServer.add_player(socket.assigns.game_id, socket.assigns.player_id, registration.player_name) do
  {:noreply, socket}
else
  {:error, :player_name_not_available} -> {:noreply, assign(socket, :changeset, RegisterPlayer.add_player_name_already_taken_error(changeset))}
  _ -> {:noreply, assign(socket, :changeset, changeset)}
end
```

If `GameServer.add_player` returns the `{:error, :player_name_not_available}` error tuple, we assign a modified changeset with the error to the socket.

![Name already taken error displayed](/images/2021-02-22-phoenix-liveview-event-sourced-game-acting-on-the-game-from-the-views/name_taken_error.jpg)

That's it for this article. We've covered all needed for players to act against the game. In the next article, [we'll see how the view constructs its state from the game's state](/articles/phoenix-liveview-event-sourced-game-building-views-states-and-reacting-to-changes).

