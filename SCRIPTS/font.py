import sys, codecs

def base64(n):
	if n < 26: return chr(ord('a') + n)
	if n < 52: return chr(ord('A') + n - 26)
	if n < 62: return chr(ord('0') + n - 52)
	if n == 62: return '+'
	if n == 63: return '*'
	raise OverflowError()

with open(sys.argv[1]) as f:
	lines = [line.strip() for line in f]
	assert lines[0] == 'P1'

	w, h = list(map(int, lines[2].split()))

	bits = ''.join(lines[3:])
	assert len(bits) == w*h
	rows = []
	for i in range(0, len(bits), w):
		rows.append(bits[i: i+w])

	rows2 = []
	for i in range(6):
		rows2.append('0'.join(rows[j] for j in range(i, len(rows), 6))+'0')

	stack = []
	codes = []
	for i in range(len(rows2[0])):
		col = ''.join(rows2[-j-1][i] for j in range(6))
		#print(col.replace('0', ' '))
		col = int(col, 2)

		if col == 0: # next char
			if len(stack) > 0:
				codes.append(''.join(list(map(base64, stack))))
			stack = []
		else:
			stack.append(col)
	#print(sys.argv[2])
	#print(len(codes), len(sys.argv[2]))
	assert len(codes) == len(sys.argv[2])
	
	
	chars = ['' for i in range(256)]

	for key, code in zip(sys.argv[2], codes):
		assert 0<= ord(key) <256
		chars[ord(key)] = code

##	print(chars)
	
	"""
	with open(sys.argv[4], 'wb') as output:
		output.write(f"{sys.argv[3]}: Font = (\n".encode('windows-1250'))
		for i in range(256):
			if i < 32 or chr(i) in {'{', '}', "\n"}:
				desc = f"#{i}"
			else:
				desc = chr(i)
			t = b"  '" + chars[i].encode('windows-1250') + b"', { " + bytes((i,)) + b" }\n"
			output.write(t)
		output.write(");\n".encode('windows-1250'))
	"""

	print(f"{sys.argv[3]}: Font = (")
	line = ""
	for i in range(256):
		if line == "":
			line = f"  '{chars[i]}'"
		else:
			new_line = f"{line}, '{chars[i]}'"
			if len(new_line) <= 75:
				line = new_line
			else:
				print(line+',')
				line = f"  '{chars[i]}'"
	print(line)
	print(");")