Prog : javascript
+++++++++++++++++

.. contents::

.. highlight:: javascript

References
==========

* http://www.w3schools.com/jsref/default.asp

Datatypes
=========

In JavaScript there are 5 different data types that can contain values:

* string
* number
* boolean
* object
* function

There are 3 types of objects:

* Object
* Date
* Array

And 2 data types that cannot contain values:

* null
* undefined

**A JavaScript object is an unordered collection of variables called named values.**

Note

* The data type of **NaN is number**
* The data type of **an array is object**
* The data type of **a date is object**
* The data type of **null is object**
* The data type of **an undefined variable is undefined**

::

    function isArray(myArray) {
        return myArray.constructor.toString().indexOf("Array") > -1;
    }

    function isDate(myDate) {
        return myDate.constructor.toString().indexOf("Date") > -1;
    }

JavaScript Objects are Mutable

::

     var person = {firstName:"John", lastName:"Doe", age:50, eyeColor:"blue"}

     var x = person;
     x.age = 10;           // This will change both x.age and person.age

The JavaScript prototype property allows you to add new properties to an existing prototype:

::

    //adds a new property nationality to person class
    person.prototype.nationality = "English";

Variables
=========

Global vs functions variables

::
    // Global variable
    function myFunction() {
        carName = "Volvo";
    }

    // Function local variable
    function myFunction() {
        var carName = "Volvo";
    }

Syntax
======

**"use strict"** enforces strict declaration of all variables

variables, A variable declared without a value will have the value **undefined**.

::

    ==      equal to
    ===     equal value and equal type

    var carName;
    var carName = "Volvo";
    var cars = ["Saab", "Volvo", "BMW"];           // Array
    var x = {firstName:"John", lastName:"Doe"};    // Object
    var x = true;                                  // boolean
    var y = false;
    var car = "";                // The value is "", the typeof is string

    typeof "John"                // Returns string
    typeof 3.14                  // Returns number
    typeof false                 // Returns boolean
    typeof [1,2,3,4]             // Returns object
    typeof {name:'John', age:34} // Returns object
    // The typeof operator in JavaScript returns "function" for functions.
    // The arguments.length property returns the number of arguments received when the function was invoked:
    // The toString() method returns the function as a string:


    var person = null;           // Value is null, but type is still an object
    var person = undefined;      // Value is undefined, type is undefined
    null === undefined           // false
    null == undefined            // true


    // Strings can be objects
    var x = "John";                 // typeof x will return string
    var y = new String("John");     // typeof y will return object


    // Numbers can be objects
    var x = 123;                    // typeof x returns number
    var y = new Number(123);        // typeof y returns object


    //You Can Have Different Objects in One Array
    var cars = ["Saab", "Volvo", "BMW"];           // Array
    myArray[0] = Date.now;
    myArray[1] = myFunction;
    myArray[2] = myCars;
    fruits[fruits.length] = "Lemon";     // adds a new element (Lemon) to fruits
    //Adding elements with high indexes can create undefined "holes" in an array:
    fruits[10] = "Lemon";                // adds a new element (Lemon) to fruits
    fruits.join(" * ");                  // joins array elements with separator
    fruits.pop();
    fruits.push("Kiwi");
    fruits.shift();                     // Removes the first element "Banana" from fruits
    fruits.unshift("Lemon");            // Adds a new element "Lemon" to fruits

    // If you use a named index, when accessing an array,
    // JavaScript will redefine the array to a standard object,
    // and all array methods and properties will produce undefined
    // or incorrect results.
    In JavaScript, arrays use numbered indexes.
    In JavaScript, objects use named indexes.


    // Looping through the properties of an object:
    for (x in person) {
        txt += person[x];
    }


    // The delete keyword deletes both the value of the property and the property itself.
    // After deletion, the property cannot be used before it is added back again.
    delete person.age;   // or delete person["age"];


    // Defining a new class/object type
    function person(first, last, age, eyecolor) {
        this.firstName = first;
        this.lastName = last;
        this.age = age;
        this.eyeColor = eyecolor;
    }



    (function () {
        var x = "Hello!!";      // I will invoke myself
    })();


Pass by value/reference
=======================

Arguments are Passed by Value

* The parameters, in a function call, are the function's arguments.
* JavaScript arguments are passed by value: The function only gets to know the values, not the argument's locations.
* If a function changes an argument's value, it does not change the parameter's original value.
* Changes to arguments are not visible (reflected) outside the function.

Objects are Passed by Reference

* In JavaScript, object references are values.
* Because of this, it looks like objects are passed by reference:
* If a function changes an object property, it changes the original value.
* Changes to object properties are visible (reflected) outside the function.

Creating Class/object
=====================

If a function invocation is preceded with the new keyword, it is a constructor invocation.

::

    // This is a function constructor:
    function myFunction(arg1, arg2) {
        this.firstName = arg1;
        this.lastName  = arg2;
    }

    // This creates a new object
    var x = new myFunction("John","Doe");
    x.firstName;                             // Will return "John"

JavaScript Closures
===================

::

    var add = (function () {
        var counter = 0;
        return function () {return counter += 1;}
    })();

    add();
    add();
    add();

    // the counter is now 3

The variable add is assigned the return value of a self invoking function.

The self-invoking function only runs once. It sets the counter to zero (0), and returns a function expression.

This way add becomes a function. The "wonderful" part is that it can access the counter in the parent scope.

This is called a JavaScript closure. It makes it possible for a function to have "private" variables.

The counter is protected by the scope of the anonymous function, and can only be changed using the add function.

**A closure is a function having access to the parent scope, even after the parent function has closed.**

JavaScript Display output
=========================

JavaScript Display Possibilities

JavaScript can "display" data in different ways:

* Writing into an alert box, using window.alert().
* Writing into the HTML output using document.write().
* Writing into an HTML element, using innerHTML.
* Writing into the browser console, using console.log().

