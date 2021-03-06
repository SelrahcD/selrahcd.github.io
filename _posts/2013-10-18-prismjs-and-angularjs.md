---
layout: "post-no-feature"
title: Using PrismJs with AngularJs
description: "If you need to display code snippets in an AngularJs application you might want to read this !"
category: articles
tags: 
  - AngularJs
  - PrismJs
  - Dev
  - Javascript
published: true
comments: true
---

In a project I'm working on I need to display code snippets. I found [PrismJs](http://prismjs.com/) library, which is lightweight and cover a lot of languages. The application is based on AngularJs, and code snippets are displayed after having been read from an API and PrimsJs is run before code is injected in the template, when used as the documentation said, so highlighting doesn't work. The problem can be tackled down with the creation of a directive. Here is the code :

```javascript
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
```

For each HTML element marked with the prism attribute we wait that the inner DOM is fully loaded, using the ready function, and then trigger Prism highlighting on it.

```html
<pre>
    <code class="language-markup" prism>
    {% raw %}{{ snippet }}{% endraw %}
    </code>
</pre>
```

Here is the [Gist](https://gist.github.com/SelrahcD/7042692) !
