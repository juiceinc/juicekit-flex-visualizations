/*
 * Copyright (c) 2007-2010 Regents of the University of California.
 *   All rights reserved.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 *   3.  Neither the name of the University nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *   ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 *   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *   SUCH DAMAGE.
 */

package flare.vis.events
{

import flash.events.Event;

import org.juicekit.animate.Transitioner;

/**
 * Event fired in response to visualization updates.
 */
public class VisualizationEvent extends Event
{
  /** A visualization update event. */
  public static const UPDATE:String = "update";

  private var _trans:Transitioner;
  private var _params:Array;

  /** Transitioner used in the visualization update. */
  public function get transitioner():Transitioner {
    return _trans;
  }

  /** Parameter provided to the visualization update. If not null,
   *  this string indicates the named operators that were run. */
  public function get params():Array {
    return _params;
  }

  /**
   * Creates a new VisualizationEvent.
   * @param type the event type
   * @param trans the Transitioner used in the visualization update
   */
  public function VisualizationEvent(type:String,
                                     trans:Transitioner = null, params:Array = null)
  {
    super(type);
    _params = params;
    _trans = trans == null ? Transitioner.DEFAULT : trans;
  }

} // end of class VisualizationEvent
}