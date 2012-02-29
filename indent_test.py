def main():
	print "main"
	print "another"

def test(a=5, *args, **args2):
	print "test"

def test2(a, b, c, d, e, f, g):
	print "test2"

class Foo(a, b, c):
	def __init__(self, test=7):
		pass
	def bar():
		pass

if __name__ == '__main__':
	main()