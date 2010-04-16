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

	return array(
		array(
			array( '/\&(#038|amp);/i', '\&' ),
			array( '/\&(#8243|#8217|#8220|#8221|#039|apos|rsquo|lsquo);/i', '\'' ),
			array( '/[\ \t]*&[^;]+;[\ \t]*/i', '' ),
			array( '/<\!\[CDATA\[(.*)\]\]>/', '$1' ),
			array( '/<[^>]+>/', '' ),
			'total'=>5,
		),
		array(
			array( '/^(Zero)([^a-zA-Z])/i', '0$2' ),
			array( '/^(One)([^a-zA-Z])/i', '1$2' ),
			array( '/^(Two)([^a-zA-Z])/i', '2$2' ),
			array( '/^(Three)([^a-zA-Z])/i', '3$2' ),
			array( '/^(Four)([^a-zA-Z])/i', '4$2' ),
			array( '/^(Five)([^a-zA-Z])/i', '5$2' ),
			array( '/^(Six)(teen|ty)?([^a-zA-Z])/i', '6$2$3' ),
			array( '/^(Seven)(teen|ty)?([^a-zA-Z])/i', '7$2$3' ),
			array( '/^(Eigh)(t)(een|ty)?([^a-zA-Z])/i', '8$2$3$6' ),
			array( '/^(Nine)(teen|ty)?([^a-zA-Z])/i', '9$2$3' ),
			array( '/^(Ten)([^a-zA-Z])/i', '10$2' ),
			array( '/^(Eleven)([^a-zA-Z])/i', '11$2' ),
			array( '/^(Twelve)([^a-zA-Z])/i', '12$2' ),
			array( '/^(Thirteen)([^a-zA-Z])/i', '13$2' ),
			array( '/^(Fifteen)([^a-zA-Z])/i', '15$2' ),
			array( '/^([0-9])teen([^a-zA-Z])/i', '1$2$2' ),
			array( '/^(Twenty)([^a-zA-Z])/i', '20$2' ),
			array( '/^(Thirty)([^a-zA-Z])/i', '30$2' ),
			array( '/^(Fifty)([^a-zA-Z])/i', '50$2' ),
			array( '/^([0-9])ty([^a-zA-Z])/i', '${1}0$2' ),
			'total'=>19,
		),
		array(
			array( '/([^a-zA-Z])(Zero)([^a-zA-Z])/i', '${1}0$3' ),
			array( '/([^a-zA-Z])(One)([^a-zA-Z])/i', '${1}1$3' ),
			array( '/([^a-zA-Z])(Two)([^a-zA-Z])/i', '${1}2$3' ),
			array( '/([^a-zA-Z])(Three)([^a-zA-Z])/i', '${1}3$3' ),
			array( '/([^a-zA-Z])(Four)(teen)?([^a-zA-Z])/i', '${1}4$3' ),
			array( '/([^a-zA-Z])(Five)([^a-zA-Z])/i', '${1}5$3' ),
			array( '/([^a-zA-Z])(Six)(teen|ty)?([^a-zA-Z])/i', '${1}6$3$4' ),
			array( '/([^a-zA-Z])(Seven)(teen|ty)?([^a-zA-Z])/i', '${1}7$3$4' ),
			array( '/([^a-zA-Z])(Eigh)(t)(een|ty)?([^a-zA-Z])/i', '${1}8$3$4$5' ),
			array( '/([^a-zA-Z])(Nine)(teen|ty)?([^a-zA-Z])/i', '${1}9$3$4' ),
			array( '/([^a-zA-Z])(Ten)([^a-zA-Z])/i', '${1}10$3' ),
			array( '/([^a-zA-Z])(Eleven)([^a-zA-Z])/i', '${1}11$3' ),
			array( '/([^a-zA-Z])(Twelve)([^a-zA-Z])/i', '${1}12$3' ),
			array( '/([^a-zA-Z])(Thirteen)([^a-zA-Z])/i', '${1}13$3' ),
			array( '/([^a-zA-Z])(Fifteen)([^a-zA-Z])/i', '${1}15$3' ),
			array( '/([^a-zA-Z])([0-9])teen([^a-zA-Z])/i', '${1}1$2$3' ),
			array( '/([^a-zA-Z])(Twenty)([^a-zA-Z])/i', '${1}20$3' ),
			array( '/([^a-zA-Z])(Thirty)([^a-zA-Z])/i', '${1}30$3' ),
			array( '/([^a-zA-Z])(Fifty)([^a-zA-Z])/i', '${1}50$3' ),
			array( '/([^a-zA-Z])([0-9])ty([^a-zA-Z])/i', '$1${2}0$3' ),
			'total'=>19,
		),
		array(
			array( '/([^a-zA-Z])(Zero)$/i', '${1}0' ),
			array( '/([^a-zA-Z])(One)$/i', '${1}1' ),
			array( '/([^a-zA-Z])(Two)$/i', '${1}2' ),
			array( '/([^a-zA-Z])(Three)$/i', '${1}3' ),
			array( '/([^a-zA-Z])(Four)$/i', '${1}4' ),
			array( '/([^a-zA-Z])(Five)$/i', '${1}5' ),
			array( '/([^a-zA-Z])(Six)(teen|ty)?$/i', '${1}6$3' ),
			array( '/([^a-zA-Z])(Seven)(teen|ty)?$/i', '${1}7$3' ),
			array( '/([^a-zA-Z])(Eigh)(t)(een|ty)?$/i', '${1}8$3$4' ),
			array( '/([^a-zA-Z])(Nine)(teen|ty)?$/i', '${1}9$3' ),
			array( '/([^a-zA-Z])(Ten)$/i', '${1}10' ),
			array( '/([^a-zA-Z])(Eleven)$/i', '${1}11' ),
			array( '/([^a-zA-Z])(Twelve)$/i', '${1}12' ),
			array( '/([^a-zA-Z])(Thirteen)$/i', '${1}13' ),
			array( '/([^a-zA-Z])(Fifteen)$/i', '${1}15' ),
			array( '/([^a-zA-Z])([0-9])teen$/i', '${1}1$2' ),
			array( '/([^a-zA-Z])(Twenty)$/i', '${1}20' ),
			array( '/([^a-zA-Z])(Thirty)$/i', '${1}30' ),
			array( '/([^a-zA-Z])(Fifty)$/i', '${1}50' ),
			array( '/([^a-zA-Z])([0-9])ty$/i', '$1${2}0' ),
			'total'=>19,
		),
		array(
			array( '/^([0-9])([^a-zA-Z0-9])/', '0$1$2' ),
			array( '/([^0-9])([0-9])([^0-9])/', '${1}0$2$3' ),
			array( '/([^a-zA-Z0-9])([0-9])$/', '${1}0$2' ),
			'total'=>3,
		),
		array(
			array( '/ I /i', ' 1 ' ),
			array( '/ II /i', ' 2 ' ),
			array( '/ III /i', ' 3 ' ),
			array( '/ IV /i', ' 4 ' ),
			array( '/ V /i', ' 5 ' ),
			array( '/ VI /i', ' 6 ' ),
			array( '/ VII /i', ' 7 ' ),
			array( '/ VIII /i', ' 8 ' ),
			array( '/ IX /i', ' 9 ' ),
			array( '/ X /i', ' 10 ' ),
			array( '/ XII /i', ' 12 ' ),
			array( '/ XIII /i', ' 13 ' ),
			array( '/ XIV /i', ' 14 ' ),
			array( '/ XV /i', ' 15 ' ),
			array( '/ XVI /i', ' 16 ' ),
			array( '/ XVII /i', ' 17 ' ),
			array( '/ XVIII /i', ' 18 ' ),
			array( '/ XIX /i', ' 19 ' ),
			array( '/ XX /i', ' 20 ' ),
			'total'=>18,
		),
		'total'=>6,
	);

?>
