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

package flare.scale {
import flash.utils.Dictionary;

/**
 * <p>Scale for ordered sequential data. This supports both numeric and
 * non-numeric data, and simply places each element in sequence using
 * the ordering found in the input data array.</p>
 *
 * <p>The scale is <i>persistent</i> because once encountered, an ordinal
 * value always maps to the same value on the scale, unlike the
 * <code>OrdinalScale</code> where mappings depend on the current
 * data set.</p>
 */
public class PersistentOrdinalScale extends OrdinalScale {
  /**
   * Stores scales, with one scale per property
   */
  private static var _scaleStore:Object = {};

  private var _ordinalCount:uint = 0;


  static public function getScale(ordinals:Array = null, flush:Boolean = false, copy:Boolean = true, labelFormat:String = null, property:String = null):PersistentOrdinalScale {
    if (_scaleStore[property] === undefined)
      _scaleStore[property] = new PersistentOrdinalScale(ordinals, flush, copy, labelFormat);
    _scaleStore[property].ordinals = ordinals;
    return _scaleStore[property];
  }


  public function PersistentOrdinalScale(ordinals:Array = null, flush:Boolean = false, copy:Boolean = true, labelFormat:String = null) {
    super(ordinals, flush, copy, labelFormat);
  }


  override protected function buildLookup():void {
    if (_lookup == null) {
      _lookup = new Dictionary();
    }
    for (var i:uint = 0; i < _ordinals.length; ++i) {
      if (_lookup[ordinals[i]] === undefined) {
        _lookup[ordinals[i]] = _ordinalCount;
        _ordinalCount++;
      }
    }
  }

  private var _spread:uint = 4;

  // Describes offsets as percentage of a _spread unit for the persistent ordinal distribution
  private var scatterer:Array = [
    1, 0.5, 0.25, 0.75,
    0.125, 0.625, 0.375, 0.875,
    0.0625, 0.5625, 0.1875, 0.6875,
    0.3125, 0.8125, 0.4375, 0.9375
  ];

  public override function interpolate(value:Object):Number
  {
    if (_ordinals == null || _ordinals.length == 0) return 0.5;

    if (Number(_lookup[value]) == 0) return 0.0;

    var baseOffset:Number = scatterer[Math.floor((Number(_lookup[value]) - 1) / _spread) % scatterer.length];
    return (baseOffset + (Number(_lookup[value]) - 1) % _spread) / _spread;
  }


  /** @inheritDoc */
  public override function get scaleType():String {
    return ScaleType.PERSISTENT_ORDINAL;
  }

}

}