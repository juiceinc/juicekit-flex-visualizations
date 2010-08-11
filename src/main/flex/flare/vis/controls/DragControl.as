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
import flare.vis.data.DataSprite;

import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * Interactive control for dragging items. A DragControl will enable
 * dragging of all Sprites in a container object by clicking and dragging
 * them.
 */
public class DragControl extends Control
{
  private var _cur:Sprite;
  private var _mx:Number, _my:Number;

  /** Indicates if drag should be followed at frame rate only.
   *  If false, drag events can be processed faster than the frame
   *  rate, however, this may pre-empt other processing. */
  public var trackAtFrameRate:Boolean = false;

  /** The active item currently being dragged. */
  public function get activeItem():Sprite {
    return _cur;
  }

  /**
   * Creates a new DragControl.
   * @param filter a Boolean-valued filter function determining which
   *  items should be draggable.
   */
  public function DragControl(filter:* = null) {
    this.filter = filter;
  }

  /** @inheritDoc */
  public override function attach(obj:InteractiveObject):void
  {
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
    var s:Sprite = event.target as Sprite;
    if (s == null) return; // exit if not a sprite

    if (_filter == null || _filter(s)) {
      _cur = s;
      _mx = _object.mouseX;
      _my = _object.mouseY;
      if (_cur is DataSprite) (_cur as DataSprite).fix();

      _cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
      _cur.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

      event.stopPropagation();
    }
  }

  private function onDrag(event:Event):void {
    var x:Number = _object.mouseX;
    if (x != _mx) {
      _cur.x += (x - _mx);
      _mx = x;
    }

    var y:Number = _object.mouseY;
    if (y != _my) {
      _cur.y += (y - _my);
      _my = y;
    }
  }

  private function onMouseUp(event:MouseEvent):void {
    if (_cur != null) {
      _cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      _cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);

      if (_cur is DataSprite) (_cur as DataSprite).unfix();
      event.stopPropagation();
    }
    _cur = null;
  }

} // end of class DragControl
}