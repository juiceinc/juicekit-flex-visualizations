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

import flare.vis.data.Data;
import flare.vis.data.DataSprite;
import flare.vis.data.ScaleBinding;
import flare.vis.operator.Operator;

import mx.events.CollectionEvent;

import org.juicekit.animate.Transitioner;
import org.juicekit.palette.Palette;
import org.juicekit.util.Filter;
import org.juicekit.util.Property;


/**
 * Base class for Operators that perform encoding of visual variables such
 * as color, shape, and size. All Encoders share a similar structure:
 * A source property (e.g., a data field) is mapped to a target property
 * (e.g., a visual variable) using a <tt>ScaleBinding</tt> instance to map
 * between values and a <tt>Palette</tt> instance to map scaled output
 * into visual variables such as color, shape, and size.
 */
public class Encoder extends Operator
{
  /** Boolean function indicating which items to process. */
  protected var _filter:Function;
  /** The target property. */
  protected var _target:String;
  /** A transitioner for collecting value updates. */
  protected var _t:Transitioner;
  /** A scale binding to the source data. */
  protected var _binding:ScaleBinding;

  /** A scale binding to the source data. */
  public function get scale():ScaleBinding {
    return _binding;
  }

  public function set scale(b:ScaleBinding):void {
    if (_binding) {
      if (!b.property) b.property = _binding.property;
      if (!b.group) b.group = _binding.group;
      if (!b.data) b.data = _binding.data;
    }
    _binding = b;
  }

  public function setScaleBinding(b:ScaleBinding):void {
    _binding = b;
  }

  /** Boolean function indicating which items to process. Only items
   *  for which this function return true will be considered by the
   *  labeler. If the function is null, all items will be considered.
   *  @see flare.util.Filter */
  public function get filter():Function {
    return _filter;
  }

  public function set filter(f:*):void {
    _filter = Filter.$(f);
  }

  /** The name of the data group for which to compute the encoding. */
  public function get group():String {
    return _binding.group;
  }

  public function set group(g:String):void {
    _binding.group = g;
  }

  /** The source property. */
  public function get source():String {
    return _binding.property;
  }

  public function set source(f:String):void {
    _binding.property = f;
  }

  /** The target property. */
  public function get target():String {
    return _target;
  }

  public function set target(f:String):void {
    _target = f;
  }

  /** The palette used to map scale values to visual values. */
  public function get palette():Palette {
    return null;
  }

  public function set palette(p:Palette):void {
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new Encoder.
   * @param source the source property
   * @param target the target property
   * @param group the data group to process
   * @param filter a filter function controlling which items are encoded
   */
  public function Encoder(source:String = null, target:String = null,
                          group:String = Data.NODES, filter:* = null)
  {
    _binding = new ScaleBinding();
    _binding.property = source;
    _binding.group = group;
    _target = target;
    this.filter = filter;
  }

  /** @inheritDoc */
  override public function setup():void
  {
    if (visualization == null) return;
    _binding.data = visualization.data;
  }

  /** @inheritDoc */
  override public function operate(t:Transitioner = null):void
  {
    if (!canBindToData()) return;

    _t = (t != null ? t : Transitioner.DEFAULT);
    var p:Property = Property.$(_binding.property);
    _binding.updateBinding();

    if (visualization) {
      visualization.data.visit(function(d:DataSprite):void {
        _t.setValue(d, _target, encode(p.getValue(d)));
      }, _binding.group, _filter);
    }

    var targetProp:Property = Property.$(_target);
    if (dataProvider) {
      dataProvider.disableAutoUpdate();
      for each (var row:Object in dataProvider) {
        var oldValue:Object = targetProp.getValue(row);
        var newValue:Object = encode(p.getValue(row));
        _t.setValue(row, _target, newValue);
        dataProvider.itemUpdated(row, _target, oldValue, newValue); 
      }
      dataProvider.enableAutoUpdate();
    }

    _t = null;
  }

  /**
   * Computes an encoding for the input value.
   * @param val a data value to encode
   * @return the encoded visual value
   */
  protected function encode(val:Object):*
  {
    // sub-classes can override this
    return null;
  }

  /**
   * Verifies the encoder is attached to a <code>Visualization</code>
   * instance that currently has data. As a side effect, this method
   * will attempt to establish the data binding.
   * @return Returns true if a <code>Visualization</code>
   * instance's <code>data</code> property is non-null.
   */
  protected function canBindToData():Boolean {
    if (visualization && visualization.data) {
      if (visualization.data !== _binding.data) {
        _binding.data = visualization.data;
      }
      return true;
    }
    if (dataProvider) {
      return true;
    }
    return false;
  }
} // end of class Encoder
}