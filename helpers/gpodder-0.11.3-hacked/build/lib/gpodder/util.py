# -*- coding: utf-8 -*-
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
#  util.py -- Misc utility functions
#  Thomas Perl <thp@perli.net> 2007-08-04
#

"""Miscellaneous helper functions for gPodder

This module provides helper and utility functions for gPodder that 
are not tied to any specific part of gPodder.

"""

import gpodder
from gpodder.liblogger import log

import gtk
import gobject

import os
import os.path
import glob
import stat

import re
import subprocess
from htmlentitydefs import entitydefs
import time
import locale
import gzip
import datetime
import threading

import urlparse
import urllib
import urllib2
import httplib
import webbrowser

import feedparser

import StringIO
import xml.dom.minidom


if gpodder.interface == gpodder.GUI:
    ICON_UNPLAYED = gtk.STOCK_YES
    ICON_LOCKED = 'emblem-nowrite'
elif gpodder.interface == gpodder.MAEMO:
    ICON_UNPLAYED = 'qgn_list_gene_favor'
    ICON_LOCKED = 'qgn_indi_KeypadLk_lock'

def make_directory( path):
    """
    Tries to create a directory if it does not exist already.
    Returns True if the directory exists after the function 
    call, False otherwise.
    """
    if os.path.isdir( path):
        return True

    try:
        os.makedirs( path)
    except:
        log( 'Could not create directory: %s', path)
        return False

    return True


def normalize_feed_url( url):
    """
    Converts any URL to http:// or ftp:// so that it can be 
    used with "wget". If the URL cannot be converted (invalid
    or unknown scheme), "None" is returned.

    This will also normalize feed:// and itpc:// to http://
    Also supported are phobos.apple.com links (iTunes podcast)
    and itms:// links (iTunes podcast direct link).
    """

    if not url or len( url) < 8:
        return None

    if url.startswith('itms://'):
        url = parse_itunes_xml(url)

    # Links to "phobos.apple.com"
    url = itunes_discover_rss(url)
    if url is None:
        return None
    
    if url.startswith( 'http://') or url.startswith( 'https://') or url.startswith( 'ftp://'):
        return url

    if url.startswith('feed://') or url.startswith('itpc://'):
        return 'http://' + url[7:]

    return None


def username_password_from_url( url):
    """
    Returns a tuple (username,password) containing authentication
    data from the specified URL or (None,None) if no authentication
    data can be found in the URL.
    """
    (username, password) = (None, None)

    (scheme, netloc, path, params, query, fragment) = urlparse.urlparse( url)

    if '@' in netloc:
        (authentication, netloc) = netloc.rsplit('@', 1)
        if ':' in authentication:
            (username, password) = authentication.split(':', 1)
            username = urllib.unquote(username)
            password = urllib.unquote(password)
        else:
            username = urllib.unquote(authentication)

    return (username, password)


def directory_is_writable( path):
    """
    Returns True if the specified directory exists and is writable
    by the current user.
    """
    return os.path.isdir( path) and os.access( path, os.W_OK)


def calculate_size( path):
    """
    Tries to calculate the size of a directory, including any 
    subdirectories found. The returned value might not be 
    correct if the user doesn't have appropriate permissions 
    to list all subdirectories of the given path.
    """
    if path is None:
        return 0L

    if os.path.dirname( path) == '/':
        return 0L

    if os.path.isfile( path):
        return os.path.getsize( path)

    if os.path.isdir( path) and not os.path.islink( path):
        sum = os.path.getsize( path)

        try:
            for item in os.listdir(path):
                try:
                    sum += calculate_size(os.path.join(path, item))
                except:
                    log('Cannot get size for %s', path)
        except:
            log('Cannot access: %s', path)

        return sum

    return 0L


def file_modification_datetime(filename):
    """
    Returns the modification date of the specified file
    as a datetime.datetime object or None if the modification
    date cannot be determined.
    """
    if filename is None:
        return None

    if not os.access(filename, os.R_OK):
        return None

    try:
        s = os.stat(filename)
        timestamp = s[stat.ST_MTIME]
        return datetime.datetime.fromtimestamp(timestamp)
    except:
        log('Cannot get modification timestamp for %s', filename)
        return None


def file_age_in_days(filename):
    """
    Returns the age of the specified filename in days or
    zero if the modification date cannot be determined.
    """
    dt = file_modification_datetime(filename)
    if dt is None:
        return 0
    else:
        return (datetime.datetime.now()-dt).days


