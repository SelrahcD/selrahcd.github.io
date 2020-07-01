---
layout: "post-no-feature"
title: Faster environment with xDebug and Docker
description: "A few tips for a faster dev env with xDebug and Docker"
category: articles
tags:
 - xDebug
 - PHP
 - Docker
published: true
comments: true
---

I have to admit that I've always been lazy when it came to set up xDebug as it felt tedious the few times I've to do it. It made me an almost perpetual member of the `var_dump` debug team.

Nevertheless, the last time I had to set it up was easier thanks to PhpStorm and I don't think the difficulty to set up is a valid excuse anymore.


I then had a debugger...

And I had a speed issue. My tests were running slower than before, every request took way too much time. Using docker on OSX didn't help at all.


I found a few tips that helped to go back to the, almost, same state as before.

So ...

## Tips 1: Do not start xDebug

Ahah... Yes you can thank me for this one. The best way to avoid xDebug slowing everything down is by not having xDebug running. So disable it by commenting the path to the extension in the `.ini` file loading it. Another idea is, if you have a `xdebug.ini` file in the php configuration directory, is to rename it to something else, `xdebug.ini.back` for instance.

This being said how can we manage to start xDebug when needed ?

## Tips 2: Use the on demand PhpStorm mode when debugging tests

As explained in the [PhpStorm documentation](https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html#on_demand_mode) an “on demand” mode is available. It will enable xDebug only when debugging tests which will allow to run your test at full speed most of the time.


I'll let you dig in the documentation as it will be better explained than if I do it myself.

## Tips 3: Use the on demand mode without PhpStorm

PhpStorm is not doing magic for the “on demand” mode but taking advantage of the `-d` PHP CLI option. The `-d` allows to define INI entry in the PHP configuration. When starting the “on demand” mode PhpStorm adds `-d zend_extension=xdebug.so` to the PHP CLI options which enables the extension. You can do the exact same thing if your running your tests without PhpStorm.

As an example here is how you can run PhpUnit with xDebug activated:

```bash
php -d zend_extension=xdebug.so ./vendor/bin/phpunit
```

You'll probably need to pass more options if you want to connect xDebug to a debugger client so this not as convenient as running it through PhpStorm as it sets everything needed to work out the box. As an example, here are all the option passed by PhpStorm when I start tests in debug mode :

```bash
-d zend_extension=xdebug.so -d xdebug.remote_enable=1 -d xdebug.remote_mode=req -d xdebug.remote_port=9100 -d xdebug.remote_host=host.docker.internal

```

This is still a good option if you need xDebug without a client listening. I guess the main use case would be for coverage report.



## Tips 4: Enable xDebug with an environment variable in your docker container

Going in the container and modifying file every time you need to enable or disable xDebug is quite cumbersome. I've tested another option for the last few weeks and it works very well.

I've modified my PHP Dockerfile to add an entrypoint script which is run when the container starts and can have access to environment variables.

The entrypoint script looks for an environment variable and decides to rename or not the `xdebug.ini` file in the PHP configuration directory.

As an example, here is the `entrypoint.sh` file I'm using in a php5.6 container, you'll probably need to adapt it to suit you container.

```bash
#!/bin/bash
set -e

if [[ ! -z "$DISABLE_XDEBUG" && "$DISABLE_XDEBUG" = true && -f "/etc/php/5.6/mods-available/xdebug.ini" ]]; then

mv /etc/php/5.6/mods-available/xdebug.ini /etc/php/5.6/mods-available/xdebug.ini.back

cat >&2 <<EOF
⚠️  xDebug is disabled
EOF

elif [[ -z "$DISABLE_XDEBUG" || "$DISABLE_XDEBUG" = false && -f "/etc/php/5.6/mods-available/xdebug.ini.back" ]]; then
mv /etc/php/5.6/mods-available/xdebug.ini.back /etc/php/5.6/mods-available/xdebug.ini
fi

exec "$@"
```

And the Dockefile is edited to include the entrypoint:

```dockerfile
COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm5.6"]
```

The container can be started either with [docker-compose](https://docs.docker.com/compose/environment-variables/#set-environment-variables-in-containers) or [docker run](https://docs.docker.com/engine/reference/run/#env-environment-variables) and xDebug activated by setting the environment variable `DISABLE_XDEBUG` to `false` and disabled by setting it to `true`. When the variable is missing xDebug will stay activated.

We now have a convenient way to enable xDebug only when needed and save some precious time not waiting in front of loading pages. Only thing needed is to change the value of the variable and restart the container.

## Extra tip:

xDebug settings can be overridden using the `XDEBUG_CONFIG` environment variable which means there is no need to update the xDebug config file every time you have to change a setting, or if you and your teammates need different settings.


The best example is probably the `remote_host`. According to how you run docker this setting could be a changing IP address or `host.docker.internal` if you're using docker for mac.

In order to set the remote host to `host.docker.internal` the `XDEBUG_CONFIG` should be set `remote_host=host.docker.internal`.


I hope all this tips will help you improve the speed of your development environment.

If you want to share some tips as well come say “Hi!” on [Twitter](https://twitter.com/selrahcd) or feel free to comment below.


