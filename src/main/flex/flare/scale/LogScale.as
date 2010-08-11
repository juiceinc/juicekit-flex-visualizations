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
 * Scale that performs a log transformation of the data. The base of the
 * logarithm is determined by the <code>base</code> property.
 */
public class LogScale extends QuantitativeScale
{
  private var _zero:Boolean = false;

  /**
   * Creates a new LogScale.
   * @param min the minimum data value
   * @param max the maximum data value
   * @param base the number base to use
   * @param flush the flush flag for scale padding
   * @param labelFormat the formatting pattern for value labels
   */
  public function LogScale(min:Number = 0, max:Number = 0, base:Number = 10,
                           flush:Boolean = false, labelFormat:String = Strings.DEFAULT_NUMBER)
  {
    super(min, max, base, flush, labelFormat);
  }

  /** @inheritDoc */
  public override function get scaleType():String {
    return ScaleType.LOG;
  }

  /** @inheritDoc */
  public override function clone():Scale {
    return new LogScale(_dmin, _dmax, _base, _flush, _format);
  }

  /** @inheritDoc */
  protected override function interp(val:Number):Number {
    if (_zero) {
      return Maths.invAdjLogInterp(val, _smin, _smax, _base);
    } else {
      return Maths.invLogInterp(val, _smin, _smax, _base);
    }
  }

  /** @inheritDoc */
  public override function lookup(f:Number):Object
  {
    if (_zero) {
      return Maths.adjLogInterp(f, _smin, _smax, _base);
    } else {
      return Maths.logInterp(f, _smin, _smax, _base);
    }
  }

  /** @inheritDoc */
  protected override function updateScale():void
  {
    _zero = (_dmin < 0 && _dmax > 0);
    if (!_flush) {
      _smin = Maths.logFloor(_dmin, _base);
      _smax = Maths.logCeil(_dmax, _base);

      if (_zero) {
        if (Math.abs(_dmin) < _base) _smin = Math.floor(_dmin);
        if (Math.abs(_dmax) < _base) _smax = Math.ceil(_dmax);
      }
    } else {
      _smin = _dmin;
      _smax = _dmax;
    }
  }

  private function log(x:Number):Number {
    if (_zero) {
      // distorts the scale to accomodate zero
      return Maths.adjLog(x, _base);
    } else {
      // uses a zero-symmetric logarithmic scale
      return Maths.symLog(x, _base);
    }
  }

  /** @inheritDoc */
  public override function values(num:int = -1):Array
  {
    var vals:Array = new Array();

    var beg:int = int(Math.round(log(_smin)));
    var end:int = int(Math.round(log(_smax)));

    if (beg == end && beg > 0 && Math.pow(10, beg) > _smin) {
      --beg; // decrement to generate more values
    }

    var i:int, j:int, b:Number, v:Number = _zero ? -1 : 1;
    for (i = beg; i <= end; ++i)
    {
      if (i == 0 && v <= 0) {
        vals.push(v);
        vals.push(0);
      }
      v = _zero && i < 0 ? -Math.pow(_base, -i) : Math.pow(_base, i);
      b = _zero && i < 0 ? Math.pow(_base, -i - 1) : v;

      for (j = 1; j < _base; ++j,v += b) {
        if (v > _smax) return vals;
        vals.push(v);
      }
    }
    return vals;
  }

} // end of class LogScale
}