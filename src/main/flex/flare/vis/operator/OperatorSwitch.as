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

package flare.vis.operator
{
  import org.juicekit.animate.Transitioner;


/**
 * An OperatorSwitch maintains a list of operators but only runs one
 * of these operators when invoked. A switch allows different operator
 * chains to be executed at different times. Operators can be added to
 * an OperatorSwitch using the <code>add</code> method. Once added,
 * operators can be retrieved and set using their index in the list, either
 * with array notation (<code>[]</code>) or with the
 * <code>getOperatorAt</code> and <code>setOperatorAt</code> methods.
 *
 * <p>The current sub-operator to run is determined by
 * the <tt>index</tt> property. This index can be set manually or can
 * be automatically determined upon each invocation by assigning a
 * custom function to the <tt>indexFunction</tt> property.</p>
 */
public class OperatorSwitch extends OperatorList
{
  private var _cur:int = -1;

  /** The currently active index of the switch. Only the operator at this
   *  index is run when the <code>operate</code> method is called. */
  public function get index():int {
    return _cur;
  }

  public function set index(i:int):void {
    _cur = i;
  }

  /**
   * A function that determines the current index value of this
   * OperatorSwitch. This can be used to have the operator automatically
   * adjust which sub-operators to run. If this property is non-null,
   * the function will be invoked each time this OperatorSwitch is run
   * and the index property will be set with the resulting value,
   * overriding any previous index setting.
   * The index function should accept zero arguments and return an
   * integer that is a legal index value for this switch. If the
   * returned value is not a legal index value (i.e., it is not an
   * integer or is out of bounds) then no sub-operators will be
   * run.
   */
  public var indexFunction:Function = null;

  // --------------------------------------------------------------------

  /**
   * Creates a new OperatorSwitch.
   * @param ops an ordered set of operators to include in the switch.
   */
  public function OperatorSwitch(...ops) {
    for each (var op:IOperator in ops) {
      add(op);
    }
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    t = (t != null ? t : Transitioner.DEFAULT);
    if (indexFunction != null) {
      _cur = indexFunction();
    }
    if (_cur >= 0 && _cur < _list.length && _list[_cur].enabled)
      _list[_cur].operate(t);
  }

} // end of class OperatorSwitch
}