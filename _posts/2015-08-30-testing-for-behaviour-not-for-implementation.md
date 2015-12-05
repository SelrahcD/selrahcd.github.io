---
layout: "post-no-feature"
title: Test for behaviour not for implementation
description: "Avoid coupling between tests and implementation by testing for behaviour"
category: articles
tags: 
  - Php
  - Dev
  - Testing
  - Unit tests
  - Phpunit
published: true  

---

While working on [SearchCache](https://github.com/SelrahcD/SearchCache) I made a test which was ensuring that two shared search results coming from a same search - using the same search parameters - should be stored using the same key.

Here it is :

``` php
<?php
public function testStoringSharedResultWithSameParametersUsesTheSameKey()
    {
        $searchCache = new SearchCache($this->searchResultStore, $this->keyGenerator);

        $params = [
            'name' => 'test',
            'age'  => 12,
        ];

        $result1 = [1, 'AA', 3, "HUG76767"];
        $result2 = [1, 'AA', 3, "AAA"];

        $this->shouldStoreSharedResult($result1, $key1);

        $searchCache->storeSharedResult($params, $result1);

        $this->shouldStoreSharedResult($result2, $key2);

        $searchCache->storeSharedResult($params, $result2);

        $this->assertEquals($key1, $key2);
    }
?>
```

The method `shouldStoreSharedResult` allows me to get the key used when the result is stored so I can later compare them for equality.

This was not feeling right to me. It bothered me so much that I removed the test before adding it back. I had the uncomfortable impression that the test was knowing way to much thing about the system.

As you can see the test is tightly coupled to the implementation and gives us some information about it. For instance we know that the system uses keys.

Further thinking lead me to ask myself what I wanted to achieve with the system : I want the searchCache to replace an old version of a shared search cache with a newer one when possible.

I made some [refactoring on my tests](https://github.com/SelrahcD/SearchCache/commit/a7c20ce3a519592a8a814e8dd9d2d8eda70e738d) in order to have tests reflecting what the system should do instead of how it does its job. Furthemore I decided that I could get rid of my mocks created with Mockery and use a [stub](https://github.com/SelrahcD/SearchCache/blob/master/tests/Stubs/SearchResultsStores/InMemorySearchResultStore.php) instead. The test now looks like this and doesn't leak any details about the implementation :

```php
<?php
public function testIfAPreviousVersionOfSharedResultIsStoredItsReplacedWhenANewOneIsStored()
    {
        $params = [
            'name' => 'test',
            'age'  => 12,
        ];

        $result1 = [1, 'AA', 3, "HUG76767"];
        $result2 = [1, 'AA', 3, "Oho"];

        $this->storeContainsSharedResult($params, $result1);

        $this->searchCache->storeSharedResult($params, $result2);

        $key = $this->searchCache->getCopyOfSharedResult($params);

        $this->assertEquals($result2, $this->searchCache->getResult($key));
    }
?>
```

I have the impression that using a mocking library pushed me on the coupling path and I'll try to keep an eye on this in order to avoid making that same mistake again since I have already been proven guilty of this several times. Using mocks adds up a lot to the risk of creating false positive tests - [see this article](http://www.thoughtworks.com/insights/blog/mockists-are-dead-long-live-classicists) - and having a test suite that give you a false impression of confidence is probably worst than not having tests...

Previous article was linked to a blog post where Fabio Pereira discussed the issue of writing a test which is a mirror of the implementation in his [Tautological Test Driven Development article](http://fabiopereira.me/blog/2010/05/27/ttdd-tautological-test-driven-development-anti-pattern/). This is exactly what I was doing, Tautological TDD.

I still have to rewrite some of the tests to decouple them from the implementation but I'm pretty confident that writing them with behaviour in mind and without a mocking library will help make them cleaner and simpler.

I guess this episode taught me a valuable lesson. Cool.

Hey ! I'm on [Twitter](https://twitter.com/selrahcd) too, if you want to chat about testing or something else. Feel free to comment below as well.



