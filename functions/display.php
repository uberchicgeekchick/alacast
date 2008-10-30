<?php
	require_once("classes/uberChicGeekChicks::podcatcher.class.php");
	require_once("classes/uberChicGeekChicks::rss.class.php");
	$uCGC_rss=new uberChicGeekChicks::rss();
	
	function paintPodcastsHtml(&$subscribe) {
		print("<html>\n\t<head>\n\t\t<title>Alacast</title>\n\t\t<style type='text/css'>\n\t\t/*<![CDATA[*/\n\t\t\t@import url('stylesheet.css');\n\t\t\t/*]]!>*/\n\t\t</style>\n\t</head>\n\t<body>\n\t\t<div class='subscribeToAllPodcasts'>\n\t\t\t");
		
		if($_GET['channel']!="SHOW_ALL_CHANNELS")
			print("[<a href='./?channel=SHOW_ALL_CHANNELS&amp;subscribe={$_GET['subscribe']}' class='subscribeToAllPodcasts'>show all categories links</a>]");
		else
			print("[<a href='./?subscribe={$_GET['subscribe']}&amp;format={$_GET['format']}'>close all categories links</a>]");
		
		print("\n\t\t\t - [<a href='./'>start over</a>]\n\t\t</div>\n\t\t<div class='subscriptionOptions'>");
		
		print("\n\t\t\t<label name='copyright' class='copyright'>Al&aacute;cast is &copy; 2007 Kathryn Bohmont - released under the <a href='rpl-1.3.html'>RPL 1.3</a></label>");
		
		
		
		//Begining SUBSCRIPTION form.
		print("\n\t\t\t<form class=\"subscriptionForm\" post='./' method='get' target='subscribe'>\n\t\t\t\t<input type='hidden' name='channel' value='{$_GET['channel']}'>\n\t\t\t\t<select name='subscribe' onchange='javascript:this.form.submit();'>");
		
		for($i=0; $i<$GLOBALS['aggregators']['total']; $i++)
			print("\n\t\t\t\t\t<option value='{$GLOBALS['aggregators'][$i]}'"
				.(($_GET['subscribe']==$GLOBALS['aggregators'][$i])
					?" selected"
					:""
				).">{$GLOBALS['aggregators'][$i]}</option>"
			);
		
		print("\n\t\t\t\t</select>&nbsp;<input type='submit' value='subscribe'/>\n\t\t\t</form>\n\t\t\t</div>");
		//End SUBSCRIPTION form.
		
		//Begin EXPORT form.
		print("\n\t\t\t<form class='exportForm' method='GET' action='./'>\n\t\t\t\t<input type='hidden' name='subscribe' value='export'>\n\t\t\t\t<nobr><select name='format' onchange='javascript:this.form.submit();'>");
		
		for($i=0; $i<$GLOBALS['exportFormats']['total']; $i++)
			print("\n\t\t\t\t\t<option value='{$GLOBALS['exportFormats'][$i]}'"
				.((
					($_GET['subscribe']=="export")
					&&
					($_GET['format']==$GLOBALS['exportFormats'][$i])
				)
					?" selected"
					:""
				).">{$GLOBALS['exportFormats'][$i]}</option>"
			);
		
		print("\n\t\t\t\t</select>&nbsp;<input type='submit' value='export'/></nobr>\n\t\t\t</form>");
		//End EXPORT form.
		
		//Begin internal `browser` &feedback iframe.
		print("\n\t\t\t<iframe name='subscribe' id='subscribe' class='podcastPreview'></iframe>\n\t\t\t<br/>\n\t\t\t</div>\n\t\t\t<form action='./' method='GET'>\n\t\t\t\t<input type='hidden' name='subscribe' value='{$_GET['subscribe']}'><input type='hidden' name='format' value='{$_GET['format']}'><input type='hidden' name='channel' value='{$_GET['channel']}'>\n\t\t\t\t<div class='podcastsListings'>");
		
		$channels=getPodcasts();
		foreach($channels as $channel)
			if((
				($_GET['channel']==$channel['category'])
				||
				($_GET['channel']=="SHOW_ALL_CHANNELS")
			))
				$GLOBALS['uCGC_rss']->paint_links($channel['category'], (require_once("{$GLOBALS['podcastsDir']}{$channel['podcastsPHP']}")), $subscribe);
			else
				print("\n\t\t\t\t\t<a href='./?subscribe={$_GET['subscribe']}&amp;channel=".(rawurlencode( ((binary)$channel['category']) ))."'>{$channel['category']} podcasts</a><br/>");
		
		print("\n\t\t\t\t<br />\n\t\t\t\t<input type='submit' value='Alacast'> <input type='reset' value='unselect all podcasts'>\n\t\t\t</div>\n\t\t\t</form>\n\t</body>\n</html>");
	}//end 'paintPodcastsHtml' function.



	function paintPodcastsOpml($Valid_XML=True) {
		//Accessed by '?subscribe=export&format=OPML'
		header( (sprintf( "Content-disposition: attachment; filename=\"Alacast's Channels on %s.opml\"", (date("Y-m-d")) )) );
		
		printf("<?xml version='1.0' encoding='utf-8'?>\n<opml version=\"1.1\">\n\t<head>\n\t\t<title>Alacast</title>\n\t\t<dateCreated>%s</dateCreated>\n\t</head>\n\t<body>\n", (date("D M d H:i:s Y")) );
		$channels=getPodcasts();
		foreach($channels as $channel) {
			$a_or_an="a".
				((preg_match("/^[aeiou]/", $channel['category']))
					?"n"
					:""
				);
			$channel['category']=rawurlencode( ((binary)$channel['category']) );
			
			foreach((require_once("{$GLOBALS['podcastsDir']}{$channel['podcastsPHP']}")) as $podcast => $links)
				$GLOBALS['uCGC_rss']->paint_opml_items($podcast, $a_or_an, $Valid_XML, $channel['category'], $links);
		}
		
		print("\t</body>\n</opml>");
	}//end 'paintPodcastsOpml' function.



	function paintRawPodcastList($spacer="\n") {
		print("<html>\n\t<head>\n\t\t<title>Alacast</title>\n\t</head>\n\t<body style='background-color:#ffddee;'>\n\t\t<textarea style='width:90%; height:90%;'>");
		

		print("</textarea>\n\t</body>\n</html>");
	}//end 'paintPodcastsList' function.

?>
