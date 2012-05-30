# Makefile for suse-xsl-stylesheets
#
# Copyright (C) 2011,2012 Frank Sundermeyer <fsundermeyer@opensuse.org>
#
# Author:
# Frank Sundermeyer <fsundermeyer@opensuse.org>
#

PACKAGE    := suse-xsl-stylesheets
DTDNAME    := novdoc
DTDVERSION := 1.0
DBSTYLES   := /usr/share/xml/docbook/stylesheet/nwalsh/current
SUSESTYLES := /usr/share/xml/docbook/stylesheet/suse

SUSEXSL_FOR-CATALOG    := for-catalog-$(PACKAGE).xml
NOVDOC_FOR-CATALOG     := for-catalog-$(DTDNAME)-$(DTDVERSION).xml
NOVDOC_SCHEMA          := /usr/share/xml/novdoc/schema/dtd/$(DTDVERSION)

DIRECTORIES := catalogs

# html stylesheets are autogenerated from the xhtml stylesheets
# so we only need to maintain them in one place
#
XHTML2HTML    := xslt/common/xhtml2html.xsl
HTMLSTYLESHEETS=$(subst /xhtml/,/html/,$(wildcard xslt/xhtml/*.xsl))



#-------
# Directories for installation
PREFIX    ?= /usr/share
STYLEDIR := $(DESTDIR)$(PREFIX)/xml/docbook/stylesheet/suse
DOCDIR   := $(DESTDIR)$(PREFIX)/doc/packages/suse-xsl-stylesheets

all: schema/novdocx-core.rnc schema/novdocx-core.rng schema/novdocx.rng
all: schema/novdocxi.rng
all: catalogs/$(NOVDOC_FOR-CATALOG) catalogs/$(SUSEXSL_FOR-CATALOG)
all: catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION)
all: xhtml2html
	@echo "Ready to install..."

install: create-install-dirs
	install -m644 schema/*.{rnc,rng} \
	  $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/rng/$(DTDVERSION)
	install -m644 schema/{*.dtd,*.ent,catalog.xml,CATALOG} \
	  $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/dtd/$(DTDVERSION)
	install -m644 catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION) \
	  $(DESTDIR)/var/lib/sgml && \
	  ln -s /var/lib/sgml/CATALOG.$(DTDNAME)-$(DTDVERSION) \
	    $(DESTDIR)$(PREFIX)/sgml/
	install -m644 catalogs/*.xml $(DESTDIR)/etc/xml
	install -m644 COPYING* $(DOCDIR)
	tar c --mode=u+w,go+r-w,a-s -C xslt . | (cd  $(STYLEDIR); tar xpv)

create-install-dirs:
	mkdir -p $(STYLEDIR)
	mkdir -p $(DOCDIR)
	mkdir -p $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/{dtd,rng}/$(DTDVERSION)
	mkdir -p $(DESTDIR)/var/lib/sgml
	mkdir -p $(DESTDIR)$(PREFIX)/sgml
	mkdir -p $(DESTDIR)/etc/xml


.PHONY: clean
clean:
	rm -rf catalogs/ schema/novdocx-core.rnc schema/novdocx-core.rng \
		schema/novdocx.rng schema/novdocxi.rng xslt/html/

# auto-generate the html stylesheets
#
.PHONY: xhtml2html
xhtml2html: $(HTMLSTYLESHEETS)


#-----------------------------
# Auto-generate HTML stylesheets from XHTML:
xslt/html/%.xsl: xslt/xhtml/%.xsl
	xsltproc --output $@  ${XHTML2HTML} $<

#-----------------------------
# Generate SGML catalog for novdoc
#
catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION): $(DIRECTORIES)
catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION):
	echo \
	  "CATALOG \"$(NOVDOC_SCHEMA)/CATALOG\"" \
	  > $@

#-----------------------------
# Generate RELAX NG schemes for novdoc
#

schema/novdocx-core.rnc: schema/novdocx.dtd.tmp
	trang -I dtd -i no-generate-start $< $@

schema/novdocx-core.rng: schema/novdocx.dtd.tmp
	trang -I dtd -i no-generate-start $< $@

schema/novdocx.rng: schema/nocdocx.rnc
	trang -I rnc $< $@

schema/novdocxi.rng: schema/nocdocxi.rnc
	trang -I rnc $< $@


# To avoid unknown host errors with trang, we have to switch off the external
# entities from DocBook by creating a temporary file novdocx.dtd.tmp.
# As the entities are not used in RELAX NG anyway, this is uncritical.
#
.INTERMEDIATE: schema/novdocx.dtd.tmp
schema/novdocx.dtd.tmp: $(DIRECTORIES)
	sed 's:\(%[ \t]*ISO[^\.]*\.module[ \t]*\)"INCLUDE":\1"IGNORE":g' \
	  < schema/novdocx.dtd > $@

#-----------------------------
# Generate NOVDOC catalog
#

# since xmlcatalog cannot create groups (<group>) we need to use sed
# to fix this; while we are at it, we also remove the DOCTYPE line since 
# it may cause problems with some XML parsers (hen/egg probem)
#
catalogs/$(NOVDOC_FOR-CATALOG): | $(DIRECTORIES)
catalogs/$(NOVDOC_FOR-CATALOG):
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add "delegatePublic" "-//Novell//DTD NovDoc XML" \
	  "file://$(NOVDOC_SCHEMA)/catalog.xml" $@
	xmlcatalog --noout --add "delegateSystem" "novdocx.dtd" \
	  "file://$(NOVDOC_SCHEMA)/catalog.xml" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(DTDNAME)-$(DTDVERSION)">' $@
	sed -i '/<\/catalog/i\ </group>' $@

catalogs/$(SUSEXSL_FOR-CATALOG): | $(DIRECTORIES)
catalogs/$(SUSEXSL_FOR-CATALOG):
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add "rewriteSystem" \
	  "http://daps.sourceforge.net/release/suse-xsl/current" \
	  "file://$(SUSESTYLES)" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	sed -i '/<\/catalog/i\ </group>' $@

# create needed directories
#
$(DIRECTORIES):
	mkdir -p $@
