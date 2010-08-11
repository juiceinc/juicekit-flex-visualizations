package org.juicekit.charts
{
	import org.juicekit.util.Shapes;
	
	public class FlareBarChartBase extends FlareCategoryValueBase
	{
		public function FlareBarChartBase()
		{
			super();
		}
		
		override protected function setDefaults():void {
			super.setDefaults();
			markerShape = Shapes.CIRCLE;
		}
	}
}