<?php
		function showSubscribeLinks(&$channel, &$podcasts, &$subscribe) {
		print("\t\t<label for='{$channel}'>{$channel} podcasts</label><br/>\n");
		$sub2all = "";
		print("\t\t<ul name='{$channel}' id='{$channel}'>\n");
		$i = 0;
		foreach($podcasts as $podcast => $links) {
			if(!(
				$podcast
				&&
				$links['rss']
			))
				continue;
			
			$i++;
			
			$link2 = rawurlencode($links['rss']);
			if( $i > 1 )
				$sub2all .= "&amp;";
			$sub2all .= "{$subscribe['get']}{$i}={$link2}";
			print("\t\t\t<li><a href='{$links['homepage']}' target='_blank'>{$podcast}</a> - [<a href='{$subscribe['uri']}?{$subscribe['get']}"
				.( $GLOBALS['subscribe']['count']
					? "1"
					: ""
				)
			."={$link2}' target='subscribe'>subscribe</a>] [<a href='{$link}'>rss</a>]\n");
		}
		
		print("\t\t</ul>\n\t\t");
		
		if(
			$subscribe['count']
			&&
			$i>1
		)
			print("<a href='{$subscribe['uri']}?{$sub2all}' target='subscribe'>subscribe to all {$channel} podcasts</a>");

		print("[<a href='./?{$_GET['subscribe']}'>hide</a>]\n\t\t<br/><br/>\n");
		
	}
?>
