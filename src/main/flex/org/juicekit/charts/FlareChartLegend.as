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
	import flare.display.LineSprite;
	import flare.vis.Visualization;
	import flare.vis.legend.Legend;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import org.juicekit.palette.ShapePalette;
	import org.juicekit.util.Shapes;
	
	
	/**
	 * The class <code>FlareChartLegend</code> provides a Flare Legend
	 * implementation that is linked to a FlareCategoryValueChart
	 *
	 * @author Sal Uryasev
	 */
	public class FlareChartLegend extends Canvas {
		public function FlareChartLegend() {			
			this.height = 100;
			this.width = 100;
			updateData();
			
		}
		
		private var UIRef:UIComponent = new UIComponent();
		
		private var _v:LineSprite;
		
		private var vis:Visualization = new Visualization();
		
		private var _legend:Legend;
		
		private var _chart:FlareCategoryValueBase;
		
		private var _title:String = '';
		public function get title():String {
			return _title;
		}
		
		
		public function set title(t:String):void {
			_title = t;
			if (_chart && _legend)
				_legend.title.text = _title;
		}
		
		
		public function get chart():FlareCategoryValueBase {
			return _chart;
		}
		
		private var _orientation:String;
		
		public function set orientation(o:String):void {
			_orientation = o;
			if (_chart && _legend)
				_legend.orientation = _orientation;
		}
		
		/**
		 * Set whether Legend elements are stacked out left to right or top to bottom.
		 * Possible options are 'leftToRight', 'topToBottom', 'bottomToTop', 'RightToLeft'
		 */
		public function get orientation():String {
			return _orientation;
		}
		
		
		public function set chart(f:FlareCategoryValueBase):void {
			if (_chart)
				_chart.removeEventListener('dataUpdate', updateData);
			_chart = f;
			updateData();
			_chart.addEventListener('dataUpdate', updateData);
		}
		
		public function draw():void {
			updateData();
		}
		
		public function updateData(e:Event = null):void {
			if (!_legend && _chart) {
				var s:ShapePalette = new ShapePalette();
				s.addShape(Shapes.SQUARE);
				_legend = Legend.fromScale(_title, _chart is FlareLineChart ? _chart.lineColorEncoder.scale : _chart.markerColorEncoder.scale,
					_chart is FlareLineChart ? _chart.lineColorPalette : _chart.markerColorPalette,
					s);
				rawChildren.addChild(_legend);
				_legend.labelTextFormat = new TextFormat('Arial', 12, 0x666666);
				_legend.bounds = new Rectangle(0, 0, this.width, this.height);
				if (_orientation !== null) {
					_legend.orientation = _orientation;
				}
			}
			else if (_chart) {
				_legend.scale = _chart.lineColorEncoder.scale;
				_legend.colorPalette = _chart is FlareLineChart ? _chart.lineColorPalette : _chart.markerColorPalette;
				_legend.buildFromScale();
				_legend.update();
				//_legend.labelTextMode = TextSprite.EMBED;
			}
			
		}
		
	}
}