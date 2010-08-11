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

package flare.display
{
  import org.juicekit.util.Colors;

/**
 * A Sprite representing a rectangle shape. Supports line and fill colors
 * and rounded corners.
 */
public class RectSprite extends DirtySprite
{
  /** @private */
  protected var _w:Number;
  /** @private */
  protected var _h:Number;
  /** @private */
  protected var _cw:Number = 0;
  /** @private */
  protected var _ch:Number = 0;
  /** @private */
  protected var _fillColor:uint = 0x00ffffff;
  /** @private */
  protected var _lineColor:uint = 0xffaaaaaa;
  /** @private */
  protected var _lineWidth:Number = 0;
  /** @private */
  protected var _pixelHinting:Boolean = true;

  /** The width of the rectangle. */
  public function get w():Number {
    return _w;
  }

  public function set w(v:Number):void {
    _w = v;
    dirty();
  }

  /** The height of the rectangle. */
  public function get h():Number {
    return _h;
  }

  public function set h(v:Number):void {
    _h = v;
    dirty();
  }

  /** The width of rounded corners. Zero indicates no rounding. */
  public function get cornerWidth():Number {
    return _cw;
  }

  public function set cornerWidth(v:Number):void {
    _cw = v;
    dirty();
  }

  /** The height of rounded corners. Zero indicates no rounding. */
  public function get cornerHeight():Number {
    return _ch;
  }

  public function set cornerHeight(v:Number):void {
    _ch = v;
    dirty();
  }

  /** Sets corner width and height simultaneously. */
  public function set cornerSize(v:Number):void {
    _cw = _ch = v;
    dirty();
  }

  /** The fill color of the rectangle. */
  public function get fillColor():uint {
    return _fillColor;
  }

  public function set fillColor(c:uint):void {
    _fillColor = c;
    dirty();
  }

  /** The line color of the rectangle outline. */
  public function get lineColor():uint {
    return _lineColor;
  }

  public function set lineColor(c:uint):void {
    _lineColor = c;
    dirty();
  }

  /** The line width of the rectangle outline. */
  public function get lineWidth():Number {
    return _lineWidth;
  }

  public function set lineWidth(v:Number):void {
    _lineWidth = v;
    dirty();
  }

  /** Flag indicating if pixel hinting should be used for the outline. */
  public function get linePixelHinting():Boolean {
    return _pixelHinting;
  }

  public function set linePixelHinting(b:Boolean):void {
    _pixelHinting = b;
    dirty();
  }

  /**
   * Creates a new RectSprite.
   * @param x the x-coordinate of the top-left corner of the rectangle
   * @param y the y-coordinate of the top-left corder of the rectangle
   * @param w the width of the rectangle
   * @param h the height of the rectangle
   * @param cw the width of rounded corners (zero for no rounding)
   * @param ch the height of rounded corners (zero for no rounding)
   */
  public function RectSprite(x:Number = 0, y:Number = 0, w:Number = 0,
                             h:Number = 0, cw:Number = 0, ch:Number = 0)
  {
    this.x = x;
    this.y = y;
    this._w = w;
    this._h = h;
    this._cw = cw;
    this._ch = ch;
  }

  /** @inheritDoc */
  public override function render():void
  {
    graphics.clear();
    if (isNaN(_w) || isNaN(_h)) return;

    var la:Number = Colors.a(_lineColor) / 255;
    var fa:Number = Colors.a(_fillColor) / 255;
    var lc:uint = _lineColor & 0x00ffffff;
    var fc:uint = _fillColor & 0x00ffffff;

    if (la > 0) graphics.lineStyle(_lineWidth, lc, la, _pixelHinting);
    graphics.beginFill(fc, fa);
    if (_cw > 0 || _ch > 0) {
      graphics.drawRoundRect(0, 0, _w, _h, _cw, _ch);
    } else {
      graphics.drawRect(0, 0, _w, _h);
    }
    graphics.endFill();
  }

} // end of class RectSprite
}