AngularJS
+++++++++

.. highlight:: html

References
==========

* https://docs.angularjs.org/tutorial/step_03

Bootstrapping angularjs
=======================

There are 3 important things that happen during the app bootstrap:

1. The injector that will be used for dependency injection is created.
1. The injector will then create the root scope that will become the context for the model of our application.
1. Angular will then "compile" the DOM starting at the ngApp root element, processing any directives and bindings found along the way.

Directives
==========

ng-app
------


::

    <!--angular root-->
    <html ng-app>

AngularJS script tag:

::

    <script src="bower_components/angular/angular.js">

This code downloads the angular.js script which registers a callback 
that will be executed by the browser when the containing HTML page 
is fully downloaded. When the callback is executed, Angular looks 
for the **ngApp** directive.

ng-controller
-------------

::

    <body ng-controller="PhoneListCtrl">
    ...
    </body>


ng-controller, which attaches a PhoneListCtrl controller to the <body> tag

ng-repeat
---------

::

    <body ng-controller="PhoneListCtrl">
        <ul>
            <li ng-repeat="phone in phones">
                <span>{{phone.name}}</span>
                <p>{{phone.snippet}}</p>
            </li>
        </ul>
    </body>

* The **ng-repeat="phone in phones"** attribute in the <li> tag is an Angular repeater directive. The repeater tells Angular to create a <li> element for each phone in the list using the <li> tag as the template.
* The expressions wrapped in curly braces (**{{phone.name}} and {{phone.snippet}}**) will be replaced by the value of the expressions.


