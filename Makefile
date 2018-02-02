.PHONY: all clean cleandist linux-install mac-install release

all:
	make -C examples/ all

clean:
	make -C examples/ clean

cleandist:
	make -C examples/ cleandist

linux-install:
	sudo ./install/unix.sh

mac-install:
	sudo ./install/unix.sh

release:
	./makerelease ./release/
