---
layout: post-no-feature
title: Extra readable tests
description: "Some tricks to make your tests readable"
category: articles
tags:
  - Dev
  - tests
published: true
comments: true

---

I've been doing some experiments with tests for the last few weeks. In this article I'll share some tricks I've learned from others, mainly [Sandro Mancuso](https://www.youtube.com/watch?v=XHnuMjah6ps), [Matthias Verraes](https://www.youtube.com/watch?v=1_dpOZmKXBw), and, of course, from [Growing Oriented Object Software Guided By Tests](http://www.growing-object-oriented-software.com/) - the GOOS - by Nat Pryce and Steve Freeman.

In this article I will refactor the following test one step at a time in order to make it even more readable than it is right now.
The test framework I'm using here is [PhpUnit](https://phpunit.de/) but the following technics work with other frameworks - I've applied some of them with [PhpSpec](http://www.phpspec.net/). By the way some technics are heavily inspired by this great tool. 

```php
<?php
class SendWelcomeEmailToMemberTest extends PHPUnit_Framework_TestCase {
    protected function tearDown() {
        Mockery::close();
    }

    /**
     * @test
     */
    public function it_sends_a_welcome_email_to_a_member() {
        $mailSender = Mockery::mock(MailSender::class);

        $welcomeMailSender = new WelcomeMailSender($mailSender);

        $mailSender->shouldReceive('send')
           ->with(Mockery::any(new Email(
           'charles@test.fr',
           'us@chorip.am',
           'Welcome',
           'Hey! Welcome!')
           ))
           ->once();

        $welcomeMailSender->sendTo(
            new Member('Charles', 'charles@test.fr')
        );
    }
}
```

## Snake-case test name
As you can see I don't use the classical PhpUnit test naming form, `testWhatItSupposedToDo`, but prefer to use snake-case notation and to start test name with `it_` - which forces me to use the `@test` annotation. Starting the test name with `it_` helps me to think harder in order to come up with a good name for the test.

## Arrange - Act - Assert
First change is to reorganize the test to be in the form of `Arrange - Act - Assert`. Having all tests following this model helps knowing what the expectations are, as they all are at the end of the scenario. In the current version an assertion - an email should be sent - is made before the acting step.

The change here is to use a *Spy* instead of a *Mock*. You can read on the different types of stubs [here](https://adamcod.es/2014/05/15/test-doubles-mock-vs-stub.html).

```php
<?php
    /**
     * @test
     */
    public function it_sends_a_welcome_email_to_a_member() {
        // Arrange    
        $mailSender = Mockery::spy(MailSender::class); // Use a spy instead of a mock

        $welcomeMailSender = new WelcomeMailSender($mailSender);

        // Act
        $welcomeMailSender->sendTo(
            new Member('Charles', 'charles@test.fr')
        );

        // Assert
        $mailSender->shouldHaveReceived('send')
            ->with(Mockery::any(new Email(
                'charles@test.fr',
                'us@chorip.am',
                'Welcome',
                'Hey! Welcome!')
                ))
            ->once();
    }
    
```

## Builder

Let's now imagine that the class `Member` is central to our application and is used in a lot of tests, all of them having to call the constructor in order to get `Member`s. A new requirement is made : A member should have a birth date. We must add an extra parameter to all calls to `Member` constructor. Trust me, when you will face this situation you probably be very disappointed.

A solution is to introduce a [builder](https://en.wikipedia.org/wiki/Builder_pattern) which will encapsulate the call to `Member` constructor. We are now able to do the change in only one place.

Using a builder for member and email gives us the following test :

```php
<?php

    /**
     * @test
     */
    public function it_sends_a_welcome_email_to_a_member() {
        $mailSender = Mockery::spy(MailSender::class);

        $welcomeMailSender = new WelcomeMailSender($mailSender);

        $charles = (new MemberBuilder)
            ->withFirstName('Charles')
            ->withEmailAddress('charles@test.fr')
            ->build();

        $welcomeMailSender->sendTo($charles);

        $welcomeEmail = (new EmailBuilder)
            ->from('us@chorip.am')
            ->to('charles@test.fr')
            ->withSubject('Welcome')
            ->withContent('Hey! Welcome!')
            ->build();

        $mailSender->shouldHaveReceived('send')->with(Mockery::any($welcomeEmail))->once();
    }
```

The code for `MemberBuilder` is the following :

```php
<?php
final class MemberBuilder {
    private $firstname;
    private $emailAddress;
    private $birthDate;

    /**
     * MemberBuilder constructor.
     */
    public function __construct() {
        $faker = \Faker\Factory::create();
        $this->emailAddress = $faker->email;
        $this->firstname = $faker->firstname;
        $this->birthDate = $faker->date;
    }

    public function build() {
        return new Member($this->firstname, $this->emailAddress, $this->birthDate);
    }

    /**
     * @param $firstname
     * @return MemberBuilder
     */
    public function withFirstName($firstname) {
        $this->firstname = $firstname;

        return $this;
    }

    /**
     * @param $emailAddress
     * @return MemberBuilder
     */
    public function withEmailAddress($emailAddress) {
        $this->emailAddress = $emailAddress;

        return $this;
    }

    /**
     * @param $birthDate
     * @return MemberBuilder
     */
    public function bornOn($birthDate) {
        $this->birthDate = $birthDate;

        return $this;
    }
}

```

Notice that I'm using [Faker](https://github.com/fzaninotto/Faker), a library helping to create fake data for a lot of types. Faker helps creating default values for the member, each time different, ensuring that we are not making any assumptions based on a fixed value. Furthermore providing a default value allows to specify only the pieces of information required for the test. For instance if we are in need of a `Member` without any particularity we can call `(new MemberBuilder)->build()` and we will get a valid `Member`.

## Builder functions

If we want to make the test even easier to read we can hide the call to the builders behind a function. If we introduce the two following functions :

```php
<?php

function aMember() {
    return new MemberBuilder;
}

function anEmail() {
    return new EmailBuilder;
}
```

We can rewrite our test like this :

```php
<?php
    /**
     * @test
     */
    public function it_sends_a_welcome_email_to_a_member() {
        $mailSender = Mockery::spy(MailSender::class);

        $welcomeMailSender = new WelcomeMailSender($mailSender);

        $charles = aMember() // Creates a member
            ->withFirstName('Charles')
            ->withEmailAddress('charles@test.fr')
            ->build();

        $welcomeMailSender->sendTo($charles);

        $welcomeEmail = anEmail() // Creates an email
            ->from('us@chorip.am')
            ->to('charles@test.fr')
            ->withSubject('Welcome')
            ->withContent('Hey! Welcome!')
            ->build();

        $mailSender->shouldHaveReceived('send')
            ->with(Mockery::any($welcomeEmail))->once();
    }
```

## Helper methods

If we want to write our tests using the business vocabulary we can introduce helper methods as following :

```php
<?php
class SendWelcomeEmailToMemberTest extends PHPUnit_Framework_TestCase {
    private $mailSender;
    private $welcomeMailSender;

    public function setUp() {
        $this->mailSender = Mockery::spy(MailSender::class);
        $this->welcomeMailSender = new WelcomeMailSender($this->mailSender);
    }

    protected function tearDown() {
        Mockery::close();
    }

    /**
     * @test
     */
    public function it_sends_a_welcome_email_to_a_member() {
        $charles = $this->it_exists(aMember()
            ->withFirstName('Charles')
            ->withEmailAddress('charles@test.fr')
        );

        $this->welcomeMailSender->sendTo($charles);

        $this->it_should_send(anEmail()
            ->from('us@chorip.am')
            ->to('charles@test.fr')
            ->withSubject('Welcome')
            ->withContent('Hey! Welcome!')
        );
    }

    private function it_exists(MemberBuilder $member) {
        return $member->build();
    }

    private function it_should_send(EmailBuilder $email) {
        $this->mailSender->shouldHaveReceived('send')
            ->with(Mockery::any($email->build()))->once();
    }
}
```

As you can see the test reads easily and business people would be able to understand what is going on reading it. The test can now serve as documentation both for developers and business people.

## Going further

### Create plug-in for the test framework
The test could be even clearer if we could replace `$this` before in the call to helper methods by `given()` and `then()`. I made the following code work using a class with a static property but I think we could do something better with a plug-in for the test framework.

```php
<?php

    /**
     * @test
     */
    public function it_sends_a_welcome_email_to_a_member() {
        $charles = given()->it_exists(aMember()
            ->withFirstName('Charles')
            ->withEmailAddress('charles@test.fr')
        );

        $this->welcomeMailSender->sendTo($charles);

        then()->it_should_send(anEmail()
            ->from('us@chorip.am')
            ->to('charles@test.fr')
            ->withSubject('Welcome')
            ->withContent('Hey! Welcome!')
        );
    }
```

### Generate documentation
I think the tests are clear enough but if the business people are really reluctant to look at code or to deal with versioning systems we probably can parse the test class and generate a documentation in a better format for them.


All these technics can be used one at a time as they solve different problems but when combined they give a really good result.

As always using them as a cost which should be balanced regarding the interest of the project you are working on.

I hope this tricks will help you write tests you're happy with in the long run.

Hey! I'm on [Twitter](https://twitter.com/selrahcd) and I would be happy to learn your tricks about testing ! You can comment below as well.


