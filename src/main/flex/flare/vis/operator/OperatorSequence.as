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
  import org.juicekit.animate.FunctionSequence;
  import org.juicekit.animate.Transitioner;
  import org.juicekit.util.Arrays;

/**
 * An OperatorSequence maintains a list of operators that are run in
 * sequence with an animated transition in between each. This is in
 * contrast to an OperatorList, which runs all the operators at once
 * and constructs a single animated transition across all sub-operators.
 * Instead, an OperatorSequence runs each operator separately, providing
 * each with a different Transitioner. The result is a multi-stage
 * animation, in which each operator in the sequence get its own
 * sub-transition.
 *
 * <p>The <code>add</code> method is not supported by this class. Instead,
 * use the <code>addToSequence</code> method, which includes the operator
 * to add along with a duration value (in seconds) specifying the length
 * of the animated transition for the operator.</p>
 *
 * <p>An OperatorSequence is implemented by creating a
 * <code>flare.animate.FunctionSequence</code> instance and using it to
 * construct the staged animation. The <code>FunctionSequence</code> is
 * then added to the <code>Transitioner</code> passed in to the
 * <code>operate</code> method for this class. As a result, the
 * <code>operate</code> methods for each operator contained in the
 * seqeunce will not be invoked until the top-level
 * <code>Transitioner</code> is played.</p>
 *
 * <p>However, if the input <code>Transitioner</code> is null or in
 * immediate mode, all the operators in the sequence will be run
 * immediately, exactly like a normal <code>OperatorList</code>.</p>
 */
public class OperatorSequence extends OperatorList
{
  /** @private */
  protected var _times:/*Number*/Array = [];

  /**
   * Creates a new OperatorSequence.
   */
  public function OperatorSequence()
  {
    super();
  }

  /**
   * Adds an operator and its timing information to this operator
   * sequence. The operator will be invoked with a transitioner
   * configured with the given duration (in seconds).
   * @param op the operator to add to the sequence
   * @param duration the duration of the animated transition to be
   *  used for results of the given operator.
   */
  public function push(op:IOperator, duration:Number):void
  {
    super.add(op);
    _times.push(duration);
  }

  /**
   * Sets the duration in seconds for the animated transition for the
   * operator at the given index.
   * @param i the index at which to set the duration
   * @param duration the desired duration, in seconds
   * @return the previous duration value
   */
  public function setDurationAt(i:uint, duration:Number):Number
  {
    var old:Number = _times[i];
    _times[i] = duration;
    return old;
  }

  /**
   * This method is not supported by this class and will throw an error
   * if invoked.
   * @param op an input operator (ignored)
   */
  public override function add(op:IOperator):void
  {
    throw new Error("Operation not supported. Use push instead.");
  }

  /** @inheritDoc */
  public override function remove(op:IOperator):Boolean
  {
    var idx:int = Arrays.remove(_list, op);
    if (idx >= 0) {
      _times.splice(idx, 1);
      return true;
    } else {
      return false;
    }
  }

  /** @inheritDoc */
  public override function removeOperatorAt(i:uint):IOperator
  {
    var op:IOperator = super.removeOperatorAt(i);
    if (op != null) _times.splice(i, 1);
    return op;
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    if (t == null || t.immediate) {
      super.operate(t);
    } else {
      var fs:FunctionSequence = new FunctionSequence();
      for (var i:int = 0; i < _list.length; ++i) {
        if (_list[i].enabled)
          fs.push(getFunction(_list[i]), _times[i]);
      }
      t.add(fs);
    }
  }

  private function getFunction(op:IOperator):Function {
    return function(t:Transitioner):void {
      op.operate(t);
      if (visualization.axes) {
        visualization.axes.update(t);
      }
    }
  }

} // end of class OperatorSequence
}