def file_age_to_string(days):
    """
    Converts a "number of days" value to a string that
    can be used in the UI to display the file age.

    >>> file_age_to_string(0)
    ''
    >>> file_age_to_string(1)
    'one day ago'
    >>> file_age_to_String(2)
    '2 days ago'
    """
    if days == 1:
        return _('one day ago')
    elif days > 1:
        return _('%d days ago') % days
    else:
        return ''


def get_free_disk_space(path):
    """
    Calculates the free disk space available to the current user
    on the file system that contains the given path.

    If the path (or its parent folder) does not yet exist, this
    function returns zero.
    """

    path = os.path.dirname(path)
    if not os.path.exists(path):
        return 0

    s = os.statvfs(path)

    return s.f_bavail * s.f_bsize


def format_date(timestamp):
    """
    Converts a UNIX timestamp to a date representation. This
    function returns "Today", "Yesterday", a weekday name or
    the date in %x format, which (according to the Python docs)
    is the "Locale's appropriate date representation".

    Returns None if there has been an error converting the
    timestamp to a string representation.
    """
    seconds_in_a_day = 60*60*24
    try:
        diff = int((time.time()+1)/seconds_in_a_day) - int(timestamp/seconds_in_a_day)
    except:
        log('Warning: Cannot convert "%s" to date.', timestamp, traceback=True)
        return None
    
    if diff == 0:
       return _('Today')
    elif diff == 1:
       return _('Yesterday')
    elif diff < 7:
        # Weekday name
        return str(datetime.datetime.fromtimestamp(timestamp).strftime('%A'))
    else:
        # Locale's appropriate date representation
        return str(datetime.datetime.fromtimestamp(timestamp).strftime('%x'))


def format_filesize(bytesize, use_si_units=False, digits=2):
    """
    Formats the given size in bytes to be human-readable, 

    Returns a localized "(unknown)" string when the bytesize
    has a negative value.
    """
    si_units = (
            ( 'kB', 10**3 ),
            ( 'MB', 10**6 ),
            ( 'GB', 10**9 ),
    )

    binary_units = (
            ( 'KiB', 2**10 ),
            ( 'MiB', 2**20 ),
            ( 'GiB', 2**30 ),
    )

    try:
        bytesize = float( bytesize)
    except:
        return _('(unknown)')

    if bytesize < 0:
        return _('(unknown)')

    if use_si_units:
        units = si_units
    else:
        units = binary_units

    ( used_unit, used_value ) = ( 'B', bytesize )

    for ( unit, value ) in units:
        if bytesize >= value:
            used_value = bytesize / float(value)
            used_unit = unit

    return ('%.'+str(digits)+'f %s') % (used_value, used_unit)


def delete_file( path):
    """
    Tries to delete the given filename and silently 
    ignores deletion errors (if the file doesn't exist).
    Also deletes extracted cover files if they exist.
    """
    log( 'Trying to delete: %s', path)
    try:
        os.unlink( path)
        # Remove any extracted cover art that might exist
        for cover_file in glob.glob( '%s.cover.*' % ( path, )):
            os.unlink( cover_file)

    except:
        pass



def remove_html_tags(html):
    """
    Remove HTML tags from a string and replace numeric and
    named entities with the corresponding character, so the 
    HTML text can be displayed in a simple text view.
    """
    # If we would want more speed, we could make these global
    re_strip_tags = re.compile('<[^>]*>')
    re_unicode_entities = re.compile('&#(\d{2,4});')
    re_html_entities = re.compile('&(.{2,8});')

    # Remove all HTML/XML tags from the string
    result = re_strip_tags.sub('', html)

    # Convert numeric XML entities to their unicode character
    result = re_unicode_entities.sub(lambda x: unichr(int(x.group(1))), result)

    # Convert named HTML entities to their unicode character
    result = re_html_entities.sub(lambda x: unicode(entitydefs.get(x.group(1),''), 'iso-8859-1'), result)

    return result.strip()


def torrent_filename( filename):
    """
    Checks if a file is a ".torrent" file by examining its 
    contents and searching for the file name of the file 
    to be downloaded.

    Returns the name of the file the ".torrent" will download 
    or None if no filename is found (the file is no ".torrent")
    """
    if not os.path.exists( filename):
        return None

    header = open( filename).readline()
    try:
        header.index( '6:pieces')
        name_length_pos = header.index('4:name') + 6

        colon_pos = header.find( ':', name_length_pos)
        name_length = int(header[name_length_pos:colon_pos]) + 1
        name = header[(colon_pos + 1):(colon_pos + name_length)]
        return name
    except:
        return None


