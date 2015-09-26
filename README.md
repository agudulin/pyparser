Python parser for SourceAnalyzer
================================

### Features

* class definition

```python
class Foo:
    pass
```
    => Foo

* function definition

```python
class Test:
    def foo(a, b):
        def bar(c, d=g("arg")):
            pass
```
    => Test.foo(a, b)
    => Test.bar(c, d)


* function call

```python
foo().bar().a.b()
```
    => foo()
    => bar()
    => b()

### Known issues

* can't work with mixed spaces and tabs
* can't define lambda functions
* can't define decorator call


### Links

* SA3 integration: https://bitbucket.org/agudulin/sourceanalyzer3-call-graph-core-with-pyparser
* Habrahabr article: http://habrahabr.ru/post/141756/
