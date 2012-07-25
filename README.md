Python parser for SourceAnalyzer
================================

### Features

* class definition
    
    :::python
    class Foo:
        pass

    => Foo

* function definition

    :::python
    class Test:
        def foo(a, b):
            def bar(c, d=g("arg")):
                pass

    => Test.foo(a, b)
    => Test.bar(c, d)
    

* function call

    :::python
    foo().bar().a.b()

    => foo()
    => bar()
    => b()

### Bugs and so on
* can't work with mixed spaces and tabs
* can't define lambda functions
* can't define decorator call