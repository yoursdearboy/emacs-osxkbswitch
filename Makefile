CC=clang
CFLAGS=-I . -fPIC -shared -framework Foundation -framework Carbon
OBJECTS=osxkbswitch.m
OUT=osxkbswitch.so

all:
	$(CC) $(CFLAGS) $(OBJECTS) -o $(OUT)

test:
	emacs -Q -L . -batch -l osxkbswitch --eval "(message (keyboard-layout))"

clean:
	rm osxkbswitch.so
