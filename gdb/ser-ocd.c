/* Remote serial interface for Macraigor Systems implementation of
	On-Chip Debugging using serial target box or serial wiggler

   Copyright 1994, 1997 Free Software Foundation, Inc.

   This file is part of GDB.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

#include "defs.h"
#include "serial.h"

static int ser_ocd_open PARAMS ((serial_t scb, const char *name));
static void ser_ocd_raw PARAMS ((serial_t scb));
static int ser_ocd_readchar PARAMS ((serial_t scb, int timeout));
static int ser_ocd_setbaudrate PARAMS ((serial_t scb, int rate));
static int ser_ocd_write PARAMS ((serial_t scb, const char *str, int len));
static void ser_ocd_close PARAMS ((serial_t scb));
static serial_ttystate ser_ocd_get_tty_state PARAMS ((serial_t scb));
static int ser_ocd_set_tty_state PARAMS ((serial_t scb, serial_ttystate state));

static int
ocd_open (scb, name)
     serial_t scb;
     const char *name;
{
  return 0;
}

static int
ocd_noop (scb)
     serial_t scb;
{
  return 0;
}

static void
ocd_raw (scb)
     serial_t scb;
{
  /* Always in raw mode */
}

/* We need a buffer to store responses from the Wigglers.dll */
char * from_wigglers_buffer;
char * bptr;			/* curr spot in buffer */

static void
ocd_readremote ()
{
}

static int
ocd_readchar (scb, timeout)
     serial_t scb;
     int timeout;
{

}

struct ocd_ttystate {
  int dummy;
};

/* ocd_{get set}_tty_state() are both dummys to fill out the function
   vector.  Someday, they may do something real... */

static serial_ttystate
ocd_get_tty_state (scb)
     serial_t scb;
{
  struct ocd_ttystate *state;

  state = (struct ocd_ttystate *) xmalloc (sizeof *state);

  return (serial_ttystate) state;
}

static int
ocd_set_tty_state (scb, ttystate)
     serial_t scb;
     serial_ttystate ttystate;
{
  return 0;
}

static int
ocd_noflush_set_tty_state (scb, new_ttystate, old_ttystate)
     serial_t scb;
     serial_ttystate new_ttystate;
     serial_ttystate old_ttystate;
{
  return 0;
}

static void
ocd_print_tty_state (scb, ttystate)
     serial_t scb;
     serial_ttystate ttystate;
{
  /* Nothing to print.  */
  return;
}

static int
ocd_setbaudrate (scb, rate)
     serial_t scb;
     int rate;
{
  return 0;
}

static int
ocd_write (scb, str, len)
     serial_t scb;
     const char *str;
     int len;
{
  char c;

  ocd_readremote();

#ifdef __CYGWIN32__ 
  /* send packet to Wigglers.dll and store response so we can give it to
	remote-wiggler.c when get_packet is run */
  do_command (str, from_wigglers_buffer);
#endif

  return 0;
}

static void
ocd_close (scb)
     serial_t scb;
{
  ocd_close (0);
}

static struct serial_ops ocd_ops =
{
  "ocd",
  0,
  ocd_open,
  ocd_close,
  ocd_readchar,
  ocd_write,
  ocd_noop,		/* flush output */
  ocd_noop,		/* flush input */
  ocd_noop,		/* send break -- currently used only for nindy */
  ocd_raw,
  ocd_get_tty_state,
  ocd_set_tty_state,
  ocd_print_tty_state,
  ocd_noflush_set_tty_state,
  ocd_setbaudrate,
};

void
_initialize_ser_ocd_bdm ()
{
  serial_add_interface (&ocd_ops);
}
