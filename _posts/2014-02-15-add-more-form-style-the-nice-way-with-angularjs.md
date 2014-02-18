---
layout: "post-no-feature"
title: Add more element forms the nice way with AngularJs
description: "Build a form with the classic add more element button in a cool way with AngularJs."
category: articles
tags: 
  - AngularJs
  - Form
  - Dev
  - Javascript
published: true
comments: true
---

We sometimes have to deal with forms where user can add items to a list. Most of the time an "Add more" button is created and we add an input to the form when it's clicked. I'll show you in this post how to build this type of form using AngularJs form handling mechanism.

Here is the result of what will be discussed on this post, with some more things like CSS and placeholders :

<iframe style="width:100%; height:450px;" src="http://embed.plnkr.co/LKlkaaenbf9OeJrmXVES/preview"></iframe>

As you can see the "Add an element" button is disabled if an item of the list is invalid (they are all required) and the "Save list" is disabled if one element of the form is invalid.

This example makes a deep use of the [form directive](http://docs.angularjs.org/api/ng.directive:form). AngularJs allows to interlock form directives. Each directive will regiter itself upon the one above in the DOM tree. Using a form directive is helpful when you have to check the validity of several inputs without having to do a combination of all inputs states.

We will use the "ng-form" version of the directive because form tag can't contain an other form tag.

First create a basic form for the list title. The submit button is disabled when the form is not valid. The form tag is one of the way to create a form directive.

{% highlight html linenos %}
<form name="listForm" ng-submit="saveList()" novalidate>
    <label for="list-title">List title</label>
    <input id="list-title" type="text" ng-model="list.title" required />
    <input type="submit" value="Save list" ng-disabled="listForm.$invalid">
</form>
{% endhighlight %}

Use ng-repeat for the item inputs. Here two more forms are created using the ng-form attribute : one for the list of element (itemsForm) and one for each element (itemForm). We are now able to do validation for one item and for the list. User can't add an item to the list if one of the existing elements is invlaid because the "Add an element" button is disabled when itemsForm is not valid. 
{% highlight html linenos %}
<form name="listForm" ng-submit="saveList()" novalidate>
    <label for="list-title">List title</label>
    <input id="list-title" type="text" ng-model="list.title" required />
    <b>List items</b>
    <ul ng-form="itemsForm">
        <li ng-repeat="item in list.items" ng-form="itemForm">
            <label for="itemText">List item</label>
            <input name="itemText" type="text" ng-model="item.text" required />
            <ul ng-show="itemForm.$invalid && itemForm.$dirty">
                <li ng-show="itemForm.itemText.$error.required">This field is required.</li>
            </ul>
        </li>
    </ul>
    <button ng-click="addElement()" ng-disabled="itemsForm.$invalid">Add an element</button>
    <input type="submit" value="Save list" ng-disabled="listForm.$invalid">
</form>
{% endhighlight %}

The code of the associated controller is easy to understand : when the addElement function is called a new empty object is pushed in the array of items and a new row will be displayed in the form.

{% highlight javascript linenos %}
angular.module('formDemo')
  .controller('FormCtrl', function ($scope) {

    $scope.list = {
        name: '',
        items: [{}]
    };

    $scope.addElement = function() {
        $scope.list.items.push({});
    };

    $scope.saveList = function() {
        alert('This is a dummy button but let\'s say the list has been saved !');
    };    
  });
{% endhighlight %}

If you have a question or want to discuss about this solution you can find me on [Twitter](https://twitter.com/Selrahcd) or comment this post.
