<?php
	/*
	 * (c) 2007-Present Kathryn G. Bohmont <uberChicGeekChick.Com -at- uberChicGeekChick.Com>
	 * 	http://uberChicGeekChick.Com/
	 * Writen by an uberChick, other uberChicks please meet me & others @:
	 * 	http://uberChicks.Net/
	 *I'm also disabled; living with Generalized Dystonia.
	 * Specifically: DYT1+/Early-Onset Generalized Dystonia.
	 * 	http://Dystonia-DREAMS.Org/
	 */

	/*
	 * Unless explicitly acquired and licensed from Licensor under another
	 * license, the contents of this file are subject to the Reciprocal Public
	 * License ("RPL") Version 1.5, or subsequent versions as allowed by the RPL,
	 * and You may not copy or use this file in either source code or executable
	 * form, except in compliance with the terms and conditions of the RPL.
	 *
	 * All software distributed under the RPL is provided strictly on an "AS
	 * IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND
	 * LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT
	 * LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
	 * PURPOSE, QUIET ENJOYMENT, OR NON-INFRINGEMENT. See the RPL for specific
	 * language governing rights and limitations under the RPL.
	 *
	 * ---------------------------------------------------------------------------------
	 * |	A copy of the RPL 1.5 may be found with this project or online at	|
	 * |		http://opensource.org/licenses/rpl1.5.txt					|
	 * ---------------------------------------------------------------------------------
	 */
	
	/*
	 * ALWAYS PROGRAM FOR ENJOYMENT &PLEASURE!!!
	 * Feel comfortable takeing baby steps.  Every moment is another step; step by step; there are only baby steps.
	 * Being verbose in comments, variables, functions, methods, &anything else IS GOOD!
	 * If I forget ANY OF THIS than READ:
	 * 	"Paul Graham's: Hackers &Painters"
	 * 	&& ||
	 * 	"The Mentor's Last Words: The Hackers Manifesto"
	 */
	namespace alacast;
	
	function help() {
		print( "Usage: alacast.php [options]..."
			."\n\tOptions:"
			."\n"
			."\n"
			."\nUpdate options:"
			."\n----------------------------------------------"
			."\n\t--update				runs `gpodder-11.3-hacked --local --run` automatically before moving podcasts."
			."\n"
			."\n\t--nice[=priority]			Runs alacast with the specified priority (default: +19)."
			."\n"
			."\n\t--update=detailed			Displays the output from: `gpodder-11.3-hacked --local --run`."
			."\n\t						This is usually the URIs of your subscribed podcasts"
			."\n\t						and any new epidodes."
			."\n"
			."\n\t--interactive			Prompts before quiting/continuing."
			."\n"
			."\n"
			."\nOutput options:"
			."\n--------------------"
			."\n\t--quiet"
			."\n\t				This keeps any output from being output to the terminal."
			."\n\t				This is useful when ran as a cron job."
			."\n\t--verbose"
			."\n\t				These effect how much information is displayed about what"
			."\n\t				I'm doing.  These are mostly messages useful for debugging."
			."\n"
			."\n\t--logging"
			."\n\t				This writes all regular, &`--update output to this script's log file."
			."\n"
			."\n"
			."\nSymlink options:"
			."\n-------------------------"
			."\n\t--leave-trails		Leave [GUID].trail symlinks to alacast's GUID folder."
			."\n"
			."\n\t--clean-trails		This just removes any symlinks that may have been created by"
			."\n\t				previously using the`--leave-trails` option."
			."\n"
			."\n"
			."\nSyncing options:"
			."\n-------------------"
			."\n\t--keep-original		keeps alacast GUID based named files while making copies of all"
			."\n\t					podcasts with easier to understand directories &filenames."
			."\n"
			."\n\t--player[=vlc|gstreamer|xine]		different players have issues with different charaters"
			."\n\t				in the path's of podcast's files.  known issues are:"
			."\n\t				- vlc won't play files with colons(:) in their path."
			."\n\t				- xine won't play files with octothorps(#) in their path."
			."\n\t				so adding this option strips these characters from podcasts'"
			."\n\t				sub-directory and file names."
			."\n\t				if --player is alone all characters that might cause problems"
			."\n\t				are removed.  if a value for player is set than just the"
			."\n\t				character(s) known to cause issues with that player will be"
			."\n\t				removed."
			."\n"
			."\n"
			."\nNaming/Title options:"
			."\n----------------------"
			."\n\t--titles-prefix-podcast-name"
			."\n\t--titles-append-pubdate"
			."\n"
			."\n"
			."\n\t--help			displays this screen."
			."\n"
			."\n"
			."\n\t		*wink* &remember alacast.php is written in PHP;"
			."\n\t		so its super easy to customize.  just remember to share ^_~"
			."\n"
			."\n"
		);
		
		exit(0);
		
	}/*\alacast\help();*/

?>
