<?php
	function paintSubscribeLinks(&$channel, &$podcasts, &$subscribe) {
		$sub2all = "";
		$i = 0;
		ob_start();
		print("\n\t\t\t\t\t<label for='{$channel}'>{$channel} podcasts</label><br/>");
		print("\n\t\t\t\t\t<div class='close'>\n\t\t\t\t\t\t[<a href='./?subscribe={$_GET['subscribe']}&amp;export='{$_GET['format']}'>close</a>]\n\t\t\t\t\t</div>\n\t\t\t\t\t<hr size='1'/><br/>");
		foreach($podcasts as $podcast => $links) {
			if(!(
				$podcast
				&&
				($links['rss'] || $links['www'] )
			))
				continue;
			
			$i++;

			if(!($links['rss'])){ $link2=''; $link3=''; }
			else {
				$link2=rawurlencode( ((binary)$links['rss']) );
				$link3=base64_encode( $links['rss'] );
				if( $i > 1 )
					$sub2all .= "&amp;";
				$sub2all .= "{$subscribe['get']}{$i}={$link2}";
			}//end:if($links['rss']);

			print("\n\t\t\t\t\t\t"
			.($links['rss']
				?"<input type='checkbox' name='selectedPodcasts[]' value='{$link3}'>"
				:"<input type='checkbox' style='visibility:hidden;' isabled>"
			)
			.($links['www']
				?("<a href='{$links['www']}' target='subscribe'>".( wordwrap($podcast, 34, "</a>\n\t\t\t\t\t\t<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='{$links['www']}' target='subscribe'>", false) )."</a>")
				:($podcast)
			)
			.($links['rss']
				?("<div style='text-indent:40px; vertical-align:sub; font-size:small;'>[<a href='{$subscribe['uri']}?{$subscribe['get']}"
					.( $subscribe['count']
						?"1"
						:""
					)
					."={$link2}' target='subscribe'>subscribe</a>] - [<a href='{$links['rss']}' target='subscribe'>view rss</a>]</div>")
				:("<br/>")
			)
			);
		}
		if( ! $i ) {
			ob_end_clean();
			return;
		}
		
		ob_end_flush();
		
		print("\n\t\t\t\t\t</ul>\n\t\t\t\t\t");
		
		if($subscribe['count'])
			print("<div class='close'>\n\t\t\t\t\t\t<a href='{$subscribe['uri']}?{$sub2all}' target='subscribe'>subscribe to all {$channel} podcasts</a>\n\t\t\t\t\t</div>");

		print("<div class='close'>\n\t\t\t\t\t\t[<a class='close' href='./?subscribe={$_GET['subscribe']}&amp;export='{$_GET['format']}'>close</a>]\n\t\t\t\t\t</div>\n\t\t\t\t\t<hr size='1'/><br/>");
		
	}//end 'paintSubscribeLinks' function.



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
				paintSubscribeLinks($channel['category'], (require_once("{$GLOBALS['podcastsDir']}{$channel['podcastsPHP']}")), $subscribe);
			else
				print("\n\t\t\t\t\t<a href='./?subscribe={$_GET['subscribe']}&amp;channel=".(rawurlencode( ((binary)$channel['category']) ))."'>{$channel['category']} podcasts</a><br/>");
		
		print("\n\t\t\t\t<br />\n\t\t\t\t<input type='submit' value='Alacast'> <input type='reset' value='unselect all podcasts'>\n\t\t\t</div>\n\t\t\t</form>\n\t</body>\n</html>");
	}//end 'paintPodcastsHtml' function.



	function paintPodcastsOpml($Valid_XML=True) {
		header( "Content-disposition: attachment; filename=channels.opml" );
		
		printf("<?xml version='1.0' encoding='utf-8'?>\n<opml version=\"1.1\">\n\t<head>\n\t\t<title>Alacast</title>\n\t\t<dateCreated>%s</dateCreated>\n\t</head>\n\t<body>\n", (date("D M d H:i:s Y")) );
		$channels=getPodcasts();
		foreach($channels as $channel) {
			$an_or_a="a".
				((preg_match("/^[aeiou]/", $channel['category']))
					?"n"
					:""
				);
			$channel['category']=rawurlencode( ((binary)$channel['category']) );
			
			foreach((require_once("{$GLOBALS['podcastsDir']}{$channel['podcastsPHP']}")) as $podcast => $links) {
				if(!(
					$podcast
					&&
					$links['rss']
				))
					continue;
				
				$podcast=htmlentities($podcast, ENT_QUOTES);
				$links['www']=my_uri_encoder($links['www']);
				$links['rss']=my_uri_encoder($links['rss'], $Valid_XML);
				
				print("\t\t<outline title=\"{$podcast}\" text=\"&quot;{$podcast}&quot; is {$an_or_a} {$channel['category']} podcast\" type=\"rss\" xmlUrl=\"{$links['rss']}\" htmlUrl=\"{$links['www']}\"/>\n");
			}
		}
		
		print("\t</body>\n</opml>");
	}//end 'paintPodcastsOpml' function.



	function paintRawPodcastList($spacer="\n") {
		print("<html>\n\t<head>\n\t\t<title>Alacast</title>\n\t</head>\n\t<body style='background-color:#ffddee;'>\n\t\t<textarea style='width:90%; height:90%;'>");
		$channels=getPodcasts();
		$podcastsStarted=0;
		foreach($channels as $channel) {
			foreach((require_once("{$GLOBALS['podcastsDir']}{$channel['podcastsPHP']}")) as $podcast => $links) {
				if(!($links['rss']))
					continue;
				
				if(!($podcastsStarted))
					$podcastsStarted=1;
				
				print(
					($podcastsStarted	?$spacer	:""	)
					.($links['rss'])
				);
			}
		}
		print("</textarea>\n\t</body>\n</html>");
	}//end 'paintPodcastsList' function.

?>
