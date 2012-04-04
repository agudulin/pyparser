Python parser for SourceAnalyzer
================================

Features
--------
- class definition

::

    class Foo:
        pass

::

    => Foo

- function definition

::

    class Test:
        def foo(a, b):
            def bar(c, d):
                pass

::

    => Test.foo(a, b)
    => Test.bar(c, d)
    

- function call

::

    foo().bar().a.b()

::

    => foo()
    => foo().bar()
    => foo().bar().a.b()

Bugs and so on
--------------

- can't work with mixed spaces and tabs
- can't define lambda functions
- can't define function call in some function parameters

::

    def bar(x=foo())

- ...and ignores that 'some function' definition [BUG]
- can't define decorator call