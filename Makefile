PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

PLATFORMFILE := src/platform/$(shell uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]').sh

BUCKLES = $(sort $(wildcard src/buckle/*.sh))

BASHCOMP_PATH ?= $(DESTDIR)$(PREFIX)/share/bash-completion/completions
ZSHCOMP_PATH ?= $(DESTDIR)$(PREFIX)/share/zsh/site-functions
FISHCOMP_PATH ?= $(DESTDIR)$(PREFIX)/share/fish/vendor_completions.d

ifeq ($(FORCE_ALL),1)
FORCE_BASHCOMP := 1
FORCE_ZSHCOMP := 1
FORCE_FISHCOMP := 1
endif
ifneq ($(strip $(wildcard $(BASHCOMP_PATH))),)
FORCE_BASHCOMP := 1
endif
ifneq ($(strip $(wildcard $(ZSHCOMP_PATH))),)
FORCE_ZSHCOMP := 1
endif
ifneq ($(strip $(wildcard $(FISHCOMP_PATH))),)
FORCE_FISHCOMP := 1
endif

all:
	@echo "Strap is a shell script, so there is nothing to do. Try \"make install\" instead."

install-common:
	@install -v -d "$(DESTDIR)$(MANDIR)/man1" && install -m 0644 -v man/strap.1 "$(DESTDIR)$(MANDIR)/man1/strap.1"

	@[ "$(FORCE_BASHCOMP)" = "1" ] && install -v -d "$(BASHCOMP_PATH)" && install -m 0644 -v src/completion/strap.bash-completion "$(BASHCOMP_PATH)/strap" || true
	@[ "$(FORCE_ZSHCOMP)" = "1" ] && install -v -d "$(ZSHCOMP_PATH)" && install -m 0644 -v src/completion/strap.zsh-completion "$(ZSHCOMP_PATH)/_strap" || true
	@[ "$(FORCE_FISHCOMP)" = "1" ] && install -v -d "$(FISHCOMP_PATH)" && install -m 0644 -v src/completion/strap.fish-completion "$(FISHCOMP_PATH)/strap.fish" || true


ifneq ($(strip $(wildcard $(PLATFORMFILE))),)
install: install-common
	@install -v -d "$(DESTDIR)$(LIBDIR)/strap" && install -m 0644 -v "$(PLATFORMFILE)" "$(DESTDIR)$(LIBDIR)/strap/platform.sh"
	@install -v -d "$(DESTDIR)$(BINDIR)/"
	sed 's:.*PLATFORM_FUNCTION_FILE.*:source "$(DESTDIR)$(LIBDIR)/strap/platform.sh":' src/strap.sh > "$(DESTDIR)$(BINDIR)/strap"
	@chmod 0755 "$(DESTDIR)$(BINDIR)/strap"
else
install: install-common
	@install -v -d "$(DESTDIR)$(BINDIR)/"
	sed '/PLATFORM_FUNCTION_FILE/d' src/strap.sh > "$(DESTDIR)$(BINDIR)/strap"
	@chmod 0755 "$(DESTDIR)$(BINDIR)/strap"
endif

uninstall:
	@rm -vrf \
		"$(DESTDIR)$(BINDIR)/strap" \
		"$(DESTDIR)$(LIBDIR)/strap/" \
		"$(DESTDIR)$(MANDIR)/man1/strap.1" \
		"$(BASHCOMP_PATH)/strap" \
		"$(ZSHCOMP_PATH)/_strap" \
		"$(FISHCOMP_PATH)/strap.fish"
	@rmdir "$(DESTDIR)$(LIBDIR)/strap/" 2>/dev/null || true

TESTS = $(sort $(wildcard tests/t[0-9][0-9][0-9][0-9]-*.sh))

test: $(TESTS)

$(TESTS):
	@$@ $(STRAP_TEST_OPTS)

clean:
	$(RM) -rf tests/test-results/ tests/trash\ directory.*/

.PHONY: install uninstall install-common test clean $(TESTS)
