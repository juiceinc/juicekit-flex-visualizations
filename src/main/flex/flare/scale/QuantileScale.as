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
 * Scale that organizes data into discrete bins by quantiles.
 * For example, the quantile scale can be used to create a discrete size
 * encoding by statistically dividing the data into bins. Quantiles are
 * computed using the <code>flare.util.Maths.quantile</code> method.
 *
 * @see flare.util.Maths#quantile
 */
public class QuantileScale extends Scale
{
  private var _quantiles:Array;

  /** @inheritDoc */
  public override function get flush():Boolean {
    return true;
  }

  public override function set flush(val:Boolean):void { /* nothing */
  }

  /** @inheritDoc */
  public override function get min():Object {
    return _quantiles[0];
  }

  /** @inheritDoc */
  public override function get max():Object {
    return _quantiles[_quantiles.length - 1];
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new QuantileScale.
   * @param n the number of quantiles desired
   * @param values the data values to organized into quantiles
   * @param sorted flag indicating if the input values array is
   *  already pre-sorted
   * @param labelFormat the formatting pattern for value labels
   */
  public function QuantileScale(n:int, values:Array,
                                sorted:Boolean = false, labelFormat:String = Strings.DEFAULT_NUMBER)
  {
    _quantiles = (n < 0 ? values : Maths.quantile(n, values, !sorted));
    this.labelFormat = labelFormat;
  }

  /** @inheritDoc */
  public override function get scaleType():String {
    return ScaleType.QUANTILE;
  }

  /** @inheritDoc */
  public override function clone():Scale
  {
    return new QuantileScale(-1, _quantiles, false, _format);
  }

  /** @inheritDoc */
  public override function interpolate(value:Object):Number
  {
    return Maths.invQuantileInterp(Number(value), _quantiles);
  }

  /** @inheritDoc */
  public override function lookup(f:Number):Object
  {
    return Maths.quantileInterp(f, _quantiles);
  }

  /** @inheritDoc */
  public override function values(num:int = -1):/*Number*/Array
  {
    var a:Array = new Array();
    var stride:int = num < 0 ? 1 :
                     int(Math.max(1, Math.floor(_quantiles.length / num)));
    for (var i:uint = 0; i < _quantiles.length; i += stride) {
      a.push(_quantiles[i]);
    }
    return a;
  }

} // end of class QuantileScale
}