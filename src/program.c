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


#include "program.h"

AlacastProgram *alacast_program_init(int argc, char **argv){
	GOptionContext *option_context=g_option_context_new(PACKAGE_NAME);
	GOptionEntry option_entries[]={
		{ G_OPTION_REMAINING, 0, 0, G_OPTION_ARG_FILENAME_ARRAY,
			&argv,
			"Special option that collects any remaining arguments for us" },
		{ NULL }
	};
	
	g_option_context_add_main_entries(option_context, option_entries, NULL);
	
	AlacastProgram *alacast_gnome_program=(AlacastProgram *)gnome_program_init(
						PACKAGE_NAME, PACKAGE_VERSION,
						LIBGNOME_MODULE,
						argc, argv,
						GNOME_PARAM_GOPTION_CONTEXT, option_context,
						GNOME_PARAM_NONE
	);
	
	return alacast_gnome_program;
}//alacast_program_init

void alacast_program_main(Alacast *alacast){
	gui_main(alacast->gui);
}//alacast_program_mainsst


void alacast_program_main_quit(Alacast *alacast){
	/* methods to clean-up anything that uses gtk/gnome */
	gui_main_quit(alacast->gui);
}//alacast_gtk_quit

/* This method is automatically called when the program exits with Alacast using gnome_program_init */
void alacast_program_deinit(Alacast *alacast){
	/* methods to clean-up anything that uses gtk/gnome */
	alacast_program_main_quit(alacast);
	/* final clean-up */
}//alacast_program_deinit

void alacast_program_finalize(Alacast *alacast){
	/* methods to clean-up anything that uses gtk/gnome */
	alacast_program_deinit(alacast);
	/* final clean-up */
}//alacast_program_finalize

