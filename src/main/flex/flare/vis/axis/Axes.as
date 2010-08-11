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

package flare.vis.axis
{
import flare.vis.Visualization;

import flash.display.Sprite;
import flash.geom.Rectangle;

import org.juicekit.animate.Transitioner;

/**
 * Base class for representing metric data axes.
 */
public class Axes extends Sprite
{
  /** The visualization the axes correspond to. */
  protected var _vis:Visualization;
  /** The layout bounds of the axes. */
  protected var _bounds:Rectangle;

  /** The visualization the axes correspond to. */
  public function get visualization():Visualization {
    return _vis;
  }

  public function set visualization(v:Visualization):void {
    _vis = v;
  }

  /** The layout bounds of the axes. If this value is not directly set,
   *  the layout bounds of the visualization are provided. */
  public function get layoutBounds():Rectangle {
    if (_bounds != null) return _bounds;
    if (_vis != null) return _vis.bounds;
    return null;
  }

  public function set layoutBounds(b:Rectangle):void {
    _bounds = b;
  }

  /**
   * Update these axes, performing filtering and layout as needed.
   * @param trans a Transitioner for collecting value updates
   * @return the input transitioner
   */
  public function update(trans:Transitioner = null):Transitioner
  {
    return trans;
  }

  public function Axes():void {
    super();
  }

} // end of class Axes
}