---
layout: "post-no-feature"
title: In modal nested states with AngularJs ui-router
description: "Create nested states in a modal using ui-router for your AngularJs application"
category: articles
tags: 
  - AngularJs
  - ui-router
  - modal
  - Dev
  - Javascript
published: true
comments: true
---

In an AngularJs application I'm working on we need to display details about an object on a modal and to be able to switch to an edit mode in the same modal.
An other requirement is that the modal is automatically opened when the user enters the application with a url pointing to an edit or a view mode.

We are using the modal system made by [Ui Bootstrap](http://angular-ui.github.io/bootstrap/) and the [Ui Router](https://github.com/angular-ui/ui-router) both created by the AngularUi team.

Ui Router allows to organize the interface using a state machine.

As described in the introduction we need at least three states. The first one shows a list of items, and the two others are our modal's states (view and edition of the item).

We also don't want the modal to close and open when switching between view and edition mode. Here helps a really cool feature of Ui Router : [abstract states](https://github.com/angular-ui/ui-router/wiki/Nested-States-%26-Nested-Views#abstract-states). An abstract state is a state that cannot be activated itself but can have child states. We use an abstract state to deal with the modal opening, view and edit mode are its child states.

Here is a plunker of the result :

<iframe style="width:100%; height:300px;" src="http://embed.plnkr.co/5Mmu4w/preview"></iframe>

In our application config we define a state for the list of items:
{% highlight javascript linenos %}
$stateProvider
  .state('list', {
    url: '/',
    template: '<ul><li ng-repeat="pony in ponies"><a ui-sref="view({id: pony.id})">{{ pony.name }}</a></li></ul>',
    controller: function($scope) {
      $scope.ponies = ponies;
    }
  });
{% endhighlight %}

We add the abstract state :
{% highlight javascript linenos %}
$stateProvider.state('modal', {
  abstract: true,
  parent: 'list',
  url: '',
  onEnter: ['$modal', '$state', function($modal, $state) {
      console.log('Open modal');
      $modal.open({
        template: '<div ui-view="modal"></div>',
        backdrop: false,
        windowClass: 'right fade'
      }).result.finally(function() {
        $state.go('list');
    });
  }]
});
{% endhighlight %}

The abstract state is a child of the list state and therefore can be activated at the same time of the list. When this state is activated a modal is opened and it contains a basic template with an other ui-view name modal. We also use $modal promise system to go back to the list state when the modal is closed.

We finally add the edit and view states :
{% highlight javascript linenos %}
$stateProvider.state('view', {
  url: ':id',
  parent: 'modal',
  views: {
    'modal@': {
      template: '<h1>{{ pony.name }}</h1><br />\
      <a ui-sref="edit({id: pony.id})">Edit</a><br />\
      <a href="#" ng-click="$close()">Close</a>',
      controller: function($scope, pony) {
        $scope.pony = pony;
      },
      resolve: {
        pony: function($stateParams) {
          return ponies[$stateParams.id];
        }
      }
    }
  }
})
.state('edit', {
  url: ':id/edit',
  parent: 'modal',
  views: {
    'modal@': {
      template: '<h1>Edit {{ pony.name }}</h1><br /> \
        <a ui-sref="view({id: pony.id})">View</a> <br />\
        <a href="#" ng-click="$close()">Close</a>',
      controller: function($scope, pony) {
        $scope.pony = pony;
      },
      resolve: {
        pony: function($stateParams) {
          return ponies[$stateParams.id];
        }
      }
    }
  }
});
{% endhighlight %}

They both inherit from the modal state and set the content of the modal view.
We use resolve to load the needed item accordingly to the url parameter, this allows the use to reach the application with an url such as /2/edit and to see both the items list and the modal open on edition mode. Cool huh ?

Here is the full sample of code which allows you to have two states in the same modal :
{% highlight javascript linenos %}
angular.module('app', ['ui.router', 'ui.bootstrap'])
  .config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    
    $urlRouterProvider.otherwise('/');
    
    var ponies = [{
      id: 0,
      name: 'Griotte'
    }, {
      id: 1,
      name: 'Eole'
    }, {
      id: 2,
      name: 'Rox'
    }];
    
    $stateProvider
      .state('list', {
        url: '/',
        template: '<ul><li ng-repeat="pony in ponies"><a ui-sref="view({id: pony.id})">{{ pony.name }}</a></li></ul>',
        controller: function($scope) {
          $scope.ponies = ponies;
        }
      })
      .state('modal', {
        abstract: true,
        parent: 'list',
        url: '',
        onEnter: ['$modal', '$state', function($modal, $state) {
            console.log('Open modal');
            $modal.open({
              template: '<div ui-view="modal"></div>',
              backdrop: false,
              windowClass: 'right fade'
            }).result.finally(function() {
              $state.go('list');
          });
        }]
      })
      .state('view', {
        url: ':id',
        parent: 'modal',
        views: {
          'modal@': {
            template: '<h1>{{ pony.name }}</h1><br />\
            <a ui-sref="edit({id: pony.id})">Edit</a><br />\
            <a href="#" ng-click="$close()">Close</a>',
            controller: function($scope, pony) {
              $scope.pony = pony;
            },
            resolve: {
              pony: function($stateParams) {
                return ponies[$stateParams.id];
              }
            }
          }
        }
      })
      .state('edit', {
        url: ':id/edit',
        parent: 'modal',
        views: {
          'modal@': {
            template: '<h1>Edit {{ pony.name }}</h1><br /> \
              <a ui-sref="view({id: pony.id})">View</a> <br />\
              <a href="#" ng-click="$close()">Close</a>',
            controller: function($scope, pony) {
              $scope.pony = pony;
            },
            resolve: {
              pony: function($stateParams) {
                return ponies[$stateParams.id];
              }
            }
          }
        }
      });
    }]);
{% endhighlight %}
