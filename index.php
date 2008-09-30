<?php
	//To access Alacast's OPML add this QUERY_STRING '?subscribe=export&format=OPML' to Alacast URI.
	ini_set("display_errors", "true");
	ini_set("error_reporting", E_ALL | E_STRICT);
	ini_set( "date.timezone", "America/Denver" );

	require_once("functions/support.php");
	require_once("functions/display.php");

	require_once("settings/auto-globals.php");

	header( "Content-Type: text/html; charset=utf-8" );

	if(($_GET['subscribe']=="export"))
		exportPodcasts();
	else
		paintPodcastsHtml( (require_once( "settings/aggregators.php" )) );

?>
