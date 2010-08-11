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
 * Represents a Spring in a physics simulation. A spring connects two
 * particles and is defined by the springs rest length, spring tension,
 * and damping (friction) co-efficient.
 */
public class Spring
{
  /** The first particle attached to the spring. */
  public var p1:Particle;
  /** The second particle attached to the spring. */
  public var p2:Particle;
  /** The rest length of the spring. */
  public var restLength:Number;
  /** The tension of the spring. */
  public var tension:Number;
  /** The damping (friction) co-efficient of the spring. */
  public var damping:Number;
  /** Flag indicating that the spring is scheduled for removal. */
  public var die:Boolean;
  /** Tag property for storing an arbitrary value. */
  public var tag:uint;

  /**
   * Creates a new Spring with given parameters.
   * @param p1 the first particle attached to the spring
   * @param p2 the second particle attached to the spring
   * @param restLength the rest length of the spring
   * @param tension the tension of the spring
   * @param damping the damping (friction) co-efficient of the spring
   */
  public function Spring(p1:Particle, p2:Particle, restLength:Number = 10,
                         tension:Number = 0.1, damping:Number = 0.1)
  {
    init(p1, p2, restLength, tension, damping);
  }

  /**
   * Initializes an existing spring instance.
   * @param p1 the first particle attached to the spring
   * @param p2 the second particle attached to the spring
   * @param restLength the rest length of the spring
   * @param tension the tension of the spring
   * @param damping the damping (friction) co-efficient of the spring
   */
  public function init(p1:Particle, p2:Particle, restLength:Number = 10,
                       tension:Number = 0.1, damping:Number = 0.1):void
  {
    this.p1 = p1;
    this.p2 = p2;
    this.restLength = restLength;
    this.tension = tension;
    this.damping = damping;
    this.die = false;
    this.tag = 0;
  }

  /**
   * "Kills" this spring, scheduling it for removal in the next
   * simulation cycle.
   */
  public function kill():void {
    this.die = true;
  }

} // end of class Spring
}