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

package flare.vis.operator.layout
{
import flare.vis.data.Data;
import flare.vis.data.DataList;
import flare.vis.data.DataSprite;

import flash.geom.Point;
import flash.geom.Rectangle;

import org.juicekit.util.Property;
import org.juicekit.util.Shapes;

/**
 * Layout that places wedges for pie and donut charts. In addition to
 * the layout, this operator updates each node to have a "wedge" shape.
 */
public class PieLayout extends Layout
{
  private var _field:Property;

  /** The source property determining wedge size. */
  public function get source():String {
    return _field.name;
  }

  public function set source(f:String):void {
    _field = Property.$(f);
  }

  /** The data group to layout. */
  public var group:String = Data.NODES;

  /** The radius of the pie/donut chart. If this value is not a number
   *  (NaN) the radius will be determined from the layout bounds. */
  public var radius:Number = NaN;
  /** The width of wedges, negative for a full pie slice. */
  public var width:Number = -1;
  /** The initial angle for the pie layout (in radians). */
  public var startAngle:Number = Math.PI / 2;
  /** The total angular size of the layout (in radians, default 2 pi). */
  public var angleWidth:Number = 2 * Math.PI;

  // --------------------------------------------------------------------

  /**
   * Creates a new PieLayout
   * @param field the source data field for determining wedge size
   * @param width the radial width of wedges, negative for full slices
   */
  public function PieLayout(field:String = null, width:Number = -1,
                            group:String = Data.NODES)
  {
    layoutType = POLAR;
    this.group = group;
    this.width = width;
    _field = (field == null) ? null : new Property(field);
  }

  /** @inheritDoc */
  protected override function layout():void
  {
    var b:Rectangle = layoutBounds;
    var r:Number = isNaN(radius) ? Math.min(b.width, b.height) / 2 : radius;
    var a:Number = startAngle, aw:Number;
    var list:DataList = visualization.data.group(group);
    var sum:Number = list.stats(_field.name).sum;
    var anchor:Point = layoutAnchor;

    list.visit(function(d:DataSprite):void {
      var aw:Number = -angleWidth * (_field.getValue(d) / sum);
      var rh:Number = (width < 0 ? 0 : width) * r;
      var o:Object = _t.$(d);

      d.origin = anchor;

      //o.angle = a + aw/2;  // angular mid-point
      //o.radius = (r+rh)/2; // radial mid-point
      o.x = 0;
      o.y = 0;

      o.u = a;  // starting angle
      o.w = aw; // angle width
      o.h = r;  // outer radius
      o.v = rh; // inner radius
      o.shape = Shapes.WEDGE;

      a += aw;
    });
  }

} // end of class PieLayout
}