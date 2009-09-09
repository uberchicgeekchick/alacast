# -*- coding: utf-8 -*-
# 
# python-feedcache (customized by Thomas Perl for use in gPodder)
#
# Copyright 2007 Doug Hellmann.
#
#
#                         All Rights Reserved
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby
# granted, provided that the above copyright notice appear in all
# copies and that both that copyright notice and this permission
# notice appear in supporting documentation, and that the name of Doug
# Hellmann not be used in advertising or publicity pertaining to
# distribution of the software without specific, written prior
# permission.
#
# DOUG HELLMANN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN
# NO EVENT SHALL DOUG HELLMANN BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
# OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#


import feedparser

import time
import gpodder

from gpodder.liblogger import log


def patch_feedparser():
    """Fix a bug in feedparser 4.1
    This replaces the mapContentType method of the
    _FeedParserMixin class to correctly detect the
    "plain" content type as "text/plain".

    See also:
    http://code.google.com/p/feedparser/issues/detail?id=80

    Added by Thomas Perl for gPodder 2007-12-29
    """
    def mapContentType2(self, contentType):
        contentType = contentType.lower()
        if contentType == 'text' or contentType == 'plain':
            contentType = 'text/plain'
        elif contentType == 'html':
            contentType = 'text/html'
        elif contentType == 'xhtml':
            contentType = 'application/xhtml+xml'
        return contentType

    try:
        if feedparser._FeedParserMixin().mapContentType('plain') == 'plain':
            log('Patching feedparser module... (mapContentType bugfix)')
            feedparser._FeedParserMixin.mapContentType = mapContentType2
    except:
        log('Warning: feedparser unpatched - might be broken!')

patch_feedparser()


class Cache:
    """A class to wrap Mark Pilgrim's Universal Feed Parser module
    (http://www.feedparser.org) so that parameters can be used to
    cache the feed results locally instead of fetching the feed every
    time it is requested. Uses both etag and modified times for
    caching.
    """

    def __init__(self, storage, timeToLiveSeconds=3600):
        """
        Arguments:

          storage -- Backing store for the cache.  It should follow
          the dictionary API, with URLs used as keys.  It should
          persist data.

          timeToLiveSeconds=300 -- The length of time content should
          live in the cache before an update is attempted.
        """
        self.storage = storage
        self.time_to_live = timeToLiveSeconds
        self.user_agent = gpodder.user_agent
        return

    def fetch(self, url, force_update = False, offline = False):
        """
        Returns an (updated, feed) tuple for the feed at the specified
        URL. If the feed hasn't updated since the last run, updated
        will be False. If it has been updated, updated will be True.
        """

        modified = None
        etag = None
        now = time.time()

        cached_time, cached_content = self.storage.get(url, (None, None))

        if offline and cached_content is not None:
            return (False, cached_content)

        # Does the storage contain a version of the data
        # which is older than the time-to-live?
        if cached_time is not None:
            if self.time_to_live:
                age = now - cached_time
                if age <= self.time_to_live and not force_update:
                    return (False, cached_content)
            
            # The cache is out of date, but we have
            # something.  Try to use the etag and modified_time
            # values from the cached content.
            etag = cached_content.get('etag')
            modified = cached_content.get('modified')

        # We know we need to fetch, so go ahead and do it.
        parsed_result = feedparser.parse(url,
                                         agent=self.user_agent,
                                         modified=modified,
                                         etag=etag,
                                         )

        updated = False
        status = parsed_result.get('status', None)
        if status == 304:
            # No new data, based on the etag or modified values.
            # We need to update the modified time in the
            # storage, though, so we know that what we have
            # stored is up to date.
            self.storage[url] = (now, cached_content)
            log('Using cached feed: %s', url, sender=self)

            # Return the data from the cache, since
            # the parsed data will be empty.
            parsed_result = cached_content
        elif status in (200, 301, 302, 307):
            updated = True
            # There is new content, so store it unless there was an error.
            # Store it regardless of errors when we don't have anything yet
            error = parsed_result.get('bozo_exception')
            if error:
                log('Warning: %s (%s)', url, str(error), sender = self)
                # Convert the exception to a string, so we can pickle it
                parsed_result['bozo_exception'] = str(error)

            self.storage[url] = (now, parsed_result)
        else:
            log('Strange status code: %s ("%s")', url, status, sender = self)

        return (updated, parsed_result)

