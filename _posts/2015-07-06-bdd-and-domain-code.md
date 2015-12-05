---
layout: "post-no-feature"
title: BDD and domain code
description: "How to use Behat as a design tool."
category: articles
tags:
  - Dev
  - Php
  - DDD
  - Behat
  - BDD
  - tshirtaday
published: true
comments: true
---

[Behat](http://docs.behat.org/en/v2.5/) is a well known tool for end-to-end testing but as [Konstantin Kudryashov](https://twitter.com/everzet) pointed out in his article [Introducing Modelling by Example](http://everzet.com/post/99045129766/introducing-modelling-by-example) it can be used as a modeling tool too.

As Konstantin points out writing features using an [ubiquitous language](http://martinfowler.com/bliki/UbiquitousLanguage.html) shared by developers and stackholders reduce the cost of translation and thus the number of errors in the application.

In the [t-shirt a day project](/articles/-tshirt-a-day-serie/) one of the feature is that an admin can manage a t-shirt catalog. This feature is described using Gherkin language and scenario are tested using Behat.

```gherkin
Feature:
    As an admin
    I want to manage the TShirt Catalog

Scenario: Adding a TShirt to the catalog
    Given a new catalog is created
    When an admin adds a TShirt with description "La Ruda Japan Tour" to the catalog
    Then the catalog should contain 1 TShirt

Scenario: Removing a TShirt to the catalog
    Given a new catalog is created
    Given a TShirt with id 12345 is added to the catalog
    When an admin removes the TShirt with id 12345 from the catalog
    Then the catalog should contain 0 TShirt
```

As you can see scenarios are written using terms coming from the business and say nothing about the implementation, developers and stackholders are sharing the same language which remove one layer of translation.

The second layer of translation, from a language understood by developers to code, can be reduced using the DDD advice to use the ubiquitous language in code too. As you'll see below the code expresses the feature requirements in a way that should allow non developers to read it with a little help.

```php
<?php 
class ManageCatalogContext implements Context, SnippetAcceptingContext
{
    private $catalog;

    /**
     * @Given a new catalog is created
     */
    public function aNewCatalogIsCreated()
    {
        $this->catalog = new InMemoryCatalog;
    }

    /**
     * @When an admin adds a TShirt with description :description to the catalog
     */
    public function anAdminAddsATshirtWithDescriptionToTheCatalog($description)
    {
        $admin = new Admin;
        $admin->addTShirtWithDescriptionToCatalog($description, $this->catalog);
    }

    /**
     * @Then the catalog should contain :count TShirt
     */
    public function theCatalogShouldContainTshirt($count)
    {
        \PHPUnit_Framework_Assert::assertEquals($count, count($this->catalog->all()));
    }

    /**
     * @Given a TShirt with id :id is added to the catalog
     */
    public function aTshirtWithIdIsAddedToTheCatalog($id)
    {
        $this->catalog->add(new TShirt(new TShirtId($id), 'Dummy description'));   
    }

    /**
     * @When an admin removes the TShirt with id :id from the catalog
     */
    public function anAdminRemovesTheTshirtWithIdFromTheCatalog($id)
    {
        $admin = new Admin;
        $admin->removeTShirtWithIdFromCatalog(new TShirtId($id), $this->catalog);
    }
}
?>
```

As you can see the cost of translation has been reduced a lot using this approach.

As an aside I have to admit that I have some trouble writing user stories and the article [What's in a story](http://dannorth.net/whats-in-a-story/) helped me a lot and is a very good reference.

Hey ! I'm on [Twitter](https://twitter.com/selrahcd) too, if you want to chat about the bot or something else. Feel free to comment below as well.


