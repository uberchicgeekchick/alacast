<?php

	function my_uri_encoder(&$uri) {
		if(!(
			(is_array(
				($uri_parts= preg_split("/\?/", $uri))
			))
			&&
			(count($uri_parts)) > 1
		))
			return preg_replace("/[\"]/", "\\\"", $uri);

		return "{$uri_parts[0]}?" .
			preg_replace("/(%3D)/", "=",
				preg_replace( "/(%26)/", "&amp;",
					rawurlencode(
						$uri_parts[1]
					)
				)
			);
	}//end 'my_uri_encoder' function.
	
	function my_isset(&$variable) {
		if((
			((isset($variable)))
			&&
			(trim($variable))
		))
			return TRUE;
		
		return FALSE;
	}//end 'my_isset' function.

	function exportPodcasts() {
		if(!((isset($_GET['format']))))
			return paintPodcastsHTML();
		
		switch($_GET['format']) {
			case 'OPML':
				return paintPodcastsOpml();
			case 'VLC':
				return paintRawPodcastList('|');
			case 'flat list':
				return paintRawPodcastList();
		}
	}//end 'exportPodcasts' method.

	function getPodcasts() {
		$channels=array('total'=>0);
		$podcastsDir=opendir($GLOBALS['podcastsDir']);
		while(($channelList=readdir($podcastsDir)))
			if((
				(preg_match("/^[0-9]{2}\-([^\-]*)\-[0-9]{2}\.podcasts\.php$/", $channelList))
				&&
				($channel=(preg_replace("/^[0-9]{2}\-([^\-]*)\-[0-9]{2}\.podcasts\.php$/", "$1", $channelList)))
			))
				$channels[$channels['total']++]=array('podcastsPHP'=>$channelList,'category'=>$channel);
		closedir($podcastsDir);
		unset($channels['total']);
		array_multisort($channels);
		
		return $channels;
	}//end 'getPodcasts' function.

?>
