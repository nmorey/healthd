DESTDIR=
PREFIX=/usr
BINDIR=$(PREFIX)/bin/
LIBEXEC=$(PREFIX)/lib/
SYSCONF_TPL_DIR=$(PREFIX)/share/fillup-templates/
SHAREDIR=$(PREFIX)/share/
UNITDIR=$(PREFIX)/lib/systemd
SHAREDSTATEDIR=/var/lib

BINS := $(shell find bin/ -type f | grep -v "*~")
INST_BINS := $(patsubst bin/%, $(DESTDIR)$(BINDIR)/%, $(BINS))

LIBS := $(shell find libexec/ -type f | grep -v "*~")
INST_LIBS := $(patsubst libexec/%, $(DESTDIR)$(LIBEXEC)/healthd/%, $(LIBS))

HTMLS:= $(shell find html/ -type f | grep -v "*~")
INST_HTMLS := $(patsubst html/%, $(DESTDIR)$(SHAREDIR)/healthd/html/%, $(HTMLS))

SERVICES := $(shell ls *.{service,timer})
INST_SERVICES := $(patsubst %, $(DESTDIR)$(UNITDIR)/system/%, $(SERVICES))

SYSCONF_TPL := $(DESTDIR)$(SYSCONF_TPL_DIR)/sysconfig.healthd

BUILT := $(patsubst %, build/%, $(BINS) $(LIBS) $(HTMLS) $(SERVICES) sysconfig)

all: $(BUILT)

install: $(INST_BINS) $(INST_LIBS) $(INST_HTMLS) $(INST_SERVICES) $(SYSCONF_TPL)
	mkdir -p $(DESTDIR)$(SHAREDSTATEDIR)/healthd/rrd
	mkdir -p $(DESTDIR)$(SHAREDSTATEDIR)/healthd/html

$(INST_BINS): $(DESTDIR)$(BINDIR)/%: build/bin/%
	install -D -m0755 $< $@

$(INST_LIBS): $(DESTDIR)$(LIBEXEC)/healthd/%: build/libexec/%
	install -D -m0755 $< $@

$(INST_HTMLS): $(DESTDIR)$(SHAREDIR)/healthd/html/%: build/html/%
	install -D -m0644 $< $@

$(INST_SERVICES): $(DESTDIR)$(UNITDIR)/system/%: build/%
	install -D -m0644 $< $@

$(SYSCONF_TPL): build/sysconfig
	install -D -m0644 $< $@

build/%: %
	@mkdir -p $$(dirname $@)
	sed -e 's^@PREFIX@^$(PREFIX)^g' -e 's^@BINDIR@^$(BINDIR)^g' -e 's^@LIBEXEC@^$(LIBEXEC)^g' -e 's^@SHAREDIR@^$(SHAREDIR)^g' -e 's^@UNITDIR@^$(UNITDIR)^g' -e 's^@SHAREDSTATEDIR@^$(SHAREDSTATEDIR)^g' $< > $@

clean:
	rm -Rf build
