---
layout: "post-no-feature"
title: Activable set for AngularJs
description: "A directive managing active class in a set of elements."
category: articles
tags: 
  - AngularJs
  - Dev
  - Javascript
published: false
---

We sometimes have to play with CSS classes to give users a feedback when an element is active or not, and this is an annoying thing to do. I decided to make a tool avoiding me to do this over and over and made it available.

This tool works using two directives. The first one allows us to define the set of elements we want to work on and the second on to add or remove the CSS class.

## How to use it


```html
<table>
  <thead>
    <tr>
      <td>Id</td>
      <td>Name</td>
    </tr>
  </thead>
  <tbody activable-set>
    <tr ng-repeat="user in users" activable>
    	<td ng-bind="user.id"></td><td ng-bind="user.name"></td>
    </tr>
  </tbody>
</table>
```

Add the activable-set attribute to an element. All children of this element marked with the activable element will belong to the same set.
If an inactive element is clicked the directive will add the active class to the element and remove the class from all other elements of the set. If an active element is clicked the active class is removed. 

### Options
You can apply some options to the system.
On the element with activable-set attribute :

- activable-max : Passing an integer to this attribute allow you to have several active items at the same time in the set.
- activable-unblock : When the limit of selected items is reached the first selected item is unactivated and the clicked item is activated.
- on-max-items : You can pass a callback which will be called when the limite of selected item is reached.

On the elements with the activable attribute:

- on-activate : A callback called when the element is activated
- on-deactivate : A callback called when the element is deactivated
- active-class : If you want to use an other class than active to mark an element as active you can change the value of the used class by setting this attribute to whatever the class you want to use.

## Get it
This tool is available as a bower package. Add BLLLLLA to you project dependencies, load bLLLL module in your angular application and you're good to go.