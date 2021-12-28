---
layout: "post-no-feature"
title: "An alias to easily debug PHP scripts"
description: "The command to start debugging PHP scripts takes a lot of options. I wanted to free my memory from having to remember
everything and created an alias to save me time, keystrokes and brain power."
image: /images/2021-12-28-an-alias-to-easily-debug-php-scripts/xdebug.png
category: articles
tags:
 - bash
 - zsh
 - productivity
 - TIL
 - PHP
 - phpstorm
 - alias
published: true
comments: true
---

As I said before, I'm trying to save some time when using the CLI, and I rely more and more on aliases.

Aliases are fantastic to save some keystrokes, and they also significantly help with something else: freeing mental space.

Some commands take a lot of arguments and options, and it's not always simple to remember all of them. I've decided to stop remembering everything and created an abstraction on top of the one I often use, hiding the long list of arguments under an alias or a command. If I still have trouble remembering the alias, I can still rely on my [alias to find aliases](/articles/an-alias-to-learn-aliases). 

One of the examples of such a command with a long list of arguments is the PHP command when it comes to debugging a PHP script.

On my machine, with PhpStorm, it goes like `php -dxdebug.mode=debug -dxdebug.client_host=127.0.0.1 -dxdebug.client_port=9000 -dxdebug.start_with_request=yes script.php`.

You probably could have different options on your machine.

I've introduced a simple alias, `xdebug`, to avoid thinking about specifing mode, port and client:

```bash
alias xdebug='php -dxdebug.mode=debug \
 -dxdebug.client_host=127.0.0.1
 \ -dxdebug.client_port=9000
 \ -dxdebug.start_with_request=yes'
```

Now, debugging a script is as easy as `xdebug script.php` and I don't have to look for the documentation, or look through my zsh history, to see how I need to construct my command. 

Keystrokes and time saved, memory freed!
