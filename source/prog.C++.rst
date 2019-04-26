Prog : C++
==========

.. contents::

.. highlight:: c

std:: library
-------------

Header files

* **iostream.h**
* **string.h**
* **list.h**

To use the standard library use the **std::** prefix

::
        std::string s = "abc";
        std::list

================
::string Strings
================

String addition

::

        string s1 = "abc";
        string s2 = "def";
        string s3 = s1 + "," + s3;
        cout << s3;

String comparison

::

        if (answer == input)

        if (answer == "yes")

String replace

::
        
        name.replace(0, 5, "Nicholas"); // replace starting from 0, 5 chars

Substring

::
        
        name.substr(6, 10);

Char* for the sring for use with C functions

::

        name.c_str();

===========
<< operator
===========

::

        std::cout << "Hello World\n"

The operator **<<** ‘‘put to’’) writes its second argument onto its first. In this case, the string literal "H el lo w or ld \n is written onto the standard output stream s td :c ou t.

Output of different types can be combined in the obvious way:

:: 

        void h(int i)
        {
                cout << "the value of i is";
                cout << i;
                cout << "\n";
                cout << "the value of i is" << i << "\n";
        }

===========
>> operator
===========

::

        int i;
        cin >> i; //read an integer into i

        double d;
        cin >> d; //read a double

================
Vectors (arrays)
================

Define a vector

::
        
        std::vector<int> myarray(1000);

        vector<int> books(1000);        // vector of 1000 elements
        vector<int> books[1000];        // 1000 empty vectors

Assigning a vector involves copying of its elements

::

        v = v2;

Resize vector

::

        v.resize(v.size() + n);

vector does not proivde range checking. Range checking is provided by **Vec** which throws an exception if range is violated.

===================
List (linked lists)
===================

Define a list

::

        std::list<int> myarray;

A list is a sequence and can be iterated as (end() returns the element beyond the last valid element)

::

        list<int>::const_iterator i;
        for (i = myarray.begin(); i != myarray.end(); ++i) {
                
        }

Inserting an element into the list

::

        book.push_front(e);
        book.push_back(e);
        book.insert(i,e):       //add before the element 'i' refers to

===
Map
===

Define a map

::
        
        map<sring,int> phone_book;

Fetch a value (if no value is found for the key s, then a default value is returned, for int it is 0)

::

        int i = phone_book[s];

=======================
Other container objects
=======================

* **queue<T>**
* **stack<T>**
* **deque<T>**
* **priority_queue<T>**
* **set<T>**
* **mulitset<T>** : A set in which a value can occur many times
* **multimap<T>** : A map in which a key can occur many times

====
sort
====

::

        sort(ve.begin(), ve.end());

=========
Iterators
=========

::

        list<int>::const_iterator i;
        for (i = myarray.begin(); i != myarray.end(); ++i) {

                int a = *i; //*i returns the element the iterator points to
        }

===============
Iterators - I/O
===============

To make an **ostream_iterator**, we need to specify which stream will be used and the type of **ostream_iterator** objects written to it. For example, we can define an iterator that refers to the standard output stream, cout:

::

        ostream_iterator<string> oo(cout);

        *oo = "Hello, ";
        ++oo;
        *oo = "world!\n";

Similarly, an istream_iterator is something that allows us to treat an input stream as a read-only container. Again, we must specify the stream to be used and the type of values expected:

::

        istream_iterator<string> ii(cin);

Because input iterators invariably appear in pairs representing a sequence, we must provide an istream_iterator to indicate the end of input. This is the default istream_iterator:

::

        istream_iterator<string> eos;

        string s1 = *ii;
        ++ii;
        string s2 = *ii;
        cout << s1 <<  ́  ́ << s2 <<  ́\ n ́;

Namespaces
----------

A namespace is a mechanism for expressing logical grouping. That is, if some declarations logically belong together according to some criteria, they can be put in a common namespace to express that fact.

