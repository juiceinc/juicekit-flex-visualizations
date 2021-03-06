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

package flare.vis.legend
{
import flare.display.RectSprite;
import flare.display.TextSprite;

import flash.display.Graphics;
import flash.display.Shape;

import org.juicekit.util.Shapes;

/**
 * An item in a discrete legend consisting of a label and
 * an icon indicating color, shape, and/or size.
 */
public class LegendItem extends RectSprite
{
  private var _value:Object;

  private var _icon:Shape;
  private var _iconLineWidth:Number = 2;
  private var _label:TextSprite;

  private var _iconSize:Number = 12;
  private var _maxIconSize:Number = 12;
  private var _margin:Number = 5;

  private var _shape:String;
  private var _color:uint;

  private var _selected:Boolean = false;

  // -- Properties ------------------------------------------------------

  /** The data value represented by this legend item. */
  public function get value():Object {
    return _value;
  }

  public function set value(v:Object):void {
    _value = v;
  }

  /** Shape presenting this legend item's icon. */
  public function get icon():Shape {
    return _icon;
  }

  /** TextSprite presenting this legend item's label. */
  public function get label():TextSprite {
    return _label;
  }

  /** The label text. */
  public function get text():String {
    return _label.text;
  }

  public function set text(t:String):void {
    if (t != _label.text) {
      _label.text = t;
      dirty();
    }
  }

  /** Line width to use within the icon. */
  public function get iconLineWidth():Number {
    return _iconLineWidth;
  }

  public function set iconLineWidth(s:Number):void {
    if (s != _iconLineWidth) {
      _iconLineWidth = s;
      dirty();
    }
  }

  /** Size parameter for icon drawing. */
  public function get iconSize():Number {
    return _iconSize;
  }

  public function set iconSize(s:Number):void {
    if (s != _iconSize) {
      _iconSize = s;
      dirty();
    }
  }

  /** Maximum size parameter for icon drawing. */
  public function get maxIconSize():Number {
    return _maxIconSize;
  }

  public function set maxIconSize(s:Number):void {
    if (s != _maxIconSize) {
      _maxIconSize = s;
      dirty();
    }
  }

  /** Margin value for padding within the legend item. */
  public function get margin():Number {
    return _margin;
  }

  public function set margin(m:Number):void {
    if (m != _margin) {
      _margin = m;
      dirty();
    }
  }

  /** The inner width of this legend item. */
  public function get innerWidth():Number {
    return 2 * _margin + _maxIconSize +
           (_label.text.length > 0 ? _margin + _label.width : 0);
  }

  /** The inner height of this legend item. */
  public function get innerHeight():Number {
    return Math.max(2 * _margin + _maxIconSize, _label.height);
  }

  /** Flag indicating if this legend item has been selected. */
  public function get selected():Boolean {
    return _selected;
  }

  public function set selected(b:Boolean):void {
    _selected = b;
  }

  // -- Methods ---------------------------------------------------------

  /**
   * Creates a new LegendItem.
   * @param text the label text
   * @param color the color of the label icon
   * @param shape a shape drawing function for the label icon
   * @param iconSize a size parameter for drawing the label icon
   */
  public function LegendItem(text:String = null, color:uint = 0xff888888,
                             shape:String = null, iconSize:Number = NaN)
  {
    addChild(_icon = new Shape());
    addChild(_label = new TextSprite(text));

    // init background
    super(0, 0, 0, 2 * _margin + _iconSize, 13, 13);
    lineColor = 0;
    fillColor = 0;

    // init label
    _label.horizontalAnchor = TextSprite.LEFT;
    _label.verticalAnchor = TextSprite.MIDDLE;
    _label.mouseEnabled = false;

    // init icon
    _color = color;
    _shape = shape;
    if (!isNaN(iconSize)) _iconSize = iconSize;
  }

  /** @inheritDoc */
  public override function render():void
  {
    // layout label
    _label.x = 2 * _margin + _maxIconSize;
    _label.y = innerHeight / 2;
    // TODO compute text abbrev as needed?

    // layout icon
    _icon.x = _margin + _maxIconSize / 2;
    _icon.y = innerHeight / 2;
    if (_label.textMode != TextSprite.EMBED) _icon.y -= 1;

    // render icon
    var draw:Function = _shape ? Shapes.getShape(_shape) : null;
    var g:Graphics = _icon.graphics;
    g.clear();
    if (draw != null) {
      g.beginFill(_color);
      g.lineStyle(_iconLineWidth, _color, 1);
      draw(g, _iconSize / 2);
      g.endFill();
    } else {
      g.beginFill(_color);
      Shapes.drawCircle(g, _iconSize / 2);
      g.endFill();
    }

    _h = innerHeight;
    super.render();
  }

} // end of class LegendItem
}