<?php
	$GLOBALS['podcastsDir']="./OPMLs/podcast_arrays/";

	if (!(isset($_GET['channel'])))
		$_GET['channel']="";

	if(!((isset($_GET['subscribe']))))
		$_GET['subscribe'] = "";

	if(!((isset($_GET['format']))))
		$_GET['format']="";

?>