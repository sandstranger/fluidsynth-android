/* FluidSynth - A Software Synthesizer
 *
 * Copyright (C) 2003  Peter Hanappe and others.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA
 */

#include "fluid_adriver.h"
#include "fluid_settings.h"

void fluid_audio_driver_settings(fluid_settings_t* settings)
{
  /* Register audio settings */
  fluid_settings_register_str(settings, "audio.sample-format", "16bits", 0);
  fluid_settings_add_option(settings, "audio.sample-format", "16bits");
  fluid_settings_add_option(settings, "audio.sample-format", "float");

  fluid_settings_register_int(settings, "audio.period-size", 64, 64, 8192, 0);
  fluid_settings_register_int(settings, "audio.periods", 16, 2, 64, 0);

  fluid_settings_register_int (settings, "audio.realtime-prio",
                               FLUID_DEFAULT_AUDIO_RT_PRIO, 0, 99, 0);

  fluid_settings_register_str(settings, "audio.driver", "", 0);  
}