::

        namespace parser {
                // declarations
        }

We cannot declare a new member of a namespace outside a namespace definition using the qualifier syntax. For example:

::

        void Parser::logical bool;

A name from another namespace can be used when qualified by the name of its namespace. For example:

::

        switch (Lexer::curr_tok)

**using-declaration** to state in one place that the **get_token** used in this scope is **Lexer::get_token**

::

        using Lexer::get_token
        get_token();
       
A using-declaration brings every declaration with a given name into scope. In particular, a single using-declaration can bring in every variant of an overloaded function.

To make all names from a namespace to be directly accesible from a different namespace

::

        using namespace Lexer;          //make all names from Lexer available
        
Unnamed namespaces can be created as 

::

        namespace $$$ {
                int a;
                void f() { /* */ }
        }
        using namespace $$$;

namespace aliases can be created as

::

        namespace ATT = American_Telephone_and_Telegraph;


A namespace is open; that is, you can add names to it from several namespace declarations. For example:

::

        namespace A{
                int f();        //now A has member f()
        }

        namespaceA{
                intg;           //now A has two members, f() and g()
        }

Exceptions
----------

Simple exception handler

::

        try {
                char c = to_char(i);
                //...
        }
        catch(Range_error) {
                cerr<<"oops\n";
        }

To pass arguments via throw and get them via catch

::

        catch (Range_Error x) {
                cerr << "oops : to_char("<< x.i <<")\n";
        }

static functions (DONT USE)
---------------------------

In C and older C++ programs, the keyword static is (confusingly) used to mean ‘‘use internal linkage’’. Don’t use static except inside functions and classes.

Use unnamed namespaces instead as

::

        namespace {
                class X { } ;
                void f();
                int i;
        }

Classes
-------

* **priavte** : can only be used by member functions
* **public** : can be used by anybody
* **proctected** : 

A **struct** is a class whose members are public by default.

===========
Constructor
===========

::

        class Date {

                Date(int, int, int);
                Date(int, int);
                Date(int, int);
                Date();
        }

Constructor with default arguments

::

        Date(int dd=0, int mm=0, int yy=0);

static/class-level members