def file_extension_from_url( url):
    """
    Extracts the (lowercase) file name extension (with dot)
    from a URL, e.g. http://server.com/file.MP3?download=yes
    will result in the string ".mp3" being returned.

    This function will also try to best-guess the "real" 
    extension for a media file (audio, video, torrent) by 
    trying to match an extension to these types and recurse
    into the query string to find better matches, if the 
    original extension does not resolve to a known type.

    http://my.net/redirect.php?my.net/file.ogg => ".ogg"
    http://server/get.jsp?file=/episode0815.MOV => ".mov"
    """
    (scheme, netloc, path, para, query, fragid) = urlparse.urlparse(url)
    filename = os.path.basename( urllib.unquote(path))
    (filename, extension) = os.path.splitext(filename)

    if file_type_by_extension(extension) is not None:
        # We have found a valid extension (audio, video, torrent)
        return extension.lower()
    
    # If the query string looks like a possible URL, try that first
    if len(query.strip()) > 0 and query.find('/') != -1:
        query_url = '://'.join((scheme, urllib.unquote(query)))
        query_extension = file_extension_from_url(query_url)

        if file_type_by_extension(query_extension) is not None:
            return query_extension

    # No exact match found, simply return the original extension
    return extension.lower()


def file_type_by_extension( extension):
    """
    Tries to guess the file type by looking up the filename 
    extension from a table of known file types. Will return 
    the type as string ("audio", "video" or "torrent") or 
    None if the file type cannot be determined.
    """
    types = {
            'audio': [ 'mp3', 'ogg', 'wav', 'wma', 'aac', 'm4a' ],
            'video': [ 'mp4', 'avi', 'mpg', 'mpeg', 'm4v', 'mov', 'divx', 'flv', 'wmv', '3gp' ],
            'torrent': [ 'torrent' ],
    }

    if extension == '':
        return None

    if extension[0] == '.':
        extension = extension[1:]

    extension = extension.lower()

    for type in types:
        if extension in types[type]:
            return type
    
    return None


def get_tree_icon(icon_name, add_bullet=False, add_padlock=False, icon_cache=None, icon_size=32):
    """
    Loads an icon from the current icon theme at the specified
    size, suitable for display in a gtk.TreeView.

    Optionally adds a green bullet (the GTK Stock "Yes" icon)
    to the Pixbuf returned. Also, a padlock icon can be added.

    If an icon_cache parameter is supplied, it has to be a
    dictionary and will be used to store generated icons. 

    On subsequent calls, icons will be loaded from cache if 
    the cache is supplied again and the icon is found in 
    the cache.
    """
    global ICON_UNPLAYED, ICON_LOCKED

    if icon_cache is not None and (icon_name,add_bullet,add_padlock,icon_size) in icon_cache:
        return icon_cache[(icon_name,add_bullet,add_padlock,icon_size)]
    
    icon_theme = gtk.icon_theme_get_default()

    try:
        icon = icon_theme.load_icon(icon_name, icon_size, 0)
    except:
        log( '(get_tree_icon) Warning: Cannot load icon with name "%s", will use  default icon.', icon_name)
        icon = icon_theme.load_icon(gtk.STOCK_DIALOG_QUESTION, icon_size, 0)

    if icon and (add_bullet or add_padlock):
        # We'll modify the icon, so use .copy()
        if add_bullet:
            try:
                icon = icon.copy()
                emblem = icon_theme.load_icon(ICON_UNPLAYED, int(float(icon_size)*1.2/3.0), 0)
                (width, height) = (emblem.get_width(), emblem.get_height())
                xpos = icon.get_width() - width
                ypos = icon.get_height() - height
                emblem.composite(icon, xpos, ypos, width, height, xpos, ypos, 1, 1, gtk.gdk.INTERP_BILINEAR, 255)
            except:
                log('(get_tree_icon) Error adding emblem to icon "%s".', icon_name)
        if add_padlock:
            try:
                icon = icon.copy()
                emblem = icon_theme.load_icon(ICON_LOCKED, int(float(icon_size)/2.0), 0)
                (width, height) = (emblem.get_width(), emblem.get_height())
                emblem.composite(icon, 0, 0, width, height, 0, 0, 1, 1, gtk.gdk.INTERP_BILINEAR, 255)
            except:
                log('(get_tree_icon) Error adding emblem to icon "%s".', icon_name)

    if icon_cache is not None:
        icon_cache[(icon_name,add_bullet,add_padlock,icon_size)] = icon

    return icon


