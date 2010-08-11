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
 * Force simulating a spring force between two particles. This force
 * iterates over each <code>Spring</code> instance in a simulation and
 * computes the spring force between the attached particles. Spring forces
 * are computed using Hooke's Law plus a damping term modeling frictional
 * forces in the spring.
 *
 * <p>The actual equation is of the form: <code>F = -k*(d - L) + a*d*(v1 -
 * v2)</code>, where k is the spring tension, d is the distance between
 * particles, L is the rest length of the string, a is the damping
 * co-efficient, and v1 and v2 are the velocities of the particles.</p>
 */
public class SpringForce implements IForce
{
  /**
   * Applies this force to a simulation.
   * @param sim the Simulation to apply the force to
   */
  public function apply(sim:Simulation):void
  {
    var s:Spring, p1:Particle, p2:Particle;
    var dx:Number, dy:Number, dn:Number, dd:Number, k:Number, fx:Number, fy:Number;

    for (var i:uint = 0; i < sim.springs.length; ++i) {
      s = Spring(sim.springs[i]);
      p1 = s.p1;
      p2 = s.p2;
      dx = p1.x - p2.x;
      dy = p1.y - p2.y;
      dn = Math.sqrt(dx * dx + dy * dy);
      dd = dn < 1 ? 1 : dn;

      k = s.tension * (dn - s.restLength);
      k += s.damping * (dx * (p1.vx - p2.vx) + dy * (p1.vy - p2.vy)) / dd;
      k /= dd;

      // provide a random direction when needed
      if (dn == 0) {
        dx = 0.01 * (0.5 - Math.random());
        dy = 0.01 * (0.5 - Math.random());
      }

      fx = -k * dx;
      fy = -k * dy;

      p1.fx += fx;
      p1.fy += fy;
      p2.fx -= fx;
      p2.fy -= fy;
    }
  }

} // end of class SpringForce
}