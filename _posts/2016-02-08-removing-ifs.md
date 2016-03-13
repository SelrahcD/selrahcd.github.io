---
layout: post-no-feature
title: Removing ifs
description: "What if we remove some if statements ?"
category: articles
tags:
  - Dev
  - OOP
published: false
comments: true

---

I'm not a big fan of if statements.

They make source code harder to reason about, force us to write more test cases and increase [cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity)...

We even debated with some colleagues on the way to lunch if it would be possible to make an application without any one of them. We finally agreed that it would be very difficult if the application had to enforce some business rules.

In some cases it's totally doable to remove if statements. Here are a few options.

## Keeping them outside of the application

The application I work on has to be integrated with some external services. Some of them ping our system on an a callback URL with an HTTP call. This is a fairly common scenario.

I had to work on the controller action dealing with those callback calls. **The controller action**. Yep. We have only one action for several externals services. Therefore the major part of the code is dealing with trying to recognize who is calling, base on the shape of the message. Coming with a lot of ifs.

A simpler solution would have been to create one action for each external service, pushing the if statements outside of our code directly into the services' configuration.

## Depency inversion principle

Sometimes we have to make use of slightly different version of an algorithm, whether its for test purpose or for some other reason.

I've stumble upon a piece of code that was using a boolean flag specifying if code was run in test mode or not. A trivial example could be something like this :

```php
<?php
class Writter {

    public function write($text, $test = false)
    {

		if($test) {
			echo "Test : " . $text;
		}
		else {
			echo $text;
		}
	}
}

class TypeMachine {

	private $writter;

	private $isInTestMode;

	public function __construct(Writter $writter, $isInTestMode)
	{
		$this->writter = $writter;
		$this->isInTestMode = $isInTestMode;
	}

	public function type($text)
	{
		$this->writter($text, $this->isInTestMode);
	}
}

```

This code has some flaws.

The `TypeMachine` has to implement some sort of logic in order to choose the value of the second parameter and this is not it's responsabilty to deal with that. This creates coupling between `TypeMachine` and `Writter`.

A better solution would be to inject a different `Writter` when running in test mode :

```php
<?php
interface Writter {

	public function write($text);
}

class SimpleWritter {

    public function write($text)
    {
		echo $text;
	}
}

class TestWritter {

	public function write($text)
	{
		echo "Test : " . $text;
	}
}

class TypeMachine {

	private $writter;

	public function __construct(Writter $writter)
	{
		$this->writter = $writter;
	}

	public function type($text)
	{
		$this->writter($text);
	}
}
```

We have add a `Writter`interface and two implementations, `SimpleWritter`and `TestWritter`. We can now choose which one we want to use regarding of the context.
As you see the code of the `TypeMachine` class is simpler too and all classes are easily testable.

As an aside we should be carefull when we start using flag parameters in method prototype because it usually indicates a some sort of missing concept. [A cool article](https://blog.8thlight.com/dariusz-pasciak/2015/05/28/alternatives-to-boolean-parameters.html) was written on 8th Light blog on how to remove this sort of parameters.


## Null object pattern

An other common use of if conditionals is to determine if an optional colaborator was provided before performing an operation on it.

One of the best example is the use of a logger :

```php
<?php
interface Logger {
	public function log($logMessage);
}

class TypeMachine {

	private $logger;

	public function setLogger(Logger $logger)
	{
		$this->logger = $logger;
	}

	public function type($text)
	{
		if($this->logger) {
			$this->logger($text . 'was typed.');
		}

		// do something
	}

}

```

Every time we want to log something we have to check wether the logger was set or not.

Using the Null object pattern, which consists in creating an implementation of an interface with no behaviour, we can remove this checks.

```php
<?php

interface Logger {
	public function log($logMessage);
}

class NullLogger {
	public function log($logMessage){}
}

class TypeMachine {

	private $logger;

	public function __construct()
	{
		$this->logger = new NullLogger;
	}

	public function setLogger(Logger $logger)
	{
		$this->logger = $logger;
	}

	public function type($text)
	{
		$this->logger($text . 'was typed.');

		// do something
	}

}
```

When the `TypeMachine` is instanciated its logger property is set to an instance of `NullLogger` allowing us to remove each `if($this->logger)` checks.

If you want to learn more about the Null object pattern you definitely should look at [Sandy Metz's Nothing is something talk](https://www.youtube.com/watch?v=29MAL8pJImQ).

I hope this article will help removing some if statements in this world making it a better place. If you have some other ways to remove if statements please share them !


Hey! I'm on [Twitter](https://twitter.com/selrahcd), if you want to discuss about OOP feel free to come by and say hi! You can comment below as well.


