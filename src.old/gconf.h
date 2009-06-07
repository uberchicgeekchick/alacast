/* -*- Mode: C; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
 * Copyright (c) 2006-2009 Kaity G. B. <uberChick@uberChicGeekChick.Com>
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
 * Unless explicitly acquired and licensed from Licensor under another
 * license, the contents of gconf file are subject to the Reciprocal Public
 * License ("RPL") Version 1.5, or subsequent versions as allowed by the RPL,
 * and You may not copy or use gconf file in either source code or executable
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
 * Any & all data stored by gconf Software created, generated and/or uploaded by any User
 * and any data gathered by the Software that connects back to the User.  All data stored
 * by gconf Software is Copyright (C) of the User the data is connected to.
 * Users may lisences their data under the terms of an OSI approved or Creative Commons
 * license.  Users must be allowed to select their choice of license for each piece of data
 * on an individual bases and cannot be blanketly applied to all of the Users.  The User may
 * select a default license for their data.  All of the Software's data pertaining to each
 * User must be fully accessible, exportable, and deletable to that User.
 */

#ifndef __HEADER_H__
#define __HEADER_H__

/********************************************************
 *        System & library headers.                     *
 ********************************************************/
#include <strings.h>
#include <glib.h>
#include <glib/gi18n.h>
#include <libgnome/libgnome.h>

#include "config.h"

G_BEGIN_DECLS

/********************************************************
 *         typedefs: objects, structures, and etc.      *
 ********************************************************/
typedef struct {
	GtkObject	parent;
	gchar		*gtkbuilder_ui_file;
	GtkWindow	*dialog;
	GtkButton	*yes;
	GtkButton	*no;
} GConf;

typedef struct {
	GtkWidgetClass	parent_class;
} GConfClass;

extern GConf *gconf;

/********************************************************
 *          My art, code, & programming.                *
 ********************************************************/
#define	TYPE_OF_GCONF		(gconf_get_type())
#define	GCONF(o)			(G_TYPE_CHECK_INSTANCE_CAST( (o), TYPE_OF_GCONF, GConf ))
#define	GCONF_CLASS(k)		(G_TYPE_CHECK_CLASS_CAST( (k), TYPE_OF_GCONF, GConfClass ))
#define	IS_GCONF(o)		(G_TYPE_CHECK_INSTANCE_TYPE( (o), TYPE_OF_GCONF) )
#define	IS_GCONF_CLASS(k)		(G_TYPE_CHECK_CLASS_TYPE( (k), TYPE_OF_GCONF) )
#define	GCONF_GET_CLASS(o)	(G_TYPE_INSTANCE_GET_CLASS( (o), TYPE_OF_GCONF, GConfClass) )



/********************************************************
 *          Objects and handlers prototypes.            *
 ********************************************************/
GType gconf_get_type( void ) G_GNUC_CONST;// Macro
GConf *gconf_new( void );
void gconf_show( GtkWindow *parent );

G_END_DECLS

#endif


