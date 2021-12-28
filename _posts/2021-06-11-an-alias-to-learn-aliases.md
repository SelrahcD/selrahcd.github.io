---
layout: "post-no-feature"
title: "An alias to learn aliases"
description: "I'm trying to learn aliases to reduce the typing I need in the console but I can't remember them. I've created an alias to help me !"
image: /images/2021-06-11-an-alias-to-learn-aliases/fa_run_stash.png
category: articles
tags:
 - bash
 - zsh
 - productivity
 - TIL
 - alias
published: true
comments: true
---
I’m trying to save some time by reducing the number of keystrokes I need to do something. 

I'm pretty efficient with my IDE's shortcuts, but I have vast room for improvement in my console.

The obvious solution there is relying on aliases. 

I’ve been using the git ssh plugin for several years, but I only use a handful of the provided aliases, mostly because I never took the time to memorize past the few main ones. 

Now that I'm trying to save some typing, I'm learning the other ones. I have an issue, though: I spend a lot of time looking at the documentation to know which alias shortens the command I want to enter. In that case, it means I switch to my browser, get the right tab, or go to the website, use the search to find the suitable alias by typing part of the command. I don't save a lot of keystrokes, and I'm surely not gaining time.

Please don't take me wrong; time spend learning or practicing to improve in the long run is time well spent. Nevertheless, I decided to find a way to enhance my learning process. 

The best way to reduce the amount of time needed to find the proper alias for a command is to stay in the console and avoid looking at the documentation. 

After a quick search, I discovered that the `alias` command lists all aliases set up. That's a start.

Combining `alias` and `grep` makes it efficient to find the correct alias for the job.

That still requires some typing, if your shell doesn't have some sort if autocomplete at least.

As I'm in a quest for laziness and poking around with aliases, I decided to add a new one, `fa`, for “find alias” defined as `alias fa='alias | grep'`.

![An example: searching for all aliases about stash](/images/2021-06-11-an-alias-to-learn-aliases/fa_run_stash.png)

Just two letters, no more windows switching, and a lot of time saved.
