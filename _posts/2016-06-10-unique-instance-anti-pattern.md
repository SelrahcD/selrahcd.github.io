---
layout: post-no-feature
title: Unique instance anti-pattern
description: "A finalist for the worst anti-pattern tournament."
category: articles
tags:
  - Dev
  - craftsmanship
  - OOP
  - anti-pattern
published: true
comments: true

---

I'm back from the past. I have been trying to introduce some tests in one of the oldest part of our codebase. I'm back from a time where using [Service Locator](http://martinfowler.com/articles/injection.html#UsingAServiceLocator) was the norm for a lot of people, [Inversion of Control](http://martinfowler.com/articles/injection.html#InversionOfControl) concept wasn't widespread and [Singleton](https://en.wikipedia.org/wiki/Singleton_pattern) wasn't presented as an anti-pattern yet.

I have to say that I feel funny pointing to some articles from Uncle Bob from 2004 while I'm speaking about a code that is less that 7 years old.

As one of my co-worker said last week :

> It's funny to see that some people were 10 years ago where we are now. I'm wondering what they are doing now and where we will be in 10 years.

(F*** this quote is gigantic. Ok, I'm mixing message and form here...)

I do too.

So, here goes the masterpiece.

``` php
<?php
class AClassWithADecentName {

    static private $alreadyInstantiated = false;
	
    public function __construct()
    {
    	if (static::$alreadyInstantiated) {
           throw new Exception("You can't instantiate that class twice");
        }
        
        static::$alreadyInstantiated = true;
    }
}
?>
```

If you try to instantiate it twice your whole application will blow up because of the exception.

This is worst than a singleton : you can't even use the object twice. A singleton can at least be used several times. This is the **unique instance anti-pattern**.

It turns out I got the chance to speak with the man who created that beast. Remember my co-worker from last week ?

We spoke about the context at the time he wrote that piece of code. The team was composed of unexperienced/stubborn developers and he was trying to enforce a design and he wanted to prevent the misuse of that class. To be fair a more appropriate name for the class could be `AClassWithADecentNameDoingThingWeAreNotVeryProudOfInAWayWeDislike`.

The thing is that class is untestable the way it is now and the unique reason is to prevent developers to do something. I strongly believe that explanations and code reviews are way more powerful to prevent bad code from being created in the long term and so I don't want to harm code design as a protection against other developers. They have access to the codebase and they can mess with it anyway. 

Protection code passes a message - do not use me - that should have been transmitted in some other form - teaching -.

You know : Give a man a fish... Teach a man to fish...

In order to prevent some other beasts from being created let's make a deal : We will not damage our code to prevent other developers to do something and we will explain why something should be done or not instead.

We will not conflate the message and the form anymore.

If you love bad images, bad jokes and anti-pattern I'm on[Twitter](https://twitter.com/selrahcd). Feel free to comment below as well.
