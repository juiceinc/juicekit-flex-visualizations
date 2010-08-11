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

package flare.physics
{
/**
 * Force simulating a global gravitational pull on Particle instances.
 */
public class GravityForce implements IForce
{
  private var _gx:Number;
  private var _gy:Number;

  /** The gravitational acceleration in the horizontal dimension. */
  public function get gravityX():Number {
    return _gx;
  }

  public function set gravityX(gx:Number):void {
    _gx = gx;
  }

  /** The gravitational acceleration in the vertical dimension. */
  public function get gravityY():Number {
    return _gy;
  }

  public function set gravityY(gy:Number):void {
    _gy = gy;
  }

  /**
   * Creates a new gravity force with given acceleration values.
   * @param gx the gravitational acceleration in the horizontal dimension
   * @param gy the gravitational acceleration in the vertical dimension
   */
  public function GravityForce(gx:Number = 0, gy:Number = 0) {
    _gx = gx;
    _gy = gy;
  }

  /**
   * Applies this force to a simulation.
   * @param sim the Simulation to apply the force to
   */
  public function apply(sim:Simulation):void
  {
    if (_gx == 0 && _gy == 0) return;

    var p:Particle;
    for (var i:uint = 0; i < sim.particles.length; ++i) {
      p = sim.particles[i];
      p.fx += _gx * p.mass;
      p.fy += _gy * p.mass;
    }
  }

} // end of class GravityForce
}