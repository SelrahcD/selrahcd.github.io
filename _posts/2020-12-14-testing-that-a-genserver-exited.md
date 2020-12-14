---
layout: "post-no-feature"
title: Testing that a GenServer exited
description: "We can test that a GenServer exited by monitoring its process"
category: articles
tags:
 - TIL
 - Elixir
published: true
comments: true
---

In the project I'm working on, I need to keep a GenServer up for a while, but I don't want to keep it up forever as I want to free resources.
The solution is to use the [timeout mechanism](https://hexdocs.pm/elixir/GenServer.html#module-timeouts) with an `handle_info(:timeout, _)` callback stoping the loop.

This is straightforward, but then another question came up: How should I test that ?

After digging for a while I discovered that the solution is to monitor the GenServer process in the test. Once the GenServer process exits a `:DOWN` message should be sent to the test process. The test can assert that the correct message was received.

```elixir
    test "MyGenServer exits after an_action", fixtures do

      # Start the GenServer
      {:ok, pid} = start_supervised(MyGenServer)

      # Monitor the GenServer process
      ref = Process.monitor(pid)

      # Start an action on the GenServer
      MyGenServer.an_action(pid)

      # Assert that the :DOWN message for the GenServer process was received
      # I decided to allow the message to arrive in a timeframe 10 times bigger than the allowed inactive period is 
      # If the message isn't received by then the test is marked as failed
      assert_receive {:DOWN, ^ref, :process, pid, :normal}, MyGenServer.allowed_inactive_period() * 10
    end
```

This solution applies to any type of Elixir process, not only to GenServers.