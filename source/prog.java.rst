Java
++++

Java Object is mostly equivalent to C pointer

::

    Cat C = new Cat();

    equivalent to C++

    Cat *c = new Cat();


If you pass a java Object to a function, you are passing a pointer of that object

::

    void func(Cat a) {
    
    }

    equivalent to C++

    void func(Cat* a) {
        ..
    }

If you change the contents of a object in a function, it reflects in the caller

::

    void func(Cat c) {
        c.x = 10;
    }
    Cat a = new Cat();
    a.x = 5; // x = 5
    func(a)  // x = 10;

    equivalent to C++

    void func(Cat *c) {
        c->x = 10;
    }
    Cat *a = new Cat();
    a->x = 5; // x = 5
    func(a)   // x = 10;

::

    void func(Cat c) {
        c = new Cat();  // does not change a

    Cat a = new Cat();
    func(a);

    equivalent to C++

    void func(Cat *c) {
        c = new Cat();
    }
    Cat *a = new Cat();
    func(a);   // does not change a

