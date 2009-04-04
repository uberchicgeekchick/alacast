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

/**********************************************************************
 *        System & library headers, eg #include <gdk/gdkkeysyms.h>    *
 **********************************************************************/
#ifndef __DEBUG_H__
#define __DEBUG_H__

#include <stdarg.h>
#include <strings.h>
#include <glib.h>
#include <glib/gprintf.h>
#include <glib.h>


#include "config.h"


/*********************************************************************
 *        Objects, structures, and etc typedefs                      *
 *********************************************************************/
G_BEGIN_DECLS

typedef struct {
	gboolean debug_inited=FALSE;
	gboolean debug_enabled=FALSE;
	gboolean debug_all=FALSE;
	gchar **debug_envp;
} AlacastDebug;


/********************************************************
 *          My art, code, & programming.                *
 ********************************************************/
#ifndef GNOME_ENABLE_DEBUG
#	define	debug(...)
#elif defined(DISABLE_DEBUG)
#	define	debug(...)
#elif defined(G_HAVE_ISO_VARARGS)
#	define	debug(...)	debug_printf(__VA_ARGS__)
#elif defined(G_HAVE_GNUC_VARARGS)
#	define	debug(fmt...)	debug_printf(fmt)
#else
#	define	debug	debug_printf
#endif



/********************************************************
 *          Global method  & function prototypes        *
 ********************************************************/
AlacastDebug *debug_init(const char ***envp);
void debug_printf( const gchar *msg, ... );
void debug_deinit(void);


G_END_DECLS

#endif /* __DEBUG_H__ */

