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
import flash.events.MouseEvent;

/**
 * Event fired in response to interactive selection events.
 */
public class SelectionEvent extends DataEvent
{
  /** A selection event. */
  public static const SELECT:String = "select";
  /** A deselection event. */
  public static const DESELECT:String = "deselect";

  /** Indicates whether the Alt key is active (<code>true</code>)
   *  or inactive (<code>false</code>). */
  public var altKey:Boolean;
  /** Indicates whether the Control key is active (<code>true</code>)
   *  or inactive (<code>false</code>). On Macintosh computers, you must
   *  use this property to represent the Command key. */
  public var ctrlKey:Boolean;
  /** Indicates whether the Shift key is active (<code>true</code>)
   *  or inactive (<code>false</code>). */
  public var shiftKey:Boolean;

  /** The event that triggered this event, if any. */
  public function get cause():MouseEvent {
    return _cause;
  }

  private var _cause:MouseEvent;

  /**
   * Creates a new SelectionEvent.
   * @param type the event type (SELECT or DESELECT)
   * @param item the display object(s) that were selected or deselected
   * @param e (optional) the MouseEvent that triggered the selection
   */
  public function SelectionEvent(type:String, items:*, e:MouseEvent = null)
  {
    super(type, items);
    if (e != null) {
      _cause = e;
      altKey = e.altKey;
      ctrlKey = e.ctrlKey;
      shiftKey = e.shiftKey;
    }
  }

  /** @inheritDoc */
  public override function clone():Event
  {
    var se:SelectionEvent = new SelectionEvent(type,
            _items ? _items : _item, _cause);
    se.altKey = altKey;
    se.ctrlKey = ctrlKey;
    se.shiftKey = shiftKey;
    return se;
  }

} // end of class SelectionEvent
}