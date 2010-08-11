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

import flare.vis.data.Data;

import org.juicekit.animate.Transitioner;
import org.juicekit.util.Arrays;

/**
 * A SortOperator sorts a data group. This can be used to sort
 * elements prior to running a subsequent operation such as layout.
 * @see flare.util.Sort
 */
public class SortOperator extends Operator
{
  /** The data group to sort. */
  public var group:String;

  /** The sorting criteria. Sort criteria are expressed as an
   *  array of property names to sort on. These properties are accessed
   *  by sorting functions using the <code>Property</code> class.
   *  The default is to sort in ascending order. If the field name
   *  includes a "-" (negative sign) prefix, that variable will instead
   *  be sorted in descending order. */
  public function get criteria():Array {
    return Arrays.copy(_crit);
  }

  public function set criteria(crit:*):void {
    if (crit is String) {
      _crit = [crit];
    } else if (crit is Array) {
      _crit = Arrays.copy(crit as Array);
    } else {
      throw new ArgumentError("Invalid Sort specification type. " +
                              "Input must be either a String or Array");
    }
  }

  private var _crit:Array;

  /**
   * Creates a new SortOperator.
   * @param criteria the sorting criteria. Sort criteria are expressed as
   *  an array of property names to sort on. These properties are
   *  accessed by sorting functions using the <code>Property</code>
   *  class. The default is to sort in ascending order. If the field name
   *  includes a "-" (negative sign) prefix, that variable will instead
   *  be sorted in descending order.
   * @param group the data group to sort
   */
  public function SortOperator(criteria:Array, group:String = Data.NODES)
  {
    this.group = group;
    this.criteria = criteria;
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    visualization.data.group(group).sortBy(_crit);
  }

} // end of class SortOperator
}