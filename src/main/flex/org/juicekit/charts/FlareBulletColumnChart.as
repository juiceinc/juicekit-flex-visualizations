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
	import org.juicekit.util.Shapes;

/**
 * The class <code>FlareBulletChart</code> provides a Columnß implementation
 * for charts with two bars overlaid on top of one another.
 *
 * @author Sal Uryasev
 */
[Bindable]
public class FlareBulletColumnChart extends FlareBulletChart {
  public function FlareBulletColumnChart() {
    super();
    this.registerActions(actionMap);
    markerShape = Shapes.VERTICAL_BAR;
    sizingDimension = 'width'; // For use by automatic bar sizing method
    labelYoffset = -15;
    labelXoffset = 0;
  }

  private var actionMap:Object = {
    'labelYoffset': 'labelEncoder.yOffset',
    'labelXoffset': 'labelEncoder.xOffset'
  }

}
}