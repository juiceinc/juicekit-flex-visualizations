/*
* Copyright (c) 2013 Juice Inc
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
	import org.juicekit.util.Maths;
	import org.juicekit.util.Strings;
	
	/**
	 * Scale that spaces values linearly along the scale range. This is the
	 * default scale for numeric types.
	 */
	public class LinearMidpointScale extends QuantitativeScale
	{

		protected var _smid:Number;		
		
		/**
		 * Creates a new LinearMidpointScale.
		 * @param min the minimum data value
		 * @param max the maximum data value
		 * @param base the number base to use
		 * @param flush the flush flag for scale padding
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function LinearMidpointScale(min:Number = 0, max:Number = 0, base:Number = 10,
									flush:Boolean = false, labelFormat:String = Strings.DEFAULT_NUMBER)
		{
			super(min, max, base, flush, labelFormat);
			_smid = min + (max - min) / 2;
		}
		
		/** @inheritDoc */
		public override function get scaleType():String {
			return ScaleType.LINEAR_MIDPOINT;
		}

		public function setMidpoint(v:Number=0):void {
			_smid = Maths.clampValue(v, _smin, _smax);
		}

		public function set midpoint(v:Number):void {
			setMidpoint(v);
		}
		
		public function get midpoint():Number {
			return _smid;
		}		
		
		/** @inheritDoc */
		public override function clone():Scale {
			var scale:LinearMidpointScale = new LinearMidpointScale(_dmin, _dmax, _base, _flush, _format);
			scale.setMidpoint(_smid);
			return scale;
		}
		
		/** @inheritDoc */
		protected override function interp(val:Number):Number {
			if (val < _smid) {
				return Maths.invLinearInterp(val, _smin, _smid) / 2.0;
			} else {
				return 0.5 + Maths.invLinearInterp(val, _smid, _smax) / 2.0;
			}
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Object {
			if (f < 0.5) {
				return Maths.linearInterp(f * 2.0, _smin, _smid);
			} else {
				return Maths.linearInterp((f - 0.5) * 2.0, _smid, _smax);
			}
		}
		
		
	} // end of class LinearScale
}