def get_first_line( s):
    """
    Returns only the first line of a string, stripped so
    that it doesn't have whitespace before or after.
    """
    return s.strip().split('\n')[0].strip()


def updated_parsed_to_rfc2822( updated_parsed):
    """
    Converts a 9-tuple from feedparser's updated_parsed 
    field to a C-locale string suitable for further use.

    If the updated_parsed field is None or not a 9-tuple,
    this function returns None.
    """
    if updated_parsed is None or len(updated_parsed) != 9:
        return None

    old_locale = locale.getlocale( locale.LC_TIME)
    locale.setlocale( locale.LC_TIME, 'C')
    result = time.strftime( '%a, %d %b %Y %H:%M:%S GMT', updated_parsed)
    if old_locale != (None, None):
        try:
            locale.setlocale( locale.LC_TIME, old_locale)
        except:
            log('Cannot revert locale to (%s, %s)', *old_locale)
            pass
    return result


def object_string_formatter( s, **kwargs):
    """
    Makes attributes of object passed in as keyword 
    arguments available as {OBJECTNAME.ATTRNAME} in 
    the passed-in string and returns a string with 
    the above arguments replaced with the attribute 
    values of the corresponding object.

    Example:

    e = Episode()
    e.title = 'Hello'
    s = '{episode.title} World'
    
    print object_string_formatter( s, episode = e)
          => 'Hello World'
    """
    result = s
    for ( key, o ) in kwargs.items():
        matches = re.findall( r'\{%s\.([^\}]+)\}' % key, s)
        for attr in matches:
            if hasattr( o, attr):
                try:
                    from_s = '{%s.%s}' % ( key, attr )
                    to_s = getattr( o, attr)
                    result = result.replace( from_s, to_s)
                except:
                    log( 'Could not replace attribute "%s" in string "%s".', attr, s)

    return result


def format_desktop_command( command, filename):
    """
    Formats a command template from the "Exec=" line of a .desktop
    file to a string that can be invoked in a shell.

    Handled format strings: %U, %u, %F, %f and a fallback that
    appends the filename as first parameter of the command.

    See http://standards.freedesktop.org/desktop-entry-spec/1.0/ar01s06.html
    """
    items = {
            '%U': 'file://%s' % filename,
            '%u': 'file://%s' % filename,
            '%F': filename,
            '%f': filename,
    }

    for key, value in items.items():
        if command.find( key) >= 0:
            return command.replace( key, value)

    return '%s "%s"' % ( command, filename )


def find_command( command):
    """
    Searches the system's PATH for a specific command that is
    executable by the user. Returns the first occurence of an
    executable binary in the PATH, or None if the command is 
    not available.
    """

    if 'PATH' not in os.environ:
        return None

    for path in os.environ['PATH'].split( os.pathsep):
        command_file = os.path.join( path, command)
        if os.path.isfile( command_file) and os.access( command_file, os.X_OK):
            return command_file
        
    return None


def parse_itunes_xml(url):
    """
    Parses an XML document in the "url" parameter (this has to be
    a itms:// or http:// URL to a XML doc) and searches all "<dict>"
    elements for the first occurence of a "<key>feedURL</key>"
    element and then continues the search for the string value of
    this key.

    This returns the RSS feed URL for Apple iTunes Podcast XML
    documents that are retrieved by itunes_discover_rss().
    """
    url = url.replace('itms://', 'http://')
    doc = http_get_and_gunzip(url)
    try:
        d = xml.dom.minidom.parseString(doc)
    except Exception, e:
        log('Error parsing document from itms:// URL: %s', e)
        return None
    last_key = None
    for pairs in d.getElementsByTagName('dict'):
        for node in pairs.childNodes:
            if node.nodeType != node.ELEMENT_NODE:
                continue

            if node.tagName == 'key' and node.childNodes.length > 0:
                if node.firstChild.nodeType == node.TEXT_NODE:
                    last_key = node.firstChild.data

            if last_key != 'feedURL':
                continue

            if node.tagName == 'string' and node.childNodes.length > 0:
                if node.firstChild.nodeType == node.TEXT_NODE:
                    return node.firstChild.data

    return None


