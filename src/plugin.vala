/*
 * plugin.vala
 * Copyright (C) Kaity G. B. 2009 <uberChick@uberChicGeekChick.Com>
 * 
 */

using GLib;
using Anjuta;

public class alacast_windo : Plugin {

	static string UI_FILE;

	static string GLADE_FILE;

	static construct {
		// workaround for bug 538166, should be const
		UI_FILE = Config.ANJUTA_DATA_DIR + "/ui/alacast.ui";
		GLADE_FILE = Config.ANJUTA_DATA_DIR + "/glade/alacast.glade";

	}


	private int uiid = 0;
	private Gtk.ActionGroup action_group;

	private Gtk.Widget widget = null;


	const Gtk.ActionEntry[] actions_file = {
		{
			"ActionFileSample",          /* Action name */
			Gtk.STOCK_NEW,               /* Stock icon, if any */
			N_("_Sample action"),        /* Display label */
			null,                        /* short-cut */
			N_("Sample action"),         /* Tooltip */
			on_sample_action_activate    /* action callback */
		}
	};

	public void on_sample_action_activate (Gtk.Action action) {

		/* Query for object implementing IAnjutaDocumentManager interface */
		var docman = (IAnjuta.DocumentManager) shell.get_object ("IAnjutaDocumentManager");
		var editor = (IAnjuta.Editor) docman.get_current_document ();

		/* Do whatever with plugin */

	}

	public override bool activate () {

		//DEBUG_PRINT ("alacast_windo: Activating alacast_windo plugin ...");

		/* Add all UI actions and merge UI */
		var ui = shell.get_ui ();
		action_group = ui.add_action_group_entries ("ActionGroupFilealacast",
													_("Sample file operations"),
													actions_file,
													Config.GETTEXT_PACKAGE, true,
													this);
		uiid = ui.merge (UI_FILE);

		/* Add plugin widgets to Shell */
		var gxml = new Glade.XML (GLADE_FILE, "top_widget", null);
		widget = gxml.get_widget ("top_widget");
		shell.add_widget (widget, "alacast_windoWidget",
						  _("alacast_windo widget"), null,
						  ShellPlacement.BOTTOM);

		return true;
	}

	public override bool deactivate () {
		//DEBUG_PRINT ("alacast_windo: Dectivating alacast_windo plugin ...");

		shell.remove_widget (widget);

		var ui = shell.get_ui ();
		ui.remove_action_group (action_group);
		ui.unmerge (uiid);
	
		return true;
	}
}

[ModuleInit]
public GLib.Type anjuta_glue_register_components (GLib.TypeModule module) {
    return typeof (alacast_windo);
}
