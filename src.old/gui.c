/*
 * Alacast is an online media brewser for GNOME.
 * Alacast brings the best online media to one's desktop
 * with a beautiful, fun, & intuitive interface.
 *
 * Copyright (c) 2006-2009 Kaity G. B. <uberChick@uberChicGeekChick.Com>
 * For more information or to find the latest release, visit our
 * website at: http://uberChicGeekChick.Com/?projects=connectED
 *
 * Writen by an uberChick, other uberChicks please meet me & others @:
 * 	http://uberChicks.Net/
 *
 * I'm also disabled. I live with a progressive neuro-muscular disease.
 * DYT1+ Early-Onset Generalized Dystonia, a type of Generalized Dystonia.
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

#include	"gui.h"


static void gui_setup_pigment(AlacastGUI *gui);//setup_piment
static void gui_setup_clutter(AlacastGUI *gui);//setup_piment
static void gui_setup_gtk(AlacastGUI *gui);//setup_piment
static void gui_setup_cli(AlacastGUI *gui);//setup_cli

static void gui_bail(void);


AlacastGUI *gui_init(int *argc, char ***argv){
	AlacastGUI *gui=g_new0(AlacastGUI, 1);
	gui->prefs=g_new0(GUIPrefs, 1);
	
	if( (gui_pigment_init(argc, argv)) )
		gui_setup_pigment(gui);
	else if( (gui->clutter_init_error=gui_clutter_init(argc, argv)) )
		gui_setup_clutter(gui);
	else if( (gui_gtk_init(argc, argv)) )
		gui_setup_gtk(gui);
	else
		gui_setup_cli(gui);

	if(!(gui->prefs->toolkit)){
		gui_bail();
		return NULL;
	}
	
	return gui;
}//gui_init

static void gui_setup_pigment(AlacastGUI *gui){
	gui->prefs->toolkit=GUI_PIGMENT;
}//gui_setup_piment

static void gui_setup_clutter(AlacastGUI *gui){
	gui->prefs->toolkit=GUI_CLUTTER;
}//gui_setup_piment

static void gui_setup_gtk(AlacastGUI *gui){
	gui->prefs->toolkit=GUI_GTK;
}//gui_setup_piment

static void gui_setup_cli(AlacastGUI *gui){
	gui->prefs->toolkit=GUI_CLI;
}//gui_setup_cli

static void gui_bail(void){
	g_error("*FATAL ERROR*: %s was unable to initalize any graphical interface and cannot continue.\n", PACKAGE_NAME);
}//gui_bail



void gui_main(AlacastGUI *gui){
	switch(gui->prefs->toolkit){
		case GUI_PIGMENT:
			gui_pigment_main();
			break;
		case GUI_CLUTTER:
			gui_clutter_main();
			break;
		case GUI_GTK:
			gui_gtk_main();
			break;
		case GUI_CLI: default:
			gui_bail();
			break;
	}//switch
}//gui_main


void gui_main_quit(AlacastGUI *gui){
	switch(gui->prefs->toolkit){
		case GUI_PIGMENT:
			gui_pigment_main_quit();
			break;
		case GUI_GTK:
			gui_gtk_main_quit();
			break;
		case GUI_CLUTTER:
			gui_clutter_main_quit();
		case GUI_CLI:
		default:
			break;
	}//switch
}//gui_finalize



void gui_deinit(AlacastGUI *gui){
	switch(gui->prefs->toolkit){
		case GUI_PIGMENT:
			gui_pigment_deinit();
			break;
		case GUI_GTK:
			gui_gtk_deinit();
			break;
		case GUI_CLUTTER:
			gui_clutter_deinit();
		case GUI_CLI:
		default:
			break;
	}//switch
	
	g_free(gui->prefs);
	g_free(gui);
}//gui_deinit

