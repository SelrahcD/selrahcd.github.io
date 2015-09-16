---
layout: post
title: OOP Layers
description: "Please, stop breaking layers in OOP."
category: articles
tags:
  - Dev
  - OOP
published: true
comments: true
image:
  feature: humahuaca.jpg

---


Yesterday at work I ran into a pretty nasty bug and looking through the code I spotted something which even if it wasn't the primary cause of all the mess made it really worst.

The code was going like this :


{% highlight PHP linenos %}
<?php
class AClassThatDoesSomethingWithThingsAndStuff {

    public function aMethodThatAssociatesSeveralThingsWithAStuff(array $things)
    {
        $aStuff = null;

        foreach($things as $thing)
        {
            $aStuff = $this->aMethodThatUseASomething($thing, $aStuf);
        }
    }

    private function aMethodThatAssociateOneThingWithAStuff(Thing $thing, Stuff $stuff = null)
    {
        if($stuff == null) {
            $stuff = $this->somehowGetAStuff();
        }

        $thing->associateWithASomething($stuff);

        return $stuff;
    }
}
?>
{% endhighlight %}

As you can see it seems that we always need a Stuff in order to make an association with a Thing. Furthemore we hope to use that same Stuff for all the things.

The main issue with this piece of code is the Stuff we use is going through two layers, created in a sub-layer (in `aMethodThatAssociateOneThingWithAStuff`), going up one layer (in `aMethodThatAssociatesSeveralThingsWithAStuff) before returning to the sub-layer again.

An other issue is that we are not really in control of the Stuff used.

I think the code would have been better if it had been written this way :

{% highlight PHP linenos %}
<?php

class AClassThatDoesSomethingWithThingsAndStuff {

    public function aMethodThatAssociatesSeveralThingsWithAStuff(array $things)
    {
        $stuff = $this->somehowGetAStuff();

        foreach($things as $thing)
        {
            $this->aMethodThatUseASomething($thing, $aStuf);
        }
    }

    private function aMethodThatAssociateOneThingWithAStuff(Thing $thing, Stuff $stuff)
    {
        $thing->associateWithASomething($stuff);

    }
}
?>
{% endhighlight %}

This code doesn't break the layers between the methods. The Stuff is get on the top level and passed one level down when needed. We are also able to choose what Stuff we want to pass to the sub-level method.

And it's simpler...


We can even make this way more fun if `aMethodThatAssociateOneThingWithAStuff` can throw exceptions.
The code will probably end up with a try-catch structure inside of the foreach loop. (Our code end up like this at least...)

See below :


{% highlight PHP linenos %}
<?php
class AClassThatDoesSomethingWithThingsAndStuff {

    public function aMethodThatAssociatesSeveralThingsWithAStuff(array $things)
    {
        $aStuff = null;

        foreach($things as $thing)
        {
            try {
               $aStuff = $this->aMethodThatUseASomething($thing, $aStuf);
            }
            catch(Exception $exception) {
                // Do what you want here to treat the exception
            }
        }
    }

    private function aMethodThatAssociateOneThingWithAStuff(Thing $thing, Stuff $stuff = null)
    {
        if($stuff == null) {
            $stuff = $this->somehowGetAStuff();
        }

        $thing->associateWithASomething($stuff);

        // Do something else, possibly throwing an exception

        return $stuff;
    }
}

?>
{% endhighlight %}

Imagine the method `somehowGetAStuff` has some side effects: writing a new Stuff in the database for instance.

When an exception is thrown the execution enters the catch part of the try-catch and doesn't overwrite the value of `$aStuff`.
As long as the method will throw an exception without letting a chance to `$aStuff to be initialized `somehowGetAStuff` will be called, with all its side effects...

Breaking layers in OOP can have some really bad consequences, and as you can see it makes your code harder to read and will probably create some bugs.

This example is based on methods but classes are layers too and thus should not become entangled neither.

As a rule of thumb you should probably be suspicious at a piece of code when you see:

* A test for existence for something passed to your method.
* A memory allocation without desallocation.
* A layer in charge of retrieving something it needs. This breaking the [inversion of dependency principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle).
* A method called openSomething without a closeSomething, or the inverse in the same layer.

because this code is probably running through several layers.
I guess we can make this list way longer.

The header picture is a photography of the [Quebrada de Humahuaca](https://en.wikipedia.org/wiki/Quebrada_de_Humahuaca) in Argentina. The strange look of the mountain, called [Cerro de los Siete Colores](https://en.wikipedia.org/wiki/Cerro_de_los_Siete_Colores) - The Hill of Seven Colors -, is the result of thousand years of marine sediment. See how beautiful layers can be ?

I took the picture from this [website](http://www.toolito.com/montagnes-hornocal-colline-aux-7-couleurs-purmamarca/), and I really don't know who I should thanks for it and attribute it to. I'm not sure they do neither...

Hey! I'm on [Twitter](https://twitter.com/selrahcd), if you want to discuss about OOP feel free to come by and say hi! You can comment below as well.


