def main():
	print "main"
	print "another"

def test(a=5, *args, **args2):
	print "test"

def test2(a, b, c, d, e, f, g):
	print "test2"

class Lady:
	def bad_romance():
		pass

class Gaga(Lady):
	name = "Lady"
	def __init__(self):
		pass

class Foo(Lady, Gaga):
	class Bar:
		def __init__(self):
			print "GAGA"
		def bar_func():
			pass
			foo()
	def __init__(self, test=7):
		pass
	def foo():
		pass

if __name__ == '__main__':
	main()