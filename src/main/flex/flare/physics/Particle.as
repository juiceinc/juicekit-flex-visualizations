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
 * Represents a Particle in a physics simulation. A particle is a
 * point-mass (or point-charge) subject to physical forces.
 */
public class Particle
{
  /** The mass (or charge) of the particle. */
  public var mass:Number;
  /** The number of springs (degree) attached to this particle. */
  public var degree:Number;
  /** The x position of the particle. */
  public var x:Number;
  /** The y position of the particle. */
  public var y:Number;
  /** The x velocity of the particle. */
  public var vx:Number;
  /** A temporary x velocity variable. */
  public var _vx:Number;
  /** The y velocity of the particle. */
  public var vy:Number;
  /** A temporary y velocity variable. */
  public var _vy:Number;
  /** The x force exerted on the particle. */
  public var fx:Number;
  /** The y force exerted on the particle. */
  public var fy:Number;
  /** The age of the particle in simulation ticks. */
  public var age:Number;
  /** Flag indicating if the particule should have a fixed position. */
  public var fixed:Boolean;
  /** Flag indicating that the particle is scheduled for removal. */
  public var die:Boolean;
  /** Tag property for storing an arbitrary value. */
  public var tag:uint;

  /**
   * Creates a new Particle with given parameters.
   * @param mass the mass (or charge) of the particle
   * @param x the x position of the particle
   * @param y the y position of the particle
   * @param vx the x velocity of the particle
   * @param vy the y velocity of the particle
   * @param fixed flag indicating if the particle should have a
   *  fixed position
   */
  public function Particle(mass:Number = 1, x:Number = 0, y:Number = 0,
                           vx:Number = 0, vy:Number = 0, fixed:Boolean = false)
  {
    init(mass, x, y, vx, vy, fixed);
  }

  /**
   * Initializes an existing particle instance.
   * @param mass the mass (or charge) of the particle
   * @param x the x position of the particle
   * @param y the y position of the particle
   * @param vx the x velocity of the particle
   * @param vy the y velocity of the particle
   * @param fixed flag indicating if the particle should have a
   *  fixed position
   */
  public function init(mass:Number = 1, x:Number = 0, y:Number = 0,
                       vx:Number = 0, vy:Number = 0, fixed:Boolean = false):void
  {
    this.mass = mass;
    this.degree = 0;
    this.x = x;
    this.y = y;
    this.vx = this._vx = vx;
    this.vy = this._vy = vy;
    this.fx = 0;
    this.fy = 0;
    this.age = 0;
    this.fixed = fixed;
    this.die = false;
    this.tag = 0;
  }

  /**
   * "Kills" this particle, scheduling it for removal in the next
   * simulation cycle.
   */
  public function kill():void {
    this.die = true;
  }

} // end of class Particle
}