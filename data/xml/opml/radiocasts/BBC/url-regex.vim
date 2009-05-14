http://www.bbc.co.uk/radio/podcasts/forum60sec/
http://downloads.bbc.co.uk/podcasts/worldservice/forum60sec/rss.xml

1,$s/<div class="[^"]\+podcastcell">.*<h3><a href="\/radio\([^"]\+\)">\([^<]\+\)<\/a><\/h3>.*[\r\n\t\ ]\+.*[\r\n\t\ ]\+<\/li><li class="restrictions\ ukonly">.*<p>\(.*\)<\/p><\/div><\/div><\/div><\/div><\/div>//g

1,$s/<div class="[^"]\+podcastcell">.*<h3><a href="\/radio\([^"]\+\)">\([^<]\+\)<\/a><\/h3>.*[\r\n\t\ ]\+.*[\r\n\t\ ]\+<\/li><li class="restrictions\ none">.*<p>\(.*\)<\/p><\/div><\/div><\/div><\/div><\/div>/\r\t\t<outline title="<!\[CDATA\[\2\]\]>" xmlUrl="http:\/\/downloads\.bbc\.co\.uk\/radio4\1rss\.xml" type="rss" htmlUrl="http:\/\/www\.bbc\.co\.uk\/radio\1" text="<!\[CDATA\[\2\ from\ the\ BBC\&#039;\ Radio4\]\]>" description="<!\[CDATA\[\3\]\]>"\/>/g

1,$s/<div class="[^"]\+podcastcell">.*<h3><a href="\/radio\([^"]\+\)">\([^<]\+\)<\/a><\/h3>.*[\r\n\t\ ]\+.*/\r\t\t<outline title="<!\[CDATA\[\2\]\]>" xmlUrl="http:\/\/downloads\.bbc\.co\.uk\/radio\1rss\.xml" type="rss" htmlUrl="http:\/\/www\.bbc\.co\.uk\/radio\1" text="<!\[CDATA\[\2\ from\ the\ BBC\&#039;\ Radio\1\]\]>" description="<!\[CDATA\[\2\ from\ the\ BBC\&#039;\ Radio\1\]\]>"\/>/g
