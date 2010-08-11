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
import flash.utils.Dictionary;

import org.juicekit.util.Arrays;

/**
 * Scale for ordered sequential data. This supports both numeric and
 * non-numeric data, and simply places each element in sequence using
 * the ordering found in the input data array.
 */
public class OrdinalScale extends Scale
{
  protected var _ordinals:Array;
  protected var _lookup:Dictionary = null;

  /**
   * Creates a new OrdinalScale.
   * @param ordinals an ordered array of data values to include in the
   *  scale
   * @param flush the flush flag for scale padding
   * @param copy flag indicating if a copy of the input data array should
   *  be made. True by default.
   * @param labelFormat the formatting pattern for value labels
   */
  public function OrdinalScale(ordinals:Array = null, flush:Boolean = false,
                               copy:Boolean = true, labelFormat:String = null)
  {
    _ordinals = (ordinals == null ? new Array() :
                 copy ? Arrays.copy(ordinals) : ordinals);
    buildLookup();
    _flush = flush;
    _format = labelFormat;
  }

  /** @inheritDoc */
  public override function get scaleType():String {
    return ScaleType.ORDINAL;
  }

  /** @inheritDoc */
  public override function clone():Scale
  {
    return new OrdinalScale(_ordinals, _flush, true, _format);
  }

  // -- Properties ------------------------------------------------------

  /** The number of distinct values in this scale. */
  public function get length():int
  {
    return _ordinals.length;
  }

  /** The ordered data array defining this scale. */
  public function get ordinals():Array
  {
    return _ordinals;
  }

  public function set ordinals(val:Array):void
  {
    _ordinals = val;
    buildLookup();
  }

  /**
   * Builds a lookup table for mapping values to their indices.
   */
  protected function buildLookup():void
  {
    _lookup = new Dictionary();
    for (var i:uint = 0; i < _ordinals.length; ++i)
      _lookup[ordinals[i]] = i;
  }

  /** @inheritDoc */
  public override function get min():Object {
    return _ordinals[0];
  }

  /** @inheritDoc */
  public override function get max():Object {
    return _ordinals[_ordinals.length - 1];
  }

  // -- Scale Methods ---------------------------------------------------

  /**
   * Returns the index of the input value in the ordinal array
   * @param value the value to lookup
   * @return the index of the input value. If the value is not contained
   *  in the ordinal array, this method returns -1.
   */
  public function index(value:Object):int
  {
    var idx:* = _lookup[value];
    return (idx == undefined ? -1 : int(idx));
  }

  /** @inheritDoc */
  public override function interpolate(value:Object):Number
  {
    if (_ordinals == null || _ordinals.length == 0) return 0.5;

    if (_flush) {
      return Number(_lookup[value]) / (_ordinals.length - 1);
    } else {
      return (0.5 + _lookup[value]) / _ordinals.length;
    }
  }

  /** @inheritDoc */
  public override function lookup(f:Number):Object
  {
    if (_flush) {
      return _ordinals[int(Math.round(f * (_ordinals.length - 1)))];
    } else {
      f = Math.max(0, Math.min(1, f * _ordinals.length - 0.5));
      return _ordinals[int(Math.round(f))];
    }
  }

  /** @inheritDoc */
  public override function values(num:int = -1):Array
  {
    var a:Array = new Array();
    var stride:Number = num < 0 ? 1
            : Math.max(1, Math.floor(_ordinals.length / num));
    for (var i:uint = 0; i < _ordinals.length; i += stride) {
      a.push(_ordinals[i]);
    }
    return a;
  }

} // end of class OrdinalScale
}