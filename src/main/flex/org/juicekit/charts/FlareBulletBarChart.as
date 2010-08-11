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
import flare.vis.operator.layout.AxisLayout;

import org.juicekit.util.Shapes;

/**
 * The class <code>FlareBulletBarChart</code> provides a Bar implementation
 * for charts with two bars overlaid on top of one another.
 *
 * Since FlareCategoryValueBase defaults are for Column charts, we need
 * to verride a number of values.
 *
 * @author Sal Uryasev
 */
[Bindable]
public class FlareBulletBarChart extends FlareBulletChart {
  public function FlareBulletBarChart() {
    super();
    this.registerActions(actionMap);
  }
  
  override protected function setDefaults():void {
    super.setDefaults();
    markerShape = Shapes.HORIZONTAL_BAR;
    sizingDimension = 'height'; // For use by automatic bar sizing method
    labelYoffset = 0;
    labelXoffset = 25;

    axisLayout = new AxisLayout(valueEncodingField, categoryEncodingField);
  }

  private var actionMap:Object = {
    'labelYoffset': 'labelEncoder.yOffset',
    'labelXoffset': 'labelEncoder.xOffset',

    'valueEncodingField': '@axisLayout.xField',
    'categoryEncodingField': '@axisLayout.yField',

    'stacked': 'axisLayout.xStacked',

    'valueMax': 'vis.xyAxes.xAxis.axisScale.preferredMax',
    'valueMin': 'vis.xyAxes.xAxis.axisScale.preferredMin',
    'zeroBased': 'vis.xyAxes.xAxis.axisScale.baseAtZero',
    'valueAxisReverse': 'vis.xyAxes.xReverse',
    'valueAxisShowLines': 'vis.xyAxes.xAxis.showLines',
    'valueAxisShowLabels': 'vis.xyAxes.xAxis.showLabels',
    'valueAxisLabelFormat': 'vis.xyAxes.xAxis.labelFormat',

    'categoryAxisReverse': 'vis.xyAxes.yReverse',
    'categoryAxisShowLines': 'vis.xyAxes.yAxis.showLines',
    'categoryAxisShowLabels': 'vis.xyAxes.yAxis.showLabels'
  }

//  public var markerShape:String = Shapes.HORIZONTAL_BAR;
//  public var sizingDimension:String = 'height'; // For use by automatic bar sizing method
//  public var labelYoffset:Number = 0;
//  public var labelXoffset:Number = 25;
//
//  public var axisLayout:AxisLayout = new AxisLayout(valueEncodingField, categoryEncodingField);

}
}