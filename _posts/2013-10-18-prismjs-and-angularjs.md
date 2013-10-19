---
layout: "post-no-feature"
title: Using PrismJs with AngularJs
description: If you need to display code snippets in an AngularJs application I got you covered.
category: articles
tags: 
  - AngularJs
  - PrismJs
  - Dev
  - Javascript
published: true
---

In a project I'm working on I need to display code snippets. I found [PrismJs](http://prismjs.com/) library, which is lightweight and cover a lot of languages. The application is based on AngularJs, and code snippets are displayed after having been read from an API and PrimsJs is run before code is injected in the template, when used as the documentation said, so highlighting doesn't work. The problem can be tackled down with the creation of a directive. Here is the code :

{% highlight javascript linenos %}
angular.module('Prism', []).
    directive('prism', [function() {
        return {
            restrict: 'A',
            link: function ($scope, element, attrs) {
                element.ready(function() {
                    Prism.highlightElement(element[0]);
                });
            }
        } 
    }]
);
{% endhighlight %}

For each HTML element marked with the prism attribute we wait that the inner DOM is fully loaded, using the ready function, and then trigger Prism highlighting on it.

{% highlight html linenos %}
<pre>
    <code class="language-markup" prim>
    \{\{ snippet \}\}
    </code>
</pre>
{% endhighlight %}

Here is the [Gist](https://gist.github.com/SelrahcD/7042692) !