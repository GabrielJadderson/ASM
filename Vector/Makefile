
make: build

build:
	gcc src/string_reader.c src/vector.c -o stringreader;

.POHNY: clean
clean:
	rm stringreader;

.PHONY: test
test:
	./stringreader test/stringWithSpaces.txt
	./stringreader test/basicTest.txt
	./stringreader test/specialchar.txt

