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
import flash.display.InteractiveObject;
import flash.events.EventDispatcher;

import org.juicekit.util.Filter;

/**
 * Base class for interactive com.ingenix.trendview.controls.
 */
public class Control extends EventDispatcher implements IControl
{
  /** @private */
  protected var _object:InteractiveObject;
  /** @private */
  protected var _filter:Function;

  /** Boolean function indicating the items considered by the control.
   *  @see flare.util.Filter */
  public function get filter():Function {
    return _filter;
  }

  public function set filter(f:*):void {
    _filter = Filter.$(f);
  }

  /**
   * Creates a new Control
   */
  public function Control() {
    // do nothing
  }

  /** @inheritDoc */
  public function get object():InteractiveObject
  {
    return _object;
  }

  /** @inheritDoc */
  public function attach(obj:InteractiveObject):void
  {
    if (_object) detach();
    _object = obj;
  }

  /** @inheritDoc */
  public function detach():InteractiveObject
  {
    var obj:InteractiveObject = _object;
    _object = null;
    return obj;
  }

  // -- MXML ------------------------------------------------------------

  /** @private */
  public function initialized(document:Object, id:String):void
  {
    // do nothing
  }

} // end of class Control
}