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
/**
 * Interface used by classes which support mapping between
 * spatial (x,y) coordinates and values in a data scale. For example,
 * both an axis or legend range should provide this functionality.
 */
public interface IScaleMap
{
  /**
   * Returns the x-coordinate corresponding to the lower end of the scale.
   * @return the x-coordinate for the minimum value
   */
  function get x1():Number;

  /**
   * Returns the y-coordinate corresponding to the lower end of the scale.
   * @return the y-coordinate for the minimum value
   */
  function get y1():Number;

  /**
   * Returns the x-coordinate corresponding to the upper end of the scale.
   * @return the x-coordinate for the maximum value
   */
  function get x2():Number;

  /**
   * Returns the y-coordinate corresponding to the upper end of the scale.
   * @return the y-coordinate for the maximum value
   */
  function get y2():Number;

  /**
   * Returns the scale value corresponding to a given coordinate.
   * @param x the x-coordinate
   * @param y the y-coordinate
   * @param stayInBounds if true, x,y values outside the current layout
   * bounds will be snapped to the bounds. If false, the value lookup
   * will attempt to extrapolate beyond the scale bounds. This value
   * is true be default.
   * @return the scale value corresponding to the given coordinate.
   */
  function value(x:Number, y:Number, stayInBounds:Boolean = true):Object;

  /**
   * Returns the x-coordinate corresponding to the given scale value
   * @param val the scale value to lookup
   * @return the x-coordinate at which that scale value is placed
   */
  function X(val:Object):Number;

  /**
   * Returns the y-coordinate corresponding to the given scale value
   * @param val the scale value to lookup
   * @return the y-coordinate at which that scale value is placed
   */
  function Y(val:Object):Number;

} // end of interface IScaleMap
}