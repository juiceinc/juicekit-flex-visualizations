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

package flare.vis.controls
{
import flare.vis.Visualization;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.core.IMXMLObject;

import org.juicekit.util.Arrays;

/**
 * A ControlList maintains a sequential chain of com.ingenix.trendview.controls for interacting
 * with a visualization. Controls may perform operations such as selection,
 * panning, zooming, and expand/contract. Controls can be added to a
 * ControlList using the <code>add</code> method. Once added, com.ingenix.trendview.controls can be
 * retrieved and set using their index in the lists, either with array
 * notation (<code>[]</code>) or with the <code>getControlAt</code> and
 * <code>setControlAt</code> methods.
 */
public class ControlList extends Proxy implements IMXMLObject
{
  protected var _vis:Visualization;
  protected var _list:/*IControl*/Array = [];

  /** The visualization manipulated by these com.ingenix.trendview.controls. */
  public function get visualization():Visualization {
    return _vis;
  }

  public function set visualization(v:Visualization):void {
    _vis = v;
    for each (var ic:IControl in _list) {
      ic.attach(v);
    }
  }

  /** An array of the com.ingenix.trendview.controls contained in the control list. */
  public function set list(ctrls:Array):void {
    // first remove all current operators
    while (_list.length > 0) {
      removeControlAt(_list.length - 1);
    }
    // then add the new operators
    for each (var ic:IControl in ctrls) {
      add(ic);
    }
  }

  /** The number of com.ingenix.trendview.controls in the list. */
  public function get length():uint {
    return _list.length;
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new ControlList.
   * @param ops an ordered set of com.ingenix.trendview.controls to include in the list.
   */
  public function ControlList(...controls) {
    for each (var ic:IControl in controls) {
      add(ic);
    }
  }

  /**
   * Proxy method for retrieving com.ingenix.trendview.controls from the internal array.
   */
  flash_proxy override function getProperty(name:*):*
  {
    return _list[name];
  }

  /**
   * Proxy method for setting com.ingenix.trendview.controls in the internal array.
   */
  flash_proxy override function setProperty(name:*, value:*):void
  {
    if (value is IControl) {
      var ic:IControl = IControl(value);
      _list[name].detach();
      _list[name] = ic;
      ic.attach(_vis);
    } else {
      throw new ArgumentError("Input value must be an IControl.");
    }
  }

  /**
   * Returns the control at the specified position in the list
   * @param i the index into the control list
   * @return the requested control
   */
  public function getControlAt(i:uint):IControl
  {
    return _list[i];
  }

  /**
   * Removes the control at the specified position in the list
   * @param i the index into the control list
   * @return the removed control
   */
  public function removeControlAt(i:uint):IControl
  {
    var ic:IControl = Arrays.removeAt(_list, i) as IControl;
    if (ic) ic.detach();
    return ic;
  }

  /**
   * Set the control at the specified position in the list
   * @param i the index into the control list
   * @param ic the control to place in the list
   * @return the control previously at the index
   */
  public function setControlAt(i:uint, ic:IControl):IControl
  {
    var old:IControl = _list[i];
    _list[i] = ic;
    old.detach();
    ic.attach(_vis);
    return old;
  }

  /**
   * Adds a control to the end of this list.
   * @param ic the control to add
   */
  public function add(ic:IControl):void
  {
    ic.attach(_vis);
    _list.push(ic);
  }

  /**
   * Adds a control at the specified index in the list.
   * @param ic the control to add
   * @param idx the index into the list
   */
  public function addAt(ic:IControl, idx:int):void
  {
    ic.attach(_vis);
    _list.splice(idx, 0, ic);
  }

  /**
   * Removes an control from this list.
   * @param ic the control to remove
   * @return true if the control was found and removed, false otherwise
   */
  public function remove(ic:IControl):IControl
  {
    var idx:int = Arrays.remove(_list, ic);
    if (idx >= 0) ic.detach();
    return ic;
  }

  /**
   * Removes all com.ingenix.trendview.controls from this list.
   */
  public function clear():void
  {
    for each (var ic:IControl in _list) {
      ic.detach();
    }
    Arrays.clear(_list);
  }

  // -- MXML ------------------------------------------------------------

  /** @private */
  public function initialized(document:Object, id:String):void
  {
    // do nothing
  }

} // end of class ControlList
}