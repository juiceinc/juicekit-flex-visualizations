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

package flare.scale
{
  import org.juicekit.util.Maths;
  import org.juicekit.util.Strings;

/**
 * Scale that performs a root transformation of the data. This could be a
 * square root or any arbitrary power.
 */
public class RootScale extends QuantitativeScale
{
  private var _pow:Number = 2;

  /** The power of the root transform. A value of 2 indicates a square
   *  root, 3 a cubic root, etc. */
  public function get power():Number {
    return _pow;
  }

  public function set power(p:Number):void {
    _pow = p;
  }

  /**
   * Creates a new RootScale.
   * @param min the minimum data value
   * @param max the maximum data value
   * @param base the number base to use
   * @param flush the flush flag for scale padding
   * @param labelFormat the formatting pattern for value labels
   */
  public function RootScale(min:Number = 0, max:Number = 0, base:Number = 10,
                            flush:Boolean = false, pow:Number = 2,
                            labelFormat:String = Strings.DEFAULT_NUMBER)
  {
    super(min, max, base, flush, labelFormat);
    _pow = pow;
  }

  /** @inheritDoc */
  public override function get scaleType():String {
    return ScaleType.ROOT;
  }

  /** @inheritDoc */
  public override function clone():Scale {
    return new RootScale(_dmin, _dmax, _base, _flush, _pow, _format);
  }

  /** @inheritDoc */
  protected override function interp(val:Number):Number {
    if (_pow == 2) return Maths.invSqrtInterp(val, _smin, _smax);
    return Maths.invRootInterp(val, _smin, _smax, _pow);
  }

  /** @inheritDoc */
  public override function lookup(f:Number):Object {
    if (_pow == 2) return Maths.sqrtInterp(f, _smin, _smax);
    return Maths.rootInterp(f, _smin, _smax, _pow);
  }

} // end of class RootScale
}