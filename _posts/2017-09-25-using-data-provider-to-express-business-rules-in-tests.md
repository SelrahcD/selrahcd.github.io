---
layout: "post-no-feature"
title: Using data provider to express business rules in test
description: "Data provider to the rescue when it comes to test case naming."
category: articles
tags:
 - Dev
 - DDD
published: true
comments: true
---

When we write tests we want to achieve several things: ensure that the code works, create documentation, gain feedback about the ease of use of the system we are building and the quality of it's design.

Creating documentation with tests goes through good test case naming. We want the name of our test cases to express the behavior of the system under test, or even better, the business rules of the domain.

As I was working around data providers with PhpUnit I noticed they offer a good opportunity to work toward that goal.

```php
<?php
class DishTest extends PHPUnit_Framework_TestCase {

	public function test_is_vegan_if_empty(){
		$dish = new Dish([]);
		$this->assertTrue($dish->isVegan());
	}

	public function test_is_not_vegan_if_it_contains_meat()
	{
		$dish = new Dish(['meat']);
		$this->assertFalse($dish->isVegan());
	}

	public function test_is_not_vegan_if_it_contains_cheese()
	{
		$dish = new Dish(['cheese']);
		$this->assertFalse($dish->isVegan());
	}

	public function test_is_not_vegan_if_it_contains_egg()
	{
		$dish = new Dish(['egg']);
		$this->assertFalse($dish->isVegan());
	}
}
```


This test class fails at expressing the business rule. Every test case name is an example.

Using a data provider we can manage to reduce the number of test cases and to express the business rule in a clearer way.

```php
<?php
class DishTest extends PHPUnit_Framework_TestCase {

	public function test_is_vegan_if_empty(){
		$dish = new Dish([]);
		$this->assertTrue($dish->isVegan());
	}

	/**
	 * @dataProvider nonVeganDishes
	 */
	public function test_is_not_vegan_if_it_contains_non_vegan_aliments($dish)
	{
		$this->assertFalse($dish->isVegan());
	}

	public function nonVeganDishes()
	{
		return [
			'A dish with meat' => [new Dish(['meat'])],
			'A dish with cheese' => [new Dish(['cheese'])],
			'A dish with egg' => [new Dish(['egg'])],
		];
	}
}

```

Through the introduction of the data provider we made a separation between the business rule, in the test case name, and the supporting examples, provided by the data provider.

We've partly achieved our goal, the two remaining test cases convey way more information about the business rule. Still having the same rule expressed in a positive and a negative way feels really strange.

We can keep the business rule expressed in the positive way if we modify the data provider in order to include the expected result.

First, because we want to keep our tests as readable as we can, we should introduce two constants

```php
const IS_VEGAN = true;
const IS_NOT_VEGAN = false;
```

Then we can modify the tests cases and the data provider.

```php
<?php
class DishTest extends PHPUnit_Framework_TestCase {

	const IS_VEGAN = true;
	const IS_NOT_VEGAN = false;

	/**
	 * @dataProvider dishes
	 */
	public function test_is_vegan_if_it_contains_only_vegan_aliment($dish, $isVegan)
	{
		$this->assertEquals($isVegan, $dish->isVegan());
	}

	public function dishes()
	{
		return [
			'An empty dish is vegan' => [new Dish([]), self::IS_VEGAN],
			'A dish with fruits is vegan' => [new Dish(['fruits']), self::IS_VEGAN],
			'A dish with meat is not vegan' => [new Dish(['meat']), self::IS_NOT_VEGAN],
			'A dish with cheese is not vegan' => [new Dish(['cheese']), self::IS_NOT_VEGAN],
			'A dish with egg is not vegan' => [new Dish(['egg']), self::IS_NOT_VEGAN],
		];
	}
}

```

Our test class now fully communicates the business rule as a domain expert would express it.

## Listening to the test
Tests provide a good opportunity to reflect on the quality of the system design.

When we take a look at the test name and the associated examples we can see the mismatch between them. We are talking about non vegan food in the name but are using aliment names such as meat or cheese. This is a hint we might want the aliment to convey the information about whether it's vegan or not. We then would be able to simplify our test with factory methods for vegan or non vegan aliment.

Hey! I'm on [Twitter](https://twitter.com/selrahcd) wher I sometimes talks about testing too ! You can comment below as well if you feel like doing so !
