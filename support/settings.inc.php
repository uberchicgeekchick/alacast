<?php
	if(!(isset($_GET['subscribe'])))
		$_GET['subscribe'] = "podnova";

	switch($_GET['subscribe']) {
		case "odeo":
			$subscribe = array(
				'uri'	=>	"http://odeo.com/listen/subscribe",
				'get'	=>	"feed",
				'count'	=>	false
			);
		break;

		case "podnova":
			$subscribe = array(
				'uri'   =>      "http://www.podnova.com/add.srf",
				'get'   =>      "url",
				'count' =>      false
			);
		break;

		case "democracy": default:
			$subscribe = array(
				'uri'   =>      "http://subscribe.getdemocracy.com/",
				'get'   =>      "url",
				'count' =>      true
			);
		break;
	}
?>
