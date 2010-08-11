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

package flare.vis.operator.encoder
{
import flare.scale.ScaleType;
import flare.vis.data.Data;

import org.juicekit.palette.Palette;
import org.juicekit.palette.ShapePalette;

/**
 * Encodes a data field into shape values, using an ordinal scale.
 * Shape values are integer indices that map into a shape palette, which
 * provides drawing routines for shapes. See the
 * <code>flare.palette.ShapePalette</code> and
 * <code>flare.data.render.ShapeRenderer</code> classes for more.
 */
public class ShapeEncoder extends Encoder
{
  private var _palette:ShapePalette;

  /** @inheritDoc */
  public override function get palette():Palette {
    return _palette;
  }

  public override function set palette(p:Palette):void {
    _palette = p as ShapePalette;
  }

  /** The palette as a ShapePalette instance. */
  public function get shapes():ShapePalette {
    return _palette;
  }

  public function set shapes(p:ShapePalette):void {
    _palette = p;
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new ShapeEncoder.
   * @param source the source property
   * @param group the data group to process
   * @param palette the shape palette for assigning shapes
   */
  public function ShapeEncoder(field:String = null,
                               group:String = Data.NODES, palette:ShapePalette = null)
  {
    super(field, "shape", group);
    _binding.scaleType = ScaleType.CATEGORIES;
    _palette = palette ? palette : ShapePalette.defaultPalette();
  }

  /** @inheritDoc */
  protected override function encode(val:Object):*
  {
    return _palette.getShape(_binding.index(val));
  }

} // end of class ShapeEncoder
}