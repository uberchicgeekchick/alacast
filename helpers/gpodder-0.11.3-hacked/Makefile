#
# gPodder - A media aggregator and podcast client
# Copyright (c) 2005-2008 Thomas Perl and the gPodder Team
#
# gPodder is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# gPodder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#

##########################################################################

BINFILE=bin/gpodder
GLADEFILE=data/gpodder.glade
GLADEGETTEXT=$(GLADEFILE).h
MESSAGESPOT=data/messages.pot
GUIFILE=src/gpodder/gui.py
LOGO_22=data/icons/22/gpodder.png
LOGO_24=data/icons/24/gpodder.png
HELP2MAN=help2man
MANPAGE=doc/man/gpodder.1
GPODDERVERSION=`cat $(BINFILE) |grep ^__version__.*=|cut -d\" -f2`

ROSETTA_FILES=$(MESSAGESPOT) data/po/*.po
ROSETTA_ARCHIVE=gpodder-rosetta-upload.tar.gz

CHANGELOG=ChangeLog
CHANGELOG_TMP=.ChangeLog.tmp
CHANGELOG_EDT=.ChangeLog.edit
CHANGELOG_BKP=.ChangeLog.backup
EMAIL ?= $$USER@`hostname -f`

DESTDIR ?= /
PREFIX ?= /usr

# default editor of user has not set "EDITOR" env variable
EDITOR ?= vim

##########################################################################

all: help

help:
	@echo 'make test            run gpodder in local directory'
	@echo 'make mtest           run gpodder (for maemo scratchbox)'
	@echo 'make cl              make new changelog entry (1)'
	@echo 'make ci              format a commit message from the changelog'
	@echo 'make release         create source tarball in "dist/"'
	@echo 'make releasetest     run some tests before the release'
	@echo 'make install         install gpodder into "$(PREFIX)"'
	@echo 'make uninstall       uninstall gpodder from "$(PREFIX)"'
	@echo 'make generators      generate manpage and icons (if needed)'
	@echo 'make messages        rebuild messages.pot from new source'
	@echo 'make rosetta-upload  generate a tarball of all translation files'
	@echo 'make clean           remove generated+temp+*.py{c,o} files'
	@echo 'make distclean       do a "make clean" + remove "dist/"'
	@echo ''
	@echo '(1) Please set environment variable "EMAIL" to your e-mail address'

##########################################################################

cl:
	cp $(CHANGELOG) $(CHANGELOG_BKP)
	(echo "`date -R` <$(EMAIL)>" ; svn status | sed -f doc/dev/svncl.sed | sort ; echo ""; cat $(CHANGELOG)) >$(CHANGELOG_EDT)
	cp $(CHANGELOG_EDT) $(CHANGELOG)
	$(EDITOR) $(CHANGELOG)
	diff -q $(CHANGELOG) $(CHANGELOG_EDT) && mv $(CHANGELOG_BKP) $(CHANGELOG) || true
	rm -f $(CHANGELOG_BKP) $(CHANGELOG_EDT)


ci:
	(svn diff ChangeLog | egrep '^[+]([^+].+|)$$' | sed -e 's/^[+]//')>commit_message
	@echo 'to commit, enter "svn ci -F commit_message'

##########################################################################

test:
	@# set xterm title to know what this window does ;)
	@echo -ne '\033]0;gPodder console (make test)\007'
	$(BINFILE) --local --verbose

mtest:
	@# in maemo scratchbox, we need this for osso/hildon
	run-standalone.sh $(BINFILE) --local --maemo --verbose

deb:
	debuild

release: distclean
	python setup.py sdist

releasetest:
	if grep -q '^__version__.*=.*+svn' $(BINFILE); then echo "Version is still '+svn'."; exit 1; fi
	desktop-file-validate data/gpodder.desktop

install: generators
	python setup.py install --root=$(DESTDIR) --prefix=$(PREFIX)

update-icons:
	gtk-update-icon-cache -f -i $(PREFIX)/share/icons/hicolor/

uninstall:
	@echo "##########################################################################"
	@echo "#  MAKE UNINSTALL STILL NOT READY FOR PRIME TIME, WILL DO MY BEST TO     #"
	@echo "#  REMOVE FILES INSTALLED BY GPODDER. WATCH INSTALL PROCESS AND REMOVE   #"
	@echo "#  THE REST OF THE PACKAGES MANUALLY TO COMPLETELY REMOVE GPODDER.       #"
	@echo "##########################################################################"
	rm -rf $(PREFIX)/share/gpodder $(PREFIX)/share/pixmaps/gpodder* $(PREFIX)/share/applications/gpodder.desktop $(PREFIX)/share/man/man1/gpodder.1 $(PREFIX)/bin/gpodder $(PREFIX)/lib*/python?.?/site-packages/gpodder* $(PREFIX)/share/locale/*/LC_MESSAGES/gpodder.mo $(PREFIX)/lib*/python?.?/site-packages/gpodder* >2 /dev/null


##########################################################################

generators: $(MANPAGE) $(LOGO_24)
	make -C data/po update

messages: gen_gettext

$(MANPAGE): $(BINFILE)
	$(HELP2MAN) --name="A Media aggregator and Podcast catcher" -N $(BINFILE) >$(MANPAGE)

data/maemo/gpodder.desktop: data/gpodder.desktop
	sed -e 's/^Exec=gpodder$$/Exec=gpodder --maemo/g' <data/gpodder.desktop >data/maemo/gpodder.desktop

gen_gettext: $(MESSAGESPOT)
	make -C data/po generators
	make -C data/po update

$(LOGO_24): $(LOGO_22)
	convert -bordercolor Transparent -border 1x1 $(LOGO_22) $(LOGO_24)

$(GLADEGETTEXT): $(GLADEFILE)
	intltool-extract --type=gettext/glade $(GLADEFILE)

$(MESSAGESPOT): src/gpodder/*.py $(GLADEGETTEXT) $(BINFILE)
	xgettext -k_ -kN_ -o $(MESSAGESPOT) src/gpodder/*.py $(GLADEGETTEXT) $(BINFILE)
	sed -i'~' -e 's/SOME DESCRIPTIVE TITLE/gPodder translation template/g' -e 's/YEAR THE PACKAGE'"'"'S COPYRIGHT HOLDER/2006 Thomas Perl/g' -e 's/FIRST AUTHOR <EMAIL@ADDRESS>, YEAR/Thomas Perl <thp@perli.net>, 2006/g' -e 's/PACKAGE VERSION/gPodder '$(GPODDERVERSION)'/g' -e 's/PACKAGE/gPodder/g' $(MESSAGESPOT)

rosetta-upload: $(ROSETTA_ARCHIVE)
	@echo 'You can now upload the archive to launchpad.net:  ' $(ROSETTA_ARCHIVE)

$(ROSETTA_ARCHIVE):
	tar czvf $(ROSETTA_ARCHIVE) $(ROSETTA_FILES)

##########################################################################

clean:
	python setup.py clean
	rm -f src/gpodder/*.pyc src/gpodder/*.pyo src/gpodder/*.bak MANIFEST PKG-INFO data/gpodder.gladep{,.bak} data/gpodder.glade.bak $(GLADEGETTEXT) data/messages.pot~ data/gpodder-??x??.png $(ROSETTA_ARCHIVE)
	rm -rf build
	make -C data/po clean

debclean:
	fakeroot debian/rules clean

distclean: clean
	rm -rf dist
 
##########################################################################

.PHONY: all cl ci test release releasetest install update-icons generators gen_manpage gen_graphics clean distclean messages help

##########################################################################


