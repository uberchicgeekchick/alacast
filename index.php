<?php

	ini_set("display_errors", "true");
	ini_set("error_reporting", E_ALL);// & E_STRICT);
	
	if (!(isset($_GET['channel'])))
		$_GET['channel']="";
	
	require_once( "./support/settings.inc.php" );
	require_once( "./support/functions.inc.php" );



	print("<html>\n\t<head>\n\t\t<title>Alacast</title>\n\t</head>\n\t<body>\n\t<iframe name='subscribe' id='subscribe' style='display:none;'></iframe>");

	foreach( $podcasts as $channel=>$allPodcasts )
		if( $channel != $_GET['channel'] )
			print("\t\t<a href='./?channel=".rawurlencode($channel)."'>{$channel}</a><br/>\n");
		else
			showSubscribeLinks($channel, $allPodcasts, $subscribe);
	
	print("\t</body>\n</html>");


?>
