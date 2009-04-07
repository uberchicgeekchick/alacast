/* -*- Mode: C; shift-width: 8; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
 * Greet-Tweet-Know is:
 * 	Copyright (c) 2006-2009 Kaity G. B. <uberChick@uberChicGeekChick.Com>
 * 	Released under the terms of the RPL
 *
 * For more information or to find the latest release, visit our
 * website at: http://uberChicGeekChick.Com/?projects=Greet-Tweet-Know
 *
 * Writen by an uberChick, other uberChicks please meet me & others @:
 * 	http://uberChicks.Net/
 *
 * I'm also disabled. I live with a progressive neuro-muscular disease.
 * DYT1+ Early-Onset Generalized Dystonia, a type of Generalized Dystonia.
 * 	http://Dystonia-DREAMS.Org/
 *
 *
 *
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
 * The User-Visible Attribution Notice below, when provided, must appear in each
 * user-visible display as defined in Section 6.4 (d):
 * 
 * Initial art work including: design, logic, programming, and graphics are
 * Copyright (C) 2009 Kaity G. B. and released under the RPL where sapplicable.
 * All materials not covered under the terms of the RPL are all still
 * Copyright (C) 2009 Kaity G. B. and released under the terms of the
 * Creative Commons Non-Comercial, Attribution, Share-A-Like version 3.0 US license.
 * 
 * Any & all data stored by this Software created, generated and/or uploaded by any User
 * and any data gathered by the Software that connects back to the User.  All data stored
 * by this Software is Copyright (C) of the User the data is connected to.
 * Users may lisences their data under the terms of an OSI approved or Creative Commons
 * license.  Users must be allowed to select their choice of license for each piece of data
 * on an individual bases and cannot be blanketly applied to all of the Users.  The User may
 * select a default license for their data.  All of the Software's data pertaining to each
 * User must be fully accessible, exportable, and deletable to that User.
 */

/********************************************************
 *        Project headers, eg #include "config.h"       *
 ********************************************************/
#include "config.h"
#include "debug.h"



/********************************************************
 *          Variable definitions.                       *
 ********************************************************/


/********************************************************
 *          Static method & function prototypes         *
 ********************************************************/
static gboolean debug_init_check( AlacastDebug *debug, const char *envp );



/********************************************************
 *          My art, code, & programming.                *
 ********************************************************/
AlacastDebug *debug_init(const char **envp){
	AlacastDebug *debug=g_new(AlacastDebug, 1);
	
	debug->enabled=FALSE;
	for(int i=0; envp && envp[i]; i++)
		if(!(strcasecmp("ALACAST_DEBUG", envp[i])))
			debug->enabled=debug_init_check( debug, envp[i] );
	return debug;
}//debug_init

static gboolean debug_init_check( AlacastDebug *debug, const char *envp ){
	debug->envp=g_strsplit_set(envp, ":", 0);

	for(int i=0; debug->envp[i] && debug->envp[i]; )
		if(!(strcasecmp( "all", debug->envp[i++] ))) {
			debug->all=TRUE;
			break;
		}
	
	return TRUE;
}//debug_init_check

void debug_main( AlacastDebug *debug, const gchar *msg, ...){
	g_return_if_fail(msg != NULL);

	for(int i=0; debug->envp && debug->envp[i]; i++) {
		if( debug->all || (strcasecmp(__FILE__, debug->envp[i])) ) {
			g_printf( "%s: ", __FILE__ );

			va_list args;
			va_start(args, msg);
			g_vprintf(msg, args);
			va_end(args);
			
			g_print("\n");
			break;
		}
	}
}

void debug_deinit( AlacastDebug *debug ){
	g_strfreev( debug->envp );
}//debug_deinit



void debug_main_quit( AlacastDebug *debug ){
	debug_deinit( debug );
	g_free(debug);
}//debug_deinit



/********************************************************
 *                       eof                            *
 ********************************************************/