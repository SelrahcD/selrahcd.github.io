---
layout: "post-no-feature"
title: Refactoring VoteValidator with tests
description: "Some lessons learned about testing"
category: articles
tags:
  - Dev
  - testing
  - phpunit
  - tshirtaday
published: true
comments: true
---

A few days ago I decided that the [t-shirt a day application](/articles/-tshirt-a-day-serie/) doesn't need the complexity of a vote validator with a validation handler and only a method stating if a vote is valid or not returning a boolean and then starting [refactoring](https://github.com/SelrahcD/tshirtaday/compare/db07728ab8ca5142ce1ed73d7ffbeb3fcdc9f8ca...b9c1b02fea17059baa69f9c6b85c280684fe82d6).

The process of recfactoring was not painfull thanks to the test suite already there but I must admit that I have spoted some flaws in my VoteValidator tests.

## A cleaner VoteValidator

A vote is valid if :

* The voter has note already voted for a Tshirt for the given day
* The Tshirt has not been elected yet
* A voting session is opened for that day

and I wanted the code to express this requirements clearly.

The isValid has been refactored to use 3 private methods each one dealing with one rule :

{% highlight PHP linenos %}
<?php
class VoteValidator
{
    public function isValid(Vote $vote)
    {
        return $this->voterHasNotAlreadyVotedForDay($vote->voterId(), $vote->day())
            && $this->tshirtExistsAndHasNotBeenElectedYet($vote->tshirtId())
            && $this->aVotingSessionIsOpenedForDay($vote->day());
    }
}
?>
{% endhighlight %}

This is the point I started to think that I probably should be able to switch lines and still have the test going green and tried to do so. Well, tests were failing.

## Testing the right thing

I'll take a simpler example that the one above with only two conditions to describe what I did wrong when I first wrote the tests.

Let's define a simple class :

{% highlight PHP linenos %}
<?php
class Tuple
{
    public $a;

    public $b;

    public function __construct($a, $b)
    {
        $this->a = $a;
        $this->b = $b;
    }
}
?>
{% endhighlight %}

A tuple is valid if :

* Element A exists
* Element B exists


The tuple validator would have been something like this :

{% highlight PHP linenos %}
<?php
class TupleValidator
{
    private $elementARepository;

    public function __construct(ElementRepository $elementRepository)
    {
        $this->elementRepository = $elementRepository;
    }

    public function isValid(Tuple $tuple)
    {
        return $this->elementAExists($tuple->a)
            && $this->elementBExists($tuple->b);
    }

    private function elementAExists($a)
    {
        return $this->elementRepository->exists($a) !== null;
    }

    private function elementBExists($b)
    {
        return $this->elementRepository->exists($b) !== null;
    }
}
?>
{% endhighlight %}

In the TupleValidatorTest the method asserting that isValid returns false if A doesn't exist would have been :

{% highlight PHP linenos %}
<?php
class TupleValidatorTest
{
    private $elementRepository;

    public function setUp()
    {
        $this->elementRepository = \Mockery::mock('ElementRepository');
    }

    /**
     * @test
     */
    public function should_return_false_if_A_doesnt_exist()
    {
        $a = 'A';
        $b = 'B';

        $tuple = new Tuple($a, $b);

        $validator = new TupleValidator($elementRepository);

        $this->elementRepository->shouldReceive('exists')->with($a)->andReturn(false);

        $this->assertFalse($validator->isValid($tuple));
    }
}
?>
{% endhighlight %}

The test will pass.

Now if I invert the two test in the isValid method :

{% highlight PHP linenos %}
<?php
// TupleValidator
public function isValid(Tuple $tuple)
{
    return $this->elementBExists($tuple->b)
        && $this->elementAExists($tuple->a);
}
?>
{% endhighlight %}

the test is failing because the ElementRepository mock wasn't expecting a call for "exists" method with B as parameter.
The implementation and the test are tightly coupled, which is bad.

The mistake here is that I don't set up the system properly. If I want to test that isValid returns false when A doesn't exist I should ensure that B exists because I don't want a false positive test passing because B is considered unexistant too.

Let me introduce two more methods in the test class in order to make tests easier to read :

{% highlight PHP linenos %}
<?php
// TupleValidatorTest
public function elementExists($element)
{
    $this->elementRepository->shouldReceive('exists')->with($element)->andReturn(true);
}

public function elementDoesntExist($element)
{
    $this->elementRepository->shouldReceive('exists')->with($element)->andReturn(false);
}
?>
{% endhighlight %}

We can now write the tests with the correct set up :

{% highlight PHP linenos %}
<?php
// TupleValidatorTest
/**
 * @test
 */
public function should_return_false_if_A_doesnt_exist()
{
    $a = 'A';
    $b = 'B';

    $tuple = new Tuple($a, $b);

    $validator = new TupleValidator($elementRepository);

    $this->elementDoesntExist($a);
    $this->elementExists($b);

    $this->assertFalse($validator->isValid($tuple));
}
?>
{% endhighlight %}

This test will pass whatever the order of the assertions in isValid is.

I think starting with the test for the positive result helps because you have to set up the whole system in order to make it pass and you have a template for all the negative results.

Here are all the correct tests for the TupleValidator :

{% highlight PHP linenos %}
<?php
// TupleValidatorTest
/**
 * @test
 */
public function should_return_true_if_A_and_B_exist()
{
    $a = 'A';
    $b = 'B';

    $tuple = new Tuple($a, $b);

    $validator = new TupleValidator($elementRepository);

    $this->elementExists($a);
    $this->elementExists($b);

    $this->assertTrue($validator->isValid($tuple));
}

/**
 * @test
 */
public function should_return_false_if_A_doesnt_exist()
{
    $a = 'A';
    $b = 'B';

    $tuple = new Tuple($a, $b);

    $validator = new TupleValidator($elementRepository);

    $this->elementDoesntExist($a);
    $this->elementExists($b);

    $this->assertFalse($validator->isValid($tuple));
}

/**
 * @test
 */
public function should_return_false_if_B_doesnt_exist()
{
    $a = 'A';
    $b = 'B';

    $tuple = new Tuple($a, $b);

    $validator = new TupleValidator($elementRepository);

    $this->elementExists($a);
    $this->elementDoesntExist($b);

    $this->assertFalse($validator->isValid($tuple));
}
?>
{% endhighlight %}

When writing a test be sur to set up the system in a state that allows you to test what you think you are testing.

This is a rather long post and even if I noticed something else during the refactoring I'll stop now and keep this for a futur article.

Hey ! I'm on [Twitter](https://twitter.com/selrahcd) too, if you want to chat about testing or something else. Feel free to comment below as well.
