/* This file is part of http://connectED/, a GNOME2 PHP Editor.

   Copyright (C) 2008 Kaity G. B.
 uberChick@uberChicGeekChick.Com

   For more information or to find the latest release, visit our
   website at http://uberchicgeekchick.com/

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307, USA.

   The GNU General Public License is contained in the file COPYING.*/


#ifndef connectED_IPC_H
#define connectED_IPC_H

#include <glib.h>
#include "init.h"
#include "main_window.h"

G_BEGIN_DECLS


gboolean poke_existing_instance (int argc, char **argv);
void     shutdown_ipc (void);


G_END_DECLS

#endif