def http_get_and_gunzip(uri):
    """
    Does a HTTP GET request and tells the server that we accept
    gzip-encoded data. This is necessary, because the Apple iTunes
    server will always return gzip-encoded data, regardless of what
    we really request.

    Returns the uncompressed document at the given URI.
    """
    request = urllib2.Request(uri)
    request.add_header("Accept-encoding", "gzip")
    usock = urllib2.urlopen(request)
    data = usock.read()
    if usock.headers.get('content-encoding', None) == 'gzip':
        data = gzip.GzipFile(fileobj=StringIO.StringIO(data)).read()
    return data


def itunes_discover_rss(url):
    """
    Takes an iTunes-specific podcast URL and turns it
    into a "normal" RSS feed URL. If the given URL is
    not a phobos.apple.com URL, we will simply return
    the URL and assume it's already an RSS feed URL.

    Idea from Andrew Clarke's itunes-url-decoder.py
    """

    if url is None:
        return url

    if not 'phobos.apple.com' in url.lower():
        # This doesn't look like an iTunes URL
        return url

    try:
        data = http_get_and_gunzip(url)
        (url,) = re.findall("itmsOpen\('([^']*)", data)
        return parse_itunes_xml(url)
    except:
        return None


def idle_add(func, *args):
    """
    This is a wrapper function that does the Right
    Thing depending on if we are running a GTK+ GUI or
    not. If not, we're simply calling the function.

    If we are a GUI app, we use gobject.idle_add() to
    call the function later - this is needed for
    threads to be able to modify GTK+ widget data.
    """
    if gpodder.interface in (gpodder.GUI, gpodder.MAEMO):
        def x(f, *a):
            f(*a)
            return False

        gobject.idle_add(func, *args)
    else:
        func(*args)


def discover_bluetooth_devices():
    """
    This is a generator function that returns
    (address, name) tuples of all nearby bluetooth
    devices found.

    If the user has python-bluez installed, it will
    be used. If not, we're trying to use "hcitool".

    If neither python-bluez or hcitool are available,
    this function is the empty generator.
    """
    try:
        # If the user has python-bluez installed
        import bluetooth
        log('Using python-bluez to find nearby bluetooth devices')
        for name, addr in bluetooth.discover_devices(lookup_names=True):
            yield (name, addr)
    except:
        if find_command('hcitool') is not None:
            log('Using hcitool to find nearby bluetooth devices')
            # If the user has "hcitool" installed
            p = subprocess.Popen(['hcitool', 'scan'], stdout=subprocess.PIPE)
            for line in p.stdout:
                match = re.match('^\t([^\t]+)\t([^\t]+)\n$', line)
                if match is not None:
                    (addr, name) = match.groups()
                    yield (name, addr)
        else:
            log('Cannot find either python-bluez or hcitool - no bluetooth?')
            return # <= empty generator


def bluetooth_send_file(filename, device=None, callback_finished=None):
    """
    Sends a file via bluetooth using gnome-obex send.
    Optional parameter device is the bluetooth address
    of the device; optional parameter callback_finished
    is a callback function that will be called when the
    sending process has finished - it gets one parameter
    that is either True (when sending succeeded) or False
    when there was some error.

    This function tries to use "bluetooth-sendto", and if
    it is not available, it also tries "gnome-obex-send".
    """
    command_line = None

    if find_command('bluetooth-sendto'):
        command_line = ['bluetooth-sendto']
        if device is not None:
            command_line.append('--device=%s' % device)
    elif find_command('gnome-obex-send'):
        command_line = ['gnome-obex-send']
        if device is not None:
            command_line += ['--dest', device]

    if command_line is not None:
        command_line.append(filename)
        result = (subprocess.Popen(command_line).wait() == 0)
        if callback_finished is not None:
            callback_finished(result)
        return result
    else:
        log('Cannot send file. Please install "bluetooth-sendto" or "gnome-obex-send".')
        if callback_finished is not None:
            callback_finished(False)
        return False
        
        
