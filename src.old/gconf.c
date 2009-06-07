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

/********************************************************
 *        Project headers.                              *
 ********************************************************/
#include "config.h"
#include "gobject.h"

/********************************************************
 *         typedefs: objects, structures, and etc       *
 ********************************************************/
/* to impliment a private gobject:
 * 	uncomment the next 10-13+ lines
 *	& my last line in 'gconf_class_init'
 *
typedef struct {
	gchar		*gtkbuilder_ui_file;
	GtkWindow	*dialog;
	GtkButton	*yes;
	GtkButton	*no;
} GConfPriv;

#define GET_PRIV(obj) (G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_OF_GCONF, GConfPriv))
*/
static GConf *gconf=NULL;

G_DEFINE_TYPE(GConf, gconf, G_TYPE_OBJECT);


/********************************************************
 *          static method & function prototypes               *
 ********************************************************/
static void gconf_class_init( GConfClass *klass );
static void gconf_init( GConf *new_object );
static void gconf_finalize( GObject *object );



/********************************************************
 *          My art & programming.                       *
 ********************************************************/
GConf *gconf_class_new(void){
	return g_object_new(TYPE_OF_GCONF, NULL);
}//gconf_class_new


static void gconf_class_init( GConfClass *klass ){
	GObjectClass *gconf=G_OBJECT_CLASS(klass);
	gconf->finalize=new_object_finalize;
	//g_type_class_add_private(gconf, sizeof(GConfPriv));
}//gconf_class_init

static void gconf_init(GConf *gconf){
	gconf=gconf;
	g_signal_connect(gconf, "size_allocate", G_CALLBACK(gconf_resize), gconf);
	g_signal_connect(gconf, "activated", G_CALLBACK(gconf_clicked), gconf);
}//gconf_init

static void gconf_create( GtkWindow *parent ){
	gconf=g_new0(GConf, 1);
	gconf->gtkbuilder_ui_file=g_strdup_printf( "%sgconf-object.ui", PREFIX );
}//gconf_create

void gconf_show( GtkWindow *parent ){
	if(!gconf) gconf_create( parent );
	
	gtk_widget_show( gconf->window );
}//gconf_show

static void gconf_finalize( GObject *object ){
	GConfPrivate *private=GET_PRIV(object);
	G_OBJECT_CLASS(private_parent_class)->finalize(object);
}//gconf_finalize


