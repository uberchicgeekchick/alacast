#!/bin/tcsh -f
rm .*.swp >& /dev/null;
cp backup/*\&*.opml .;
wget -O theworld.org.opml 'http://theworld.org/podcasts/'

set opml="theworld.org.opml";

ex -s '+1,$s/\v\r\n?\_$//g' '+1,$s/\n//g' '+s/<span class="pd_title_sub">\([^<]\+\)<\/span>/\1/g' '+1,$s/\(<a name="[^"]\+"><\/a>\)[\ \t]*/\r\1/g' '+wq' "${opml}";
sleep 2;
ex -s '+1,$s/^<a name="\([^"]\+\)"><\/a>.*<\!\-\-pod tile \(.*\)\-\->.*<span class="pd_title">\([^<]\+\)<\/span>.*class="pd_descp">[\ \t]*\([^<>]*\).*<form.*pd_rss"><a href=\("[^"]\+"\).*\/form.*<span class="programlink caption"><a href=\("[^"]\+"\).*\-\->[\ \t]*$/\t\t<outline title="<\!\[CDATA\[\3\]\]>" xmlUrl=\5 type="rss" text="<\!\[CDATA\[CBC.ca Radio\&#039;s \&quot;\2\&quot; podcast\]\]>" htmlUrl=\6 description="<\!\[CDATA\[\4\]\]>"\/>/' '+wq' "${opml}";
sleep 2;
ex -s '+1,$s/^<a name="\([^"]\+\)"><\/a>.*<\!\-\-pod tile \(.*\)\-\->[\n\r]*.*<span class="pd_title">\([^<]\+\)<\/span>.*class="pd_descp">[\ \t]*\([^<>]*\).*<form.*pd_rss"><a href=\("[^"]\+"\).*\/form.*\-\->[\ \t]*$/\t\t<outline title="<\!\[CDATA\[\3\]\]>" xmlUrl=\5 type="rss" text="<\!\[CDATA\[CBC.ca Radio\&#039;s \&quot;\2\&quot; podcast\]\]>" htmlUrl="http:\/\/cbc.ca\/podcasting\/#\1" description="<\!\[CDATA\[\4\]\]>"\/>/' '+wq' "${opml}";
sleep 2;
ex -s '+1,$s/[\ \t]*\(\]\]>"\)/\1/g' '+wq' "${opml}"

