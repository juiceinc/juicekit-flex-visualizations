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
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;

import flash.display.DisplayObject;
import flash.events.Event;

/**
 * Event fired in response to tooltip show, hide, or update events.
 * @see flare.vis.controls.TooltipControl
 */
public class TooltipEvent extends Event
{
  /** A tooltip show event. */
  public static const SHOW:String = "show";
  /** A tooltip hide event. */
  public static const HIDE:String = "hide";
  /** A tooltip update event. */
  public static const UPDATE:String = "update";

  private var _object:DisplayObject;
  private var _tooltip:DisplayObject;

  /** The displayed tooltip object. */
  public function get tooltip():DisplayObject {
    return _tooltip;
  }

  /** The moused-over interface object. */
  public function get object():DisplayObject {
    return _object;
  }

  /** The moused-over interface object, cast to a NodeSprite. */
  public function get node():NodeSprite {
    return _object as NodeSprite;
  }

  /** The moused-over interface object, cast to an EdgeSprite. */
  public function get edge():EdgeSprite {
    return _object as EdgeSprite;
  }

  /**
   * Creates a new TooltipEvent.
   * @param type the event type (SHOW,HIDE, or UPDATE)
   * @param item the DisplayObject that was moused over
   * @param tip the tooltip DisplayObject
   */
  public function TooltipEvent(type:String, item:DisplayObject, tip:DisplayObject)
  {
    super(type);
    _object = item;
    _tooltip = tip;
  }

  /** @inheritDoc */
  public override function clone():Event
  {
    return new TooltipEvent(type, _object, _tooltip);
  }

} // end of class TooltipEvent
}