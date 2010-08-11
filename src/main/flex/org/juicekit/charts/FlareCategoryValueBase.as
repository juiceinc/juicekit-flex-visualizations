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
	import flare.display.TextSprite;
	import flare.scale.ScaleType;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.encoder.ColorEncoder;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.AxisLayout;
	
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import mx.events.PropertyChangeEvent;
	import mx.styles.StyleManager;
	
	import org.juicekit.palette.ColorPalette;
	import org.juicekit.util.Colors;
	import org.juicekit.util.Property;
	import org.juicekit.util.Shapes;
	
	
	[Bindable]
	public class FlareCategoryValueBase extends FlareVisBase {
		public function FlareCategoryValueBase() {
			super();
			this.registerActions(actionMap);
			baseOperators.addItem(axisLayout);
			baseOperators.addItem(lineColorEncoder);
			baseOperators.addItem(markerColorEncoder);
			baseOperators.addItem(nodePropertyEncoder);
			baseOperators.addItem(edgePropertyEncoder);
			
			labelEncoder.yOffset = labelYoffset;
			labelEncoder.xOffset = labelXoffset;
			baseOperators.addItem(labelEncoder);
		}
		
		
		protected function createTextFormat():TextFormat {
			var c:uint = StyleManager.getStyleManager(null).getColorName(fontColor);
			if (c != StyleManager.NOT_A_COLOR) {
				if (Colors.a(c) == 0) c = Colors.setAlpha(c, 255);
			}
			return new TextFormat(fontFamily, fontSize, c, fontWeight == 'bold', fontStyle == 'italic');
		}
		
		protected function textFormatChanged(e:PropertyChangeEvent):void {
			const tf:TextFormat = createTextFormat();
			if (vis != null) {
				vis.xyAxes.xAxis.labelTextFormat = tf;
				vis.xyAxes.yAxis.labelTextFormat = tf;
			}
		}
		
		protected function colorPaletteChanged(e:PropertyChangeEvent):void {
			if (e.property == 'markerPalette') {
				//TODO: determine whether the palette is linear or categorical and choose the appropriate scale type
				//        if (e.newValue == null)
				//        else markerColorEncoder.scale.scaleType = ScaleType.LINEAR;
				if (e.newValue is ColorPalette) {
					markerColorPalette = e.newValue as ColorPalette;
				} else {
					markerColorPalette = ColorPalette.getCategoricalPaletteByName(e.newValue as String);
				}
				markerColorEncoder.palette = markerColorPalette;
			}
			//        if (e.newValue == null) lineColorEncoder.scale.scaleType = ScaleType.PERSISTENT_ORDINAL;
			//        else lineColorEncoder.scale.scaleType = ScaleType.LINEAR;
			if (e.property == 'linePalette') {
				if (e.newValue is ColorPalette) {
					lineColorPalette = e.newValue as ColorPalette;
				} else {
					lineColorPalette = ColorPalette.getCategoricalPaletteByName(e.newValue as String);
				}
				lineColorEncoder.palette = lineColorPalette;
			}
		}
		
		override protected function styleNodes():void {
			// if (gapWidth !== null)
			resizeStrategy();
			if (endLabelEnabled) endLabelStrategy();
		}
		
		// Calculate number of distinctive nodes for aid with resizing strategy
		protected function distinctiveNodes():uint {
			var dict:Dictionary = new Dictionary();
			var count:uint = 0;
			vis.data.nodes.visit(function(d:DataSprite):void {
				if (dict[Property.$(categoryEncodingField).getValue(d)] == null) {
					dict[Property.$(categoryEncodingField).getValue(d)] = true;
					count += 1
				}
			});
			return count;
			
		}
		
		/**
		 * resizeStrategy allows for automatically adjusting the width of the markers
		 * The default behavior adjusts according to the minimum of either the specified
		 * markerSize or a dynamically adjusted gapWidth.
		 *
		 */
		protected function resizeStrategy():void {
			if (gapWidth > 1 || gapWidth < 0) throw Error("gapWidth is a proportion of the space that must be taken up by the gap.  Only values between 0 and 1 are acceptable.");
			
			//6 is the default multiplier of nodeSize versus canvasSize
			nodePropertyEncoder.values.size = Math.min(markerSize, (1 - gapWidth) * this[sizingDimension] /
				(6 * (distinctiveNodes() - 1)))
		}
		
		protected function endLabelStrategy():void {
			labelEncoder.group = Data.NODES;
			labelEncoder.source = valueEncodingField;
			
			if (vis && vis.data && vis.data.length > 0)  labelEncoder.operate();
		}
		
		/**
		 * A proxy for Flare properties. The key is the
		 * local property that may change. The value is either
		 * a property that the new value should be assigned to,
		 * or a function that will receive the PropertyChangeEvent.
		 */
		private var actionMap:Object = {
			'fontSize': textFormatChanged,
			'fontColor': textFormatChanged,
			'fontWeight': textFormatChanged,
			'fontFamily': textFormatChanged,
			'fontStyle': textFormatChanged,
			
			'markerPalette': colorPaletteChanged,
			'linePalette': colorPaletteChanged,
			
			'markerColorField': '@markerColorEncoder.source',
			'lineColorField': '@lineColorEncoder.source',
			'valueEncodingField': '@axisLayout.yField',
			'categoryEncodingField': '@axisLayout.xField',
			
			'markerSize': 'nodePropertyEncoder.values.size',
			'markerAlpha': 'nodePropertyEncoder.values.alpha',
			'markerShape': 'nodePropertyEncoder.values.shape',
			'markerBorderWidth': 'nodePropertyEncoder.values.lineWidth',
			'markerBorderColor': 'nodePropertyEncoder.values.lineColor',
			'borderColor': 'vis.xyAxes.borderColor',
			'showBorder':  'vis.xyAxes.showBorder',
			'lineWidth': 'edgePropertyEncoder.values.lineWidth',
			'stacked': 'axisLayout.yStacked',
			
			'valueMax': 'vis.xyAxes.yAxis.axisScale.preferredMax',
			'valueMin': 'vis.xyAxes.yAxis.axisScale.preferredMin',
			'zeroBased': 'vis.xyAxes.yAxis.axisScale.baseAtZero',
			'valueAxisReverse': 'vis.xyAxes.yReverse',
			'valueAxisShowLines': 'vis.xyAxes.yAxis.showLines',
			'valueAxisShowLabels': 'vis.xyAxes.yAxis.showLabels',
			'valueAxisLabelFormat': 'vis.xyAxes.yAxis.labelFormat',
			
			'categoryAxisReverse': 'vis.xyAxes.xReverse',
			'categoryAxisShowLines': 'vis.xyAxes.xAxis.showLines',
			'categoryAxisShowLabels': 'vis.xyAxes.xAxis.showLabels',
			'categoryAxisLabelFormat': 'vis.xyAxes.xAxis.labelFormat',
			
			'endLabelFormat': 'labelEncoder.labelFormat',
			'labelEncoderEnabled': 'labelEncoder.enabled',
			'labelYoffset': 'labelEncoder.yOffset',
			'labelXoffset': 'labelEncoder.xOffset',
			'endLabelAlign': 'labelEncoder.horizontalAnchor',
			
			'labelEncodingField': 'labelEncoder.source'
		}
		
		
		//------------------------
		// fonts
		//------------------------
		
		public var fontSize:Number = 10;
		public var fontFamily:String = 'Arial';
		public var fontColor:String = '#333333';
		public var fontWeight:String = 'normal';
		public var fontStyle:String = 'normal';
		
		
		//------------------------
		// axes
		//------------------------
		
		public var zeroBased:Boolean = false;
		public var valueAxisShowLines:Boolean = true;
		public var valueAxisShowLabels:Boolean = true;
		public var valueAxisLabelFormat:String = '0';
		public var valueAxis:Boolean = true;
		public var valueMax:Number = 100;
		public var valueMin:Number = 100;
		public var valueAxisReverse:Boolean = false;
		public var categoryAxisShowLines:Boolean = true;
		public var categoryAxisShowLabels:Boolean = true;
		public var categoryAxisReverse:Boolean = false;
		public var categoryAxisLabelFormat:String = '0';
		
		
		public var colorEncodingField:String = 'color';
		
		public var markerPalette:* = 'spectral';
		public var linePalette:* = 'spectral';
		
		
		//------------------------
		// fields
		//------------------------
		
		public var valueEncodingField:String = 'data.count';
		public var labelEncodingField:String = 'data.count';
		public var categoryEncodingField:String = 'data.date';
		public var markerColorField:String = 'data.series';
		public var markerBorderColor:uint = 0x000000;
		public var markerBorderWidth:Number = 1;
		public var gapWidth:Number = 0.0;
		public var markerSize:Number = 100.0;
		public var markerAlpha:Number = 1.0;
		public var lineColorField:String = 'source.data.series';
		public var lineWidth:Number = 2.0;
		public var borderWidth:Number = 1.0;
		public var borderColor:uint = 0x333333;
		public var showBorder:Boolean = true;
		public var masterAlpha:Number = 1.0;
		public var markerShape:String = Shapes.CIRCLE;
		public var stacked:Boolean = false;
		
		//-------------------------
		// end labels
		//-------------------------
		public var labelEncoderEnabled:Boolean = true;
		public var endLabelFormat:String = null;
		public var endLabelAlign:int = TextSprite.LEFT;
		public var endLabelEnabled:Boolean = false;
		public var labelYoffset:Number = 0; //-15;
		public var labelXoffset:Number = 0;
		
		public var sizingDimension:String = 'width';
		
		public var lineColorPalette:ColorPalette = ColorPalette.getCategoricalPaletteByName('Paired');
		public var markerColorPalette:ColorPalette = ColorPalette.getCategoricalPaletteByName('Paired');
		
		//------------------------
		// encoders
		//------------------------
		
		public var axisLayout:AxisLayout = createAxisLayout();
		public var lineColorEncoder:ColorEncoder = createLineColorEncoder();
		public var markerColorEncoder:ColorEncoder = createMarkerColorEncoder();
		public var nodePropertyEncoder:PropertyEncoder = createNodePropertyEncoder();
		public var edgePropertyEncoder:PropertyEncoder = createEdgePropertyEncoder();
		public var labelEncoder:Labeler = createLabelEncoder();
		
		//------------------------
		// encoders
		//------------------------
		
		protected function createAxisLayout():AxisLayout {
			return new AxisLayout(categoryEncodingField, valueEncodingField);
		}
		
		protected function createLineColorEncoder():ColorEncoder {
			return new ColorEncoder(lineColorField, Data.EDGES, "lineColor", ScaleType.PERSISTENT_ORDINAL, lineColorPalette);
		}
		
		protected function createMarkerColorEncoder():ColorEncoder {
			return new ColorEncoder(markerColorField, Data.NODES, "fillColor", ScaleType.PERSISTENT_ORDINAL, markerColorPalette);
		}
		
		protected function createNodePropertyEncoder():PropertyEncoder {
			return new PropertyEncoder(
				{lineAlpha: 1.0,
					alpha: markerAlpha,
					//shape: markerShape,
					size: markerSize,
					lineColor: markerBorderColor,
					lineWidth: markerBorderWidth
				}, Data.NODES);
		}
		
		protected function createEdgePropertyEncoder():PropertyEncoder {
			return new PropertyEncoder(
				{lineWidth: lineWidth,
					lineAlpha: 1.0
				}, Data.EDGES);
		}
		
		protected function createLabelEncoder():Labeler {
			return new Labeler(valueEncodingField, null, null);
		}
		
		
		
	}
}