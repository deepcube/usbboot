# Change settings in config.mk or as arguments to make. E.g.
#
#     make CFLAGS='-Wall -Wextra -Werror'

PKG_VER=$(shell grep rpiboot debian/changelog | head -n1 | sed 's/.*(\(.*\)).*/\1/g')
GIT_VER=$(shell git rev-parse HEAD 2>/dev/null | cut -c1-8 || echo "")

include config.mk

CFLAGS_ALL = \
	$(CFLAGS_FTM) \
	$(CFLAGS_NEED_HAVE) \
	-DGIT_VER='"$(GIT_VER)"'\
	-DPKG_VER='"$(PKG_VER)"' \
	$(CFLAGS)

rpiboot: main.c msd/bootcode.h msd/start.h msd/bootcode4.h msd/start4.h
	$(CC) $(CFLAGS_ALL) -Wall -Wextra -g -o $@ $< `pkg-config --cflags --libs libusb-1.0`

%.h: %.bin ./bin2c
	./bin2c $< $@

%.h: %.elf ./bin2c
	./bin2c $< $@

bin2c: bin2c.c
	$(CC) -Wall -Wextra -g -o $@ $<

install: rpiboot
	install -m 755 rpiboot /usr/bin/
	install -d /usr/share/rpiboot
	install -m 644 msd/bootcode.bin  /usr/share/rpiboot/
	install -m 644 msd/bootcode4.bin /usr/share/rpiboot/
	install -m 644 msd/start.elf  /usr/share/rpiboot/
	install -m 644 msd/start4.elf /usr/share/rpiboot/

uninstall:
	rm -f /usr/bin/rpiboot
	rm -f /usr/share/rpiboot/bootcode.bin
	rm -f /usr/share/rpiboot/bootcode4.bin
	rm -f /usr/share/rpiboot/start.elf
	rm -f /usr/share/rpiboot/start4.elf
	rmdir --ignore-fail-on-non-empty /usr/share/rpiboot/

clean:
	rm -f rpiboot msd/*.h bin2c config.mk

.PHONY: uninstall clean
