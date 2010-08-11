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

package flare.vis.operator.distortion
{
import flash.geom.Rectangle;

/**
 * Computes a graphical fisheye distortion of a graph view. This distortion
 * allocates more space to items near the layout anchor and less space to
 * items further away, magnifying space near the anchor and demagnifying
 * distant space in a continuous fashion.
 *
 * <p>
 * For more details on this form of transformation, see Manojit Sarkar and
 * Marc H. Brown, "Graphical Fisheye Views of Graphs", in Proceedings of
 * CHI'92, Human Factors in Computing Systems, p. 83-91, 1992. Available
 * online at <a href="http://citeseer.ist.psu.edu/sarkar92graphical.html">
 * http://citeseer.ist.psu.edu/sarkar92graphical.html</a>.
 * </p>
 */
public class FisheyeDistortion extends Distortion
{
  private var _dx:Number; // x distortion factor
  private var _dy:Number; // y distortion factor
  private var _ds:Number; // size distortion factor

  // --------------------------------------------------------------------

  /**
   * Create a new FisheyeDistortion with the given distortion factors
   * along the x and y directions.
   * @param dx the distortion factor along the x axis (0 for none)
   * @param dy the distortion factor along the y axis (0 for none)
   * @param ds the distortion factor to use for sizes (0 for none)
   */
  public function FisheyeDistortion(dx:Number = 4, dy:Number = 4, ds:Number = 3) {
    _dx = dx;
    _dy = dy;
    _ds = ds;
    super(_dx > 0, _dy > 0, _ds > 0);
  }

  /** @inheritDoc */
  protected override function xDistort(x:Number):Number
  {
    return fisheye(x, layoutAnchor.x, _dx, _b.left, _b.right);
  }

  /** @inheritDoc */
  protected override function yDistort(y:Number):Number
  {
    return fisheye(y, layoutAnchor.y, _dy, _b.top, _b.bottom);
  }

  /** @inheritDoc */
  protected override function sizeDistort(bb:Rectangle, x:Number, y:Number):Number
  {
    if (!distortX && !distortY) return 1;
    var fx:Number = 1, fy:Number = 1;
    var a:Number, min:Number, max:Number, v:Number;

    if (distortX) {
      a = layoutAnchor.x;
      min = bb.left;
      max = bb.right;
      v = Math.abs(min - a) > Math.abs(max - a) ? min : max;
      if (v < _b.left || v > _b.right) v = (v == min ? max : min);
      fx = fisheye(v, a, _dx, _b.left, _b.right);
      fx = Math.abs(x - fx) / (max - min);
    }

    if (distortY) {
      a = layoutAnchor.y;
      min = bb.top;
      max = bb.bottom;
      v = Math.abs(min - a) > Math.abs(max - a) ? min : max;
      if (v < _b.top || v > _b.bottom) v = (v == min ? max : min);
      fy = fisheye(v, a, _dy, _b.top, _b.bottom);
      fy = Math.abs(y - fy) / (max - min);
    }

    var sf:Number = (!distortY ? fx : (!distortX ? fy : Math.min(fx, fy)));
    return (!isFinite(sf) || isNaN(sf)) ? 1 : _ds * sf;
  }

  private function fisheye(x:Number, a:Number, d:Number,
                           min:Number, max:Number):Number
  {
    if (d == 0) return x;

    var left:Boolean = x < a;
    var v:Number, m:Number = (left ? a - min : max - a);
    if (m == 0) m = max - min;
    v = Math.abs(x - a) / m;
    v = (d + 1) / (d + (1 / v));
    return (left ? -1 : 1) * m * v + a;
  }

} // end of class FisheyeDistortion
}