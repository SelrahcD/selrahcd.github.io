---
layout: "post-no-feature"
title: Passing data to session while testing in Elixir
description: "It's not as hard as it seems to pass data to the session while testing a Phoenix application"
category: articles
tags:
 - TIL
 - Elixir
published: true
comments: true
---

I struggled a while when I tried to pass data to the session while setting up a Liveview test. I googled a lot and asked on the elixir slack for a solution, but everything I saw seemed [quite complicated](https://elixirforum.com/t/test-for-sessions-in-phoenix/2569), and I didn't manage to make it work.

I probably messed up something.

I finally found relief and [a blog post](https://paulhoffer.com/2018/03/22/easy-session-testing-in-phoenix-and-plug.html) with a one liner that does it :

```elixir
Plug.Test.init_test_session(conn, user_id: 1)
```

The [Plug documentation](https://hexdocs.pm/plug/Plug.Test.html#init_test_session/2) doesn't say much more.