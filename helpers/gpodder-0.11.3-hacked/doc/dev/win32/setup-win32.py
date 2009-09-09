#!/usr/bin/env python

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

import glob
import os
from distutils.core import setup
import py2exe


# read the version from the gpodder main program
gpodder_version = os.popen( "cat bin/gpodder |grep ^__version__.*=|cut -d\\\" -f2").read().strip()

# translations
languages = [ "de", "fr", "sv", "it", "pt", "es", "nl", "ru", "uk", "gl" ]
translation_files = []

# add translated files to translations dictionary
#for l in languages:
#    translation_files.append( ("share/locale/%s/LC_MESSAGES" % l, [ "data/locale/%s/LC_MESSAGES/gpodder.mo" % l ]) )

# files to install
inst_manpages = glob.glob( 'doc/man/*.1')
inst_share    = [ 'data/gpodder.glade' ]
inst_desktop  = [ 'data/gpodder.desktop' ]

inst_icons    = [ 'data/gpodder.png' ]
inst_icons_24 = [ 'data/icons/24/gpodder.png' ]
inst_icons_22 = [ 'data/icons/22/gpodder.png' ]
inst_icons_16 = [ 'data/icons/16/gpodder.png' ]
inst_icons_svg = [ 'data/gpodder.svg' ]

data_files = [
  ('share/man/man1',       inst_manpages),
  ('share/gpodder',        inst_share),
  ('share/applications',   inst_desktop),
  ('share/pixmaps',        inst_icons),

  ('share/icons/hicolor/scalable/apps', inst_icons_svg),
  ('share/icons/hicolor/48x48/apps', inst_icons),
  ('share/icons/hicolor/24x24/apps', inst_icons_24),
  ('share/icons/hicolor/22x22/apps', inst_icons_22),
  ('share/icons/hicolor/16x16/apps', inst_icons_16),
]

setup(
  windows = [
      { 'script': 'bin/gpodder.pyw' }
  ],
  options = {
      'py2exe': {
          'packages': 'encodings, dbhash',
          'includes': 'cairo, pango, pangocairo, atk, gobject',
      },
  },
  
  name         = 'gpodder',
  version      = gpodder_version,
  package_dir  = { '':'src' },
  packages     = [ 'gpodder' ],
  description  = 'media aggregator',
  author       = 'Thomas Perl',
  author_email = 'thp@perli.net',
  url          = 'http://gpodder.berlios.de/',
  scripts      = [ 'bin/gpodder' ],
  data_files   = data_files + translation_files
)