def format_seconds_to_hour_min_sec(seconds):
    """
    Take the number of seconds and format it into a
    human-readable string (duration).

    >>> format_seconds_to_hour_min_sec(3834)
    '1 hour, 3 minutes and 54 seconds'
    >>> format_seconds_to_hour_min_sec(2600)
    '1 hour'
    >>> format_seconds_to_hour_min_sec(62)
    '1 minute and 2 seconds'
    """

    if seconds < 1:
        return _('0 seconds')

    result = []

    hours = seconds/3600
    seconds = seconds%3600

    minutes = seconds/60
    seconds = seconds%60

    if hours == 1:
        result.append(_('1 hour'))
    elif hours > 1:
        result.append(_('%i hours') % hours)

    if minutes == 1:
        result.append(_('1 minute'))
    elif minutes > 1:
        result.append(_('%i minutes') % minutes)

    if seconds == 1:
        result.append(_('1 second'))
    elif seconds > 1:
        result.append(_('%i seconds') % seconds)

    if len(result) > 1:
        return (' '+_('and')+' ').join((', '.join(result[:-1]), result[-1]))
    else:
        return result[0]


def get_episode_info_from_url(url, proxy=None):
    """
    Try to get information about a podcast episode by sending
    a HEAD request to the HTTP server and parsing the result.

    The return value is a dict containing all fields that 
    could be parsed from the URL. This currently contains:
    
      "length": The size of the file in bytes
      "pubdate": A formatted representation of the pubDate

    If the "proxy" parameter is used, it has to be the URL 
    of the HTTP proxy server to use, e.g. http://proxy:8080/
    
    If there is an error, this function returns {}. This will
    only function with http:// and https:// URLs.
    """
    if not (url.startswith('http://') or url.startswith('https://')):
        return {}

    if proxy is None or proxy.strip() == '':
        (scheme, netloc, path, parms, qry, fragid) = urlparse.urlparse(url)
        conn = httplib.HTTPConnection(netloc)
        start = len(scheme) + len('://') + len(netloc)
        conn.request('HEAD', url[start:])
    else:
        (scheme, netloc, path, parms, qry, fragid) = urlparse.urlparse(proxy)
        conn = httplib.HTTPConnection(netloc)
        conn.request('HEAD', url)

    r = conn.getresponse()
    result = {}

    log('Trying to get metainfo for %s', url)

    if 'content-length' in r.msg:
        try:
            length = int(r.msg['content-length'])
            result['length'] = length
        except ValueError, e:
            log('Error converting content-length header.')

    if 'last-modified' in r.msg:
        try:
            parsed_date = feedparser._parse_date(r.msg['last-modified'])
            pubdate = updated_parsed_to_rfc2822(parsed_date)
            result['pubdate'] = pubdate
        except:
            log('Error converting last-modified header.')

    return result


def gui_open(filename):
    """
    Open a file or folder with the default application set
    by the Desktop environment. This uses "xdg-open".
    """
    try:
        subprocess.Popen(['xdg-open', filename])
        # FIXME: Win32-specific "open" code needed here
        # as fallback when xdg-open not available
    except:
        log('Cannot open file/folder: "%s"', folder, sender=self, traceback=True)


def open_website(url):
    """
    Opens the specified URL using the default system web
    browser. This uses Python's "webbrowser" module, so
    make sure your system is set up correctly.
    """
    threading.Thread(target=webbrowser.open, args=(url,)).start()


def sanitize_filename(filename):
    """
    Generate a sanitized version of a filename that can
    be written on disk (i.e. remove/replace invalid 
    characters and encode in the native language)
    """
    # Try to detect OS encoding (by Leonid Ponomarev)
    if 'LANG' in os.environ and '.' in os.environ['LANG']:
        lang = os.environ['LANG']
        (language, encoding) = lang.rsplit('.', 1)
        log('Detected encoding: %s', encoding)
        enc = encoding
    else:
        # Using iso-8859-15 here as (hopefully) sane default
        # see http://en.wikipedia.org/wiki/ISO/IEC_8859-1
        log('Using ISO-8859-15 as encoding. If this')
        log('is incorrect, please set your $LANG variable.')
        enc = 'iso-8859-15'

    return re.sub('[/|?*<>:+\[\]\"\\\]', '_', filename.strip().encode(enc, 'ignore'))


def find_mount_point(directory):
    """
    Try to find the mount point for a given directory.
    If the directory is itself a mount point, return
    it. If not, remove the last part of the path and
    re-check if it's a mount point. If the directory
    resides on your root filesystem, "/" is returned.
    """
    while os.path.split(directory)[0] != '/':
        if os.path.ismount(directory):
            return directory
        else:
            (directory, tail_data) = os.path.split(directory)

    return '/'

