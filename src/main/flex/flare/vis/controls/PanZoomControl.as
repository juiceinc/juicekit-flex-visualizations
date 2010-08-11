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

import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;

import org.juicekit.util.Displays;

/**
 * Interactive control for panning and zooming a "camera". Any sprite can
 * be treated as a camera onto its drawing content and display list
 * children. The PanZoomControl allows you to manipulate a sprite's
 * transformation matrix (the <code>transform.matrix</code> property) to
 * simulate camera movements such as panning and zooming. To pan and
 * zoom over a collection of objects, simply add a PanZoomControl for
 * the sprite holding the collection.
 *
 * <pre>
 * var s:Sprite; // a sprite holding a collection of items
 * new PanZoomControl().attach(s); // attach pan and zoom com.ingenix.trendview.controls to the sprite
 * </pre>
 * <p>Once a PanZoomControl has been created, panning is performed by
 * clicking and dragging. Zooming is performed either by scrolling the
 * mouse wheel or by clicking and dragging vertically while the control key
 * is pressed.</p>
 *
 * <p>By default, the PanZoomControl attaches itself to the
 * <code>stage</code> to listen for mouse events. This works fine if there
 * is only one collection of objects in the display list, but can cause
 * trouble if you want to have multiple collections that can be separately
 * panned and zoomed. The PanZoomControl constructor takes a second
 * argument that specifies a "hit area", a shape in the display list that
 * should be used to listen to the mouse events for panning and zooming.
 * For example, this could be a background sprite behind the zoomable
 * content, to which the "camera" sprite could be added. One can then set
 * the <code>scrollRect</code> property to add clipping bounds to the
 * panning and zooming region.</p>
 */
public class PanZoomControl extends Control
{
  private var px:Number, py:Number;
  private var dx:Number, dy:Number;
  private var mx:Number, my:Number;
  private var _drag:Boolean = false;

  private var _hit:InteractiveObject;
  private var _stage:Stage;

  /** The active hit area over which pan/zoom interactions can be performed. */
  public function get hitArea():InteractiveObject {
    return _hit;
  }

  public function set hitArea(hitArea:InteractiveObject):void {
    if (_hit != null) onRemove();
    _hit = hitArea;
    if (_object && _object.stage != null) onAdd();
  }

  /**
   * Creates a new PanZoomControl.
   * @param hitArea a display object to use as the hit area for mouse
   *  events. For example, this could be a background region over which
   *  the panning and zooming should be done. If this argument is null,
   *  the stage will be used.
   */
  public function PanZoomControl(hitArea:InteractiveObject = null):void
  {
    _hit = hitArea;
  }

  /** @inheritDoc */
  public override function attach(obj:InteractiveObject):void
  {
    super.attach(obj);
    if (obj != null) {
      obj.addEventListener(Event.ADDED_TO_STAGE, onAdd);
      obj.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
      if (obj.stage != null) onAdd();
    }
  }

  /** @inheritDoc */
  public override function detach():InteractiveObject
  {
    onRemove();
    _object.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
    _object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
    return super.detach();
  }

  private function onAdd(evt:Event = null):void
  {
    _stage = _object.stage;
    if (_hit == null) {
      _hit = _stage;
    }
    _hit.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    _hit.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
  }

  private function onRemove(evt:Event = null):void
  {
    _hit.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    _hit.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
  }

  private function onMouseDown(event:MouseEvent):void
  {
    if (_stage == null) return;
    if (_hit == _object && event.target != _hit) return;

    _stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

    px = mx = event.stageX;
    py = my = event.stageY;
    _drag = true;
  }

  private function onMouseMove(event:MouseEvent):void
  {
    if (!_drag) return;

    var x:Number = event.stageX;
    var y:Number = event.stageY;

    if (!event.ctrlKey) {
      dx = dy = NaN;
      Displays.panBy(_object, x - mx, y - my);
    } else {
      if (isNaN(dx)) {
        dx = event.stageX;
        dy = event.stageY;
      }
      var dz:Number = 1 + (y - my) / 100;
      Displays.zoomBy(_object, dz, dx, dy);
    }
    mx = x;
    my = y;
  }

  private function onMouseUp(event:MouseEvent):void
  {
    dx = dy = NaN;
    _drag = false;
    _stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
  }

  private function onMouseWheel(event:MouseEvent):void
  {
    var dw:Number = 1.1 * event.delta;
    var dz:Number = dw < 0 ? 1 / Math.abs(dw) : dw;
    Displays.zoomBy(_object, dz);
  }

} // end of class PanZoomControl
}