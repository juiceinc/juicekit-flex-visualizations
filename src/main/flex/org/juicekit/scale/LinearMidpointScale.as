package org.juicekit.scale
{
	import org.juicekit.util.Strings;
	import org.juicekit.util.Maths;

	/**
	 * Scale that spaces values linearly along the scale range. This is the
	 * default scale for numeric types.
	 * 
	 * An optional midpoint can be set with setMidpoint. Values below
	 * the midpoint will be scaled linearly and values above will be
	 * scaled linearly. 
	 */
	public class LinearMidpointScale extends LinearScale
	{
		protected var _smid:Number;		
		
		/**
		 * Creates a new LinearScale.
		 * @param min the minimum data value
		 * @param max the maximum data value
		 * @param base the number base to use
		 * @param flush the flush flag for scale padding
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function LinearMidpointScale(min:Number=0, max:Number=0, base:Number=10, flush:Boolean=false, labelFormat:String=Strings.DEFAULT_NUMBER)
		{
			super(min, max, base, flush, labelFormat);
			_smid = min + (max - min) / 2;
		}
		
		/** @inheritDoc */
		public override function clone():Scale {
			var scale:LinearMidpointScale = new LinearMidpointScale(_dmin, _dmax, _base, _flush, _format);
			scale.setMidpoint(_smid);
			return scale;
		}
		
		public function setMidpoint(v:Number=0):void {
			_smid = Maths.clampValue(v, _smin, _smax);
		}

		/** @inheritDoc */
		[Bindable(event="updateScale")]
		protected override function interp(val:Number):Number {
			if (val < _smid) {
				return Maths.invLinearInterp(val, _smin, _smid) / 2.0;
			} else {
				return 0.5 + Maths.invLinearInterp(val, _smid, _smax) / 2.0;
			}
		}
		
		/** @inheritDoc */
		[Bindable(event="updateScale")]
		public override function lookup(f:Number):Object {
			if (f < 0.5) {
				return Maths.linearInterp(f * 2.0, _smin, _smid);
			} else {
				return Maths.linearInterp((f - 0.5) * 2.0, _smid, _smax);
			}
		}
	}
}