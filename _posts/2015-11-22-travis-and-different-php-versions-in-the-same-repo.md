---
layout: "post-no-feature"
title: Travis and different PHP versions in the same repo
description: "How to set up Travis for different applications stored in the same repo but using different PHP versions."
category: articles
tags:
  - Php
  - Dev
  - Travis
  - CI
  - Phpunit
published: true

---

At work we have one git repository for several projects. While this has some advantages their is also some drawbacks. Setting up a CI is one of them, especially when all the applications can't run on the same PHP version.

We use Travis in order to ensure that our tests are still green after a modification but as we are currently working on some refactoring of our legacy app written for PHP 5.3 - We are late, we know... - we wanted to be able to work on a more recent PHP version. The issue is that Travis' build matrix will fail either on the PHP 5.3 build or on the PHP 5.6 one.

We finally came up with a solution, which even if not ideal allows us to see if we are breaking something : we run some of the tests only for one version or the other.

First thing we create a variable for each version of PHP in the `before_script` section of `travis.yml`:

{% highlight yaml linenos %}
before_install:
    - if [[ ${TRAVIS_PHP_VERSION:0:3} == "5.3" ]]; then export PHP53=false; else export PHP53=true; fi
    - if [[ ${TRAVIS_PHP_VERSION:0:3} == "5.6" ]]; then export PHP56=false; else export PHP56=true; fi
{% endhighlight %}

Notice that we are assigning `false` to the associated variable when the PHP version matches.

Now, for each command that Travis should execute we are able to specify if it should be run for the current build version :

{% highlight yaml linenos %}
install:
    - $PHP53 || ( cd $TRAVIS_BUILD_DIR/applications/app1 && composer install )
{% endhighlight %}

This must be read as "Cd to app1 directory and run composer install for PHP 5.3".

In the end our `travis.tml` looks like this:

{% highlight yaml linenos %}
language: php

php:
  - 5.3
  - 5.6

before_install:
    - if [[ ${TRAVIS_PHP_VERSION:0:3} == "5.3" ]]; then export PHP53=false; else export PHP53=true; fi
    - if [[ ${TRAVIS_PHP_VERSION:0:3} == "5.6" ]]; then export PHP56=false; else export PHP56=true; fi

install:
    - $PHP53 || ( cd $TRAVIS_BUILD_DIR/applications/app1 && composer install )
    - $PHP56 || ( cd $TRAVIS_BUILD_DIR/applications/app2 && composer install )

script:
  - $PHP53 || ( cd $TRAVIS_BUILD_DIR/applications/app1 && ./bin/phpunit )
  - $PHP56 || ( cd $TRAVIS_BUILD_DIR/applications/app2 && ./vendor/bin/phpspec run && ./vendor/bin/behat )
{% endhighlight %}

If you want a command to be run for several PHP versions you can specify them as follow:

{% highlight yaml linenos %}
install:
    - ( $PHP53 && $PHP56 ) || ( cd $TRAVIS_BUILD_DIR/applications/app1 && composer install )
{% endhighlight %}
 which should be read "Cd to app1 directory and run composer install for PHP 5.3 and PHP 5.6".

Handy, right ?

Hey ! I'm on [Twitter](https://twitter.com/selrahcd) too. Come say Hi ! You can feel free to comment below as well.



