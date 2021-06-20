---
layout: "post-no-feature"
title: Being lazy with Postman scripts and dynamic variables
description: "Simplify your workflow working with API automating call with Postman and generating values for each call."
category: articles
tags:
 - API
 - Postman
 - productivity
published: true
comments: true
---

I'm probably really late to the show as Postman is known to be a great tool when it comes to work with API. I've never took the time to dig in what this tool can do but I recently had a workflow involving generating and copy-pasting UUIDs from responses to requests and decided to see if this could be automated and it turns out it can, relatively easily even.

## Problem

Pretend we are working with an API allowing us to create an inventory for goods stored in fridge. The API is simple and offers two actions :

* Registering a fridge to be tracked is done via a `PUT` on `/fridges/{fridgeId}` where `{fridgeId}` is an UUID. The request body is not relevant for this example. A valid call will return a json response containing a field `id` with the provided UUID.

* Tracking that a product is stored in the fridge is done via a `PUT` on `/fridges/{fridgeId}/products` where `{fridgeId}` is an UUID identifying an already registered fridge. The content of the request body and the response are not relevant for this example.

We would like to be able to generate an UUID when the registration route is called and avoid relying on another tool to get an UUID and then copy-past it in the URL input.

We'd also like to keep track of that UUID and be able to call the product stored tracking route with that newly created UUID without having to mess with input URL as well.


## Generating a new UUID

Postman is able to deal with variables and even provides some [dynamic variables](https://learning.postman.com/docs/writing-scripts/script-references/variables-list/) which are replaced with some random values when the call is executed.
One of them is `{% raw %}{{$guid}}{% endraw %}` and is replaced by an UUID.

We can change the input field to make us of `{% raw %}{{$guid}}{% endraw %}`, the URL can be modified to include `/fridges/{% raw %}{{$guid}}{% endraw %}`

![URL using {{$guid}}](/images/2020-09-28-being-lazy-with-postman/input1.png)

Now everytime we will send the request a new UUID will be generated and used.

First problem solved!

## Reusing the UUID for storing product

We are able to access the newly created UUID looking at the response of the registering call. This is the UUID we want to reuse for our call to store a product.

In order to automate the process and avoid copy-pasting the UUID from the response to the URL input field each and everytime we will take advantage of Postman scripting capability.

Postman allows to [run scripts before and after every call](https://learning.postman.com/docs/writing-scripts/intro-to-scripts/). Just below the URL input, alongside requests parameters you'll notice two tabs, Pre-request Script and Tests.

![View of the tabs](/images/2020-09-28-being-lazy-with-postman/tabs.png)

The Tests tab can be used to execute tests after a request is made but can also be used to execute a script.

By adding `pm.environment.set('fridgeId', pm.response.json().id)` in the Tests tab input we instruct Postman to read the response, look for the `id` field in the JSON and store it in a `fridgeId` variable.

![Test input](/images/2020-09-28-being-lazy-with-postman/test-input.png)

We are now able to use the `fridgeId` for any subsequent call. The URL used for storing a product can be changed to `/fridges/{fridgeId}/products`.

![New url input with {{fridgeId}} variable](/images/2020-09-28-being-lazy-with-postman/input2.png)

## A new workflow

We've greatly simplified our workflow :

* Everytime we want to register a new fridge we only need to visit the request tab for fridge registration and click send
* We can store a product in the newly created fridge by clicking send on the other request tab as the request will use the fridge UUID directly.

No more UUID generation using external tool and no more copy pasting !






