#/bin/tcsh -f
set base_url="http://www.bbc.co.uk/podcasts";

foreach station ( "`cat stations.lst`" )
	@ page=2;
	set station_url = "${base_url}/${station}"
	wget -O "${station}.opml" "${station_url}/"
	while ( "`grep 'Next' '${station}'.opml`" != "" )
		wget -a "${station}.opml" "${station_url}/page${page}2"
		@ page++;
	end
end
