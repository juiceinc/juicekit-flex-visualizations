/*
* Copyright 2007-2010 Juice, Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package org.juicekit.charts {
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.layout.AxisLayout;
	
	import org.juicekit.util.Shapes;
	
	[Bindable]
	public class FlareColumnChart extends FlareBarChartBase {
		public function FlareColumnChart() {
			super();
			this.registerActions(actionMap);
		}
		
		override protected function setDefaults():void {
			super.setDefaults();
			axisLayout = new AxisLayout(categoryEncodingField, valueEncodingField);
			sizingDimension = 'width';
		}
		
		
		/**
		 * A proxy for Flare properties. The key is the
		 * local property that may change. The value is either
		 * a property that the new value should be assigned to,
		 * or a function that will receive the PropertyChangeEvent.
		 */
		private var actionMap:Object = {
		};
		
		
		override protected function styleNodes():void {
			super.styleNodes();
			vis.data.nodes.visit(function(d:DataSprite):void {
				var n:NodeSprite = d as NodeSprite;
				n.shape = Shapes.VERTICAL_BAR;
			});
		}
		
	}
}