::

        class Date {
                static Date default_date;
                ...

By default class objects can be copied. 

::

        Date d = today;

If that default is not the behaviour wanted for class X, a copy constructor can be provided as

::

        Date(const Date&);

==========
Destructor
==========

::

        ~Date() { /* */ }

=========================
constant member functions
=========================

A member function which does not modify the state of the object

::

        int month() const { return m; }

A not const function cannot be invoked for a const object

::

        void f(Date& d, Date& cd)
        {
                d.add_year();   //fine
                cd.add_year();  //error
        }

=======================
Inline member functions
=======================

A member function defined within the class definition is taken to be an inline member function. 

::

        int day() const { return d; }

============
cast/casting
============

----------
const_cast
----------
casts away a variable from being const to a changeable object

::
        
        DAte* th = const_cast<Date*> (this);
        th->cache_valid = true;

**mutable** : specifies that a member should be stored in a way that allows updating - even when it is a member of a const object. In other words, mutable means "can never be const". Any members defined as mutable can be changed even for a object declared to be const 

::

        mutable bool cache_valid;

-----------
Static Cast
-----------

**static_cast** doesn't do any run time checking of the types involved, which means that unless you know what you are doing, they could be very unsafe. It also only allows casting between related types, such as pointers or references between Base and Derived, or between fundamental types, such as long to int or int to float.

It does not allow casts between fundamentally different types, such as a cast between a BaseA and BaseB if they are not related. This will result in a compile time error.

::

        class B {};

        class D : B {};

        B* b = new D();
        D* d1 = static_cast<D*>b; // Valid! d1 is a valid and correct pointer to a D

        B* b = new B();
        D* d1 = static_cast<D*>b; // Invalid!

------------
dynamic_cast
------------

dynamic_cast will do run time checking as well, and if the instance cannot be cast into another derived type, it will return a null pointer.

::

        class B {};

        class D : B {};

        B* b = new D();
        D* d2 = dynamic_cast<D*>b; // Valid! d2 is a valid and correct pointer to a D

        B* b = new B();
        D* d1 = dynamic_cast<D*>b; // Valid, but d2 is now null

dynamic_cast<T&>(r of a reference r is not a question but an assertion: ‘‘The object referred to by r is of type T The result of a dynamic_cast for a reference is implicitly tested by the implementation of dynamic_cast itself. If the operand of a dynamic_cast to a reference isn’t of the expected type, a bad_cast exception is thrown.  The difference in results of a failed dynamic pointer cast and a failed dynamic reference cast reflects a fundamental difference between references and pointers. If a user wants to protect against bad casts to references, a suitable handler must be provided.

----------------
reinterpret_cast
----------------

This is the ultimate cast, which disregards all kind of type safety, allowing you to cast anything to anything else, basically reassigning the type information of the bit pattern.

::

        int i = 12345;
        MyClass* p = reinterpret_cast<MyClass*> i;

====================
Operator overloading
====================

::

        inline bool operator==(Date a, Date b)
        {
                return a.day() == b.day() && a.month() == b.month() && a.year() == b.year();
        }

* bool opeartor==(Date, Date);
* bool opeartor!=(Date, Date);
* bool opeartor<(Date, Date);
* bool opeartor>(Date, Date);

* bool opeartor++(Date&);
* bool opeartor--(Date&);

* bool opeartor+=(Date&);
* bool opeartor-=(Date)&;

* bool opeartor+(Date, int);
* bool opeartor-(Date, int);

* ostream& operator<<(ostream&, Date);
* istream& opeartor>>(istream&, Date);

* Date& operator=(const Date&); - copy assignment different from copy constructor which is called when the variable is being initialised directly during declaration as "Date d2 = d;". This would be called when "Date d2; d2 = d1;"

========================
Class Objects as Members
========================

Arguments for member's constructors are specified in a member initializer list in the definition of the constructor of the containing class

::

        Class Club {
                string name;
                Table members;
                Table officers;
                Date founded;

                ..
        }

        Club::Club(const string& n, Date fd)
                :name(n), members(10, officers(), founded(fd)
        {
                //
        }

The members constructors are called before the body of the containing class's own constructor is executed. The constructors are called in the order in which they are declared in the class rather than the order in which they appear in the initializer list. The member destructors are called in the reverse order of construction. If a member construcotr needs no arguments, the member need not be mentioned in the member initializer list.

Member initializers are essential for types for which initialization differs from assignment – that is, for member objects of classes without default constructors, for c on st members, and for reference const members

For most types, however, the programmer has a choice between using an initializer and using an assignment.

================
Member constants
================

::

        class Curious {
        public:
                static const int c1 = 7;
                static int c2 = 11;     //error: not const
                const int c3 = 13;      //error: not static
                static const int c4 = f(17);    //error: in-class initializer not allowed
                static const float c5 = 7.0;    //error: floats cannot be initilaized
                //...
        };

====================
Conversion Operators
====================

::

        class Tiny {
                int v;
        Tiny& operator=(int i) { assign(i ; return *this; }
        operator int() const { return v } // conversion to int function
        };

=======
Friends
=======

A friend can access private data of a class without being part of a class. Though, the friend function must be explicitly declared in the declaration of the class of which it is a friend. 

::

        friend Vector operator* (const Matrix&, const Vector&);

===============
Derived Classes
===============

::

        class Employee {

        }

        class Manager : public Employee {
                ..
        }

        Manager::Manager(const string& n, int d, int lvl)
                :Employee(n, d),
                 level(lvl)
        {

        }

Class objects are constructed from the bottom up: first the base, then the members, and then the derived class itself. They are destroyed in the opposite order: first the derived class itself, then the members, and then the base.

====================
Multiple Inheritance
====================

::
        
        class Satellite : public Task, public Displayed {

        }

Overload resolution is not applied across different class scopes (§7.4). In particular, ambiguities between functions from different base classes are not resolved based on argument types.

--------------------
Virtual Base classes
--------------------

Virtual base classes, used in virtual inheritance, is a way of preventing multiple "instances" of a given class appearing in an inheritance hierarchy when using multiple inheritance.

Consider the following scenario:

::

        class A { public: void Foo() {} }
        class B : public A {}
        class C : public A {}
        class D : public B, public C {}

So you have two "instances" (for want of a better expression) of A.

When you have this scenario, you have the possibility of ambiguity. What happens when you do this:

::

        D d;
        d.Foo(); // is this B's Foo() or C's Foo() ??

Virtual inheritance is there to solve this problem. When you specify virtual when inheriting your classes, you're telling the compiler that you only want a single instance.

::

        class A { public: void Foo() {} }
        class B : public virtual A {}
        class C : public virtual A {}
        class D : public B, public C {}

This means that there is only one "instance" of A included in the hierarchy. Hence

::

        D d;
        d.Foo(); // no longer ambiguous

=================
virtual functions
=================

In OOP when a derived class inherits from a base class, an object of the derived class may be referred to via a pointer or reference of either the base class type or the derived class type. If there are base class methods overridden by the derived class, the method actually called by such a reference or pointer can be bound either 'early' (by the compiler), according to the declared type of the pointer or reference, or 'late' (i.e. by the runtime system of the language), according to the actual type of the object referred to.

Virtual functions are resolved 'late'. If the function in question is 'virtual' in the base class, the most-derived class's implementation of the function is called according to the actual type of the object referred to, regardless of the declared type of the pointer or reference. If it is not 'virtual', the method is resolved 'early' and the function called is selected according to the declared type of the pointer or reference.

A virtual function must be defined for the class in which it is first declared (unless it is declared to be a pure virtual function).

A virtual function can be used even if no class is derived from its class, and a derived class that does not need its own version of a virtual function need not provide one. When deriving a class, simply provide an appropriate function, if it is needed.

================
Abstract classes
================

A class containing one or more pure virtual functions is an abstract class and cannot be instantiated. A derived class which does not define all the pure virtual functions of the the base class becomes an abstract class.

Also make sure to define destructor for an abstract class, so references/pointers to the abstract class that are freed call the corresponding derived class's destructor. Like this

::

        virtual ~Ival_box() { }

---------------------
Pure virtual function
---------------------

::

        virtual void draw() = 0;

------
typeid
------

typeid() returns a reference to a standard library type called type_info defined in <type-info.h>. Given a type-name as its operand, typeid() returns a reference to a type_info that represents the type-name. 

::

        class type_info;
        const type_info& typeid(type_name) throw (bad_typeid):
        const type)info& typeid(expression);

        cout << typeid(*p).name();

Templates
---------

Templates provide direct support for generic programming, that is, programming using types as parameters.

The C++ template mechanism allows a type to be a parameter in the definition of a class or a function

::

        template <class C> class String {
                ..
        public:
                String ();
                String (const C*);
                
                C read(int i) const;
        }

        template <class C> String<C>::read(int i)
        {
                ..
        }
                        
The template **<class C>** prefix specifies that a template is being declared and that a type argument C will be used in the declaration. After its introduction, C is used exactly like other type names. The scope of C extends to the end of the declaration prefixed by template <class C>. Not that template <class C>, need not be the name of class.

::

        String<char> ss; 
        String<unsigned char> us;

Parameters can be defined for templates as

::

        template <class T, int i> class Buffer {
                T v[i];

        }

        Buffer<char, 127> cbuf;
        Buffer<Record, 8> rbuf;

==================
Function Templates
==================

::

        template<class T> void sort(vector<T>& v);

        void f(vector<int>& vi, vector<string>& vs)
        {
                sort(vi);
                sort(vs);
        }


