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
import flare.vis.Visualization;
import flare.vis.data.NodeSprite;

import flash.display.InteractiveObject;
import flash.events.MouseEvent;

/**
 * Interactive control for expaning and collapsing graph or tree nodes
 * by clicking them. This control will only work when applied to a
 * Visualization instance.
 */
public class ExpandControl extends Control
{
  private var _cur:NodeSprite;

  /** Update function invoked after expanding or collapsing an item.
   *  By default, invokes the <code>update</code> method on the
   *  visualization with a 1-second transitioner. */
  public var update:Function = function():void {
    var vis:Visualization = _object as Visualization;
    if (vis) vis.update(1).play();
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new ExpandControl.
   * @param filter a Boolean-valued filter function for determining which
   *  item this control will expand or collapse
   * @param update function invokde after expanding or collapsing an
   *  item.
   */
  public function ExpandControl(filter:* = null, update:Function = null)
  {
    this.filter = filter;
    if (update != null) this.update = update;
  }

  /** @inheritDoc */
  public override function attach(obj:InteractiveObject):void
  {
    if (obj == null) {
      detach();
      return;
    }
    if (!(obj is Visualization)) {
      throw new Error("This control can only be attached to a Visualization");
    }
    super.attach(obj);
    obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  /** @inheritDoc */
  public override function detach():InteractiveObject
  {
    if (_object != null) {
      _object.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    return super.detach();
  }

  private function onMouseDown(event:MouseEvent):void {
    var s:NodeSprite = event.target as NodeSprite;
    if (s == null) return; // exit if not a NodeSprite

    if (_filter == null || _filter(s)) {
      _cur = s;
      _cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
      _cur.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }
    event.stopPropagation();
  }

  private function onDrag(event:MouseEvent):void {
    _cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    _cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
    _cur = null;
  }

  private function onMouseUp(event:MouseEvent):void {
    _cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    _cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
    _cur.expanded = !_cur.expanded;
    _cur = null;
    event.stopPropagation();

    update();
  }

} // end of class ExpandControl
}