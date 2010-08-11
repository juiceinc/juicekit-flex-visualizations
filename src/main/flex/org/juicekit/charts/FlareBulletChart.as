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

import flare.vis.data.DataList;
import flare.vis.data.DataSprite;
import flare.vis.data.NodeSprite;
import flare.vis.operator.encoder.PropertyEncoder;

import flash.text.TextFormat;

import mx.events.PropertyChangeEvent;

import org.juicekit.util.Arrays;
import org.juicekit.util.Property;
import org.juicekit.util.Sort;

/**
 * The class <code>FlareBulletChart</code> provides a base implementation
 * for charts with two bars overlaid on top of one another.
 * This is meant to
 *
 * @author Sal Uryasev
 */
[Bindable]
public class FlareBulletChart extends FlareCategoryValueBase {
  public function FlareBulletChart() {
    labelEncoder.cacheText = false;
    labelEncoder.group = 'greatest';
    this.registerActions(actionMap);
    baseOperators.addItem(secondNodePropertyEncoder);
    super();

    //      labelEncoder.yOffset = labelYoffset;
    //      labelEncoder.xOffset = labelXoffset;
    //      labelEncoder.textFormat = labelFormat;
    //      labelFormat.horizontalAnchor = LabelFormat.LEFT;
    //      baseOperators.push(labelEncoder);
  }

  //    private function createLabelFormat():LabelFormat {
  //      var lf:LabelFormat = (super.createTextFormat() as LabelFormat);
  //      lf.horizontalAnchor = LabelFormat.LEFT;
  //      return lf;
  //    }

  override protected function textFormatChanged(e:PropertyChangeEvent):void {
    const tf:TextFormat = createTextFormat();
    if (vis != null) {
      vis.xyAxes.xAxis.labelTextFormat = tf;
      vis.xyAxes.yAxis.labelTextFormat = tf;
    }
    tf.align = 'left';
    labelEncoder.textFormat = tf;
  }

  /**
   * A proxy for Flare properties. The key is the
   * local property that may change. The value is either
   * a property that the new value should be assigned to,
   * or a function that will receive the PropertyChangeEvent.
   */
  private var actionMap:Object = {
    'secondMarkerAlpha': 'secondNodePropertyEncoder.values.alpha'
  }

  public var seriesField:String = 'data.series';

  public var secondMarkerSizeMultiplier:Number = 0.5;
  public var secondMarkerAlpha:Number = 1.0;
  public var secondSeriesField:String = 'none';


  // This is automatically calculated, and this default is for pre-loading
  private var secondMarkerSize:Number = 100;


  public var secondNodePropertyEncoder:PropertyEncoder = new PropertyEncoder(
  {alpha: secondMarkerAlpha,
    size: secondMarkerSize
  }, 'secondSeries');

  override protected function styleNodes():void {
    //      super.styleNodes();

    var secondSeries:DataList = new DataList('secondSeries');

    var l:Property = Property.$('props.label');
    vis.data.nodes.visit(function(d:DataSprite):void {
      var n:NodeSprite = d as NodeSprite;
      n.shape = markerShape;
      // Make the label invisible
      if (endLabelEnabled && d.props['label']) d.props['label'].visible = false;

      // Figure out which elements are part of the second series
      if (Property.$(seriesField).getValue(d) == secondSeriesField) {
        secondSeries.add(d);
      }
      else {
        // Move this datasprite to the least visible location in the marks layer
        vis.marks.setChildIndex(d, 0);
      }
    });

    vis.data.addGroup('secondSeries', secondSeries);

    //TODO: Consider using Displays.sortChildren to determine stacking order
    //Displays.sortChildren(vis.marks,function(

    resizeStrategy();
    if (endLabelEnabled) endLabelStrategy();

  }

  override protected function endLabelStrategy():void {
    var a:Array = Arrays.copy(vis.data.nodes.list);
    a.sort(Sort.$([categoryEncodingField]));

    // get property instances for value operations
    var f:Property = Property.$(categoryEncodingField);
    var val:Property = Property.$(valueEncodingField);

    labelEncoder.source = valueEncodingField;

    var greatest:DataList = new DataList('greatest');

    // connect all items who match on the last group by field
    var i:uint;
    for (i = 1; i < a.length; ++i) {
      if (f && f.getValue(a[i - 1]) == f.getValue(a[i])) {
        if (val.getValue(a[i]) > val.getValue(a[i - 1])) {
          greatest.add(a[i]);
          if (a[i].props['label']) a[i].props['label'].visible = true;
        } else {
          if (a[i - 1].props['label']) a[i - 1].props['label'].visible = true;
          greatest.add(a[i - 1]);
        }
      }
    }
    vis.data.addGroup('greatest', greatest);

  }

  override protected function resizeStrategy():void {
    if (this.vis.data && this.vis.data.length > 0) {
      if (gapWidth > 1 || gapWidth < 0) throw Error("gapWidth is a proportion of the space that must be taken up by the gap.  Only values between 0 and 1 are acceptable.");

      var s:uint = distinctiveNodes();
      nodePropertyEncoder.values.size = Math.min(markerSize, (1 - gapWidth) * this[sizingDimension] /
                                                             (6 * (s - 1)))

      secondNodePropertyEncoder.values.size = nodePropertyEncoder.values.size * secondMarkerSizeMultiplier;
    }
  }

}
}