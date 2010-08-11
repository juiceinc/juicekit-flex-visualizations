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

package flare.vis.controls
{
import flare.vis.events.SelectionEvent;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

[Event(name="select",   type="flare.vis.events.SelectionEvent")]
[Event(name="deselect", type="flare.vis.events.SelectionEvent")]

/**
 * Interactive control for responding to mouse clicks events. Select event
 * listeners can be added to respond to the mouse clicks. This control
 * also allows the number of mouse-clicks (single, double, triple, etc) and
 * maximum delay time between clicks to be configured.
 * @see flare.vis.events.SelectionEvent
 */
public class ClickControl extends Control
{
  private var _timer:Timer;
  private var _cur:DisplayObject;
  private var _clicks:uint = 0;
  private var _clear:Boolean = false;
  private var _evt:MouseEvent = null;

  /** The number of clicks needed to trigger a click event. Setting this
   *  value to zero effectively disables the click control. */
  public var numClicks:uint;

  /** The maximum allowed delay (in milliseconds) between clicks.
   *  The delay determines the maximum time interval between a
   *  mouse up event and a subsequent mouse down event. */
  public function get clickDelay():Number {
    return _timer.delay;
  }

  public function set clickDelay(d:Number):void {
    _timer.delay = d;
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new ClickControl.
   * @param filter a Boolean-valued filter function indicating which
   *  items should trigger hover processing
   * @param numClicks the number of clicks
   * @param onClick an optional SelectionEvent listener for click events
   */
  public function ClickControl(filter:* = null, numClicks:uint = 1,
                               onClick:Function = null, onClear:Function = null)
  {
    this.filter = filter;
    this.numClicks = numClicks;
    _timer = new Timer(150);
    _timer.addEventListener(TimerEvent.TIMER, onTimer);
    if (onClick != null)
      addEventListener(SelectionEvent.SELECT, onClick);
    if (onClear != null)
      addEventListener(SelectionEvent.DESELECT, onClear);
  }

  /** @inheritDoc */
  public override function attach(obj:InteractiveObject):void
  {
    if (obj == null) {
      detach();
      return;
    }
    super.attach(obj);
    if (obj != null) {
      obj.addEventListener(MouseEvent.CLICK, onClick);
      obj.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
    }
  }

  /** @inheritDoc */
  public override function detach():InteractiveObject
  {
    if (_object != null) {
      _object.removeEventListener(MouseEvent.CLICK, onClick);
      _object.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
    }
    return super.detach();
  }

  // -----------------------------------------------------

  private function onDown(evt:MouseEvent):void
  {
    _timer.stop();
  }

  private function onClick(evt:MouseEvent):void
  {
    var n:DisplayObject = evt.target as DisplayObject;
    if (n == null || (_filter != null && !_filter(n))) {
      _clicks++;
      _clear = true;
    } else if (_cur != n) {
      _clear = false;
      _clicks = 1;
      _cur = n;
    } else {
      _clicks++;
    }
    _evt = evt;
    _timer.start();
  }

  private function onTimer(evt:Event = null):void
  {
    if (_clicks == numClicks && _cur) {
      var type:String = _clear ? SelectionEvent.DESELECT
              : SelectionEvent.SELECT;
      if (hasEventListener(type))
        dispatchEvent(new SelectionEvent(type, _cur, _evt));
      if (_clear) _cur = null;
    }
    _timer.stop();
    _clicks = 0;
    _evt = null;
    _clear = false;
  }

} // end of class ClickControl
}