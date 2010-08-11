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
 * Force simulating frictional drag forces (e.g., air resistance). For
 * each particle, this force applies a drag based on the particles
 * velocity (<code>F = a * v</code>, where a is a drag co-efficient and
 * v is the velocity of the particle).
 */
public class DragForce implements IForce
{
  private var _dc:Number;

  /** The drag co-efficient. */
  public function get drag():Number {
    return _dc;
  }

  public function set drag(dc:Number):void {
    _dc = dc;
  }

  /**
   * Creates a new DragForce with given drag co-efficient.
   * @param dc the drag co-efficient.
   */
  public function DragForce(dc:Number = 0.1) {
    _dc = dc;
  }

  /**
   * Applies this force to a simulation.
   * @param sim the Simulation to apply the force to
   */
  public function apply(sim:Simulation):void
  {
    if (_dc == 0) return;
    for (var i:uint = 0; i < sim.particles.length; ++i) {
      var p:Particle = sim.particles[i];
      p.fx -= _dc * p.vx;
      p.fy -= _dc * p.vy;
    }
  }

} // end of class DragForce
}