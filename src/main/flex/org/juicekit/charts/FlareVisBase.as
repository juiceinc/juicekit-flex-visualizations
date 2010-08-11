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
import flare.display.DirtySprite;
import flare.vis.Visualization;
import flare.vis.controls.Control;
import flare.vis.data.Data;
import flare.vis.data.DataSprite;
import flare.vis.data.NodeSprite;
import flare.vis.events.DataEvent;
import flare.vis.operator.Operator;

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import mx.binding.utils.ChangeWatcher;
import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
import mx.styles.StyleManager;

import org.juicekit.animate.TransitionEvent;
import org.juicekit.animate.Transitioner;
import org.juicekit.collections.JKArrayCollection;
import org.juicekit.events.DataMouseEvent;
import org.juicekit.util.Property;
import org.juicekit.util.helper.CSSUtil;

/**
 * Dispatched when data has been updated in the Visualization.
 *
 * @eventType flash.event.Event
 */
[Event(name="dataUpdate", type="flash.events.Event")]

/**
 * Dispatched when the user clicks a mouse on a
 * Flare <code>NodeSprite</code> or <code>EdgeSprite</code>.
 *
 * @eventType org.juicekit.events.DataMouseEvent.CLICK
 */
[Event(name="jkDataClick", type="org.juicekit.events.DataMouseEvent")]

/**
 * Dispatched when the user clicks on a
 * Flare <code>NodeSprite</code> or <code>EdgeSprite</code>.
 *
 * @eventType org.juicekit.events.DataMouseEvent.DOUBLE_CLICK
 */
[Event(name="jkDataDoubleClick", type="org.juicekit.events.DataMouseEvent")]

/**
 * Dispatched when the user moves out of a
 * Flare <code>NodeSprite</code> or <code>EdgeSprite</code>.
 *
 * @eventType org.juicekit.events.DataMouseEvent.MOUSE_OUT
 */
[Event(name="jkDataMouseOut", type="org.juicekit.events.DataMouseEvent")]

/**
 * Dispatched when the user moves over
 * Flare <code>NodeSprite</code> or <code>EdgeSprite</code>.
 *
 * @eventType org.juicekit.events.DataMouseEvent.MOUSE_OVER
 */
[Event(name="jkDataMouseOver", type="org.juicekit.events.DataMouseEvent")]

/**
 * Dispatched when an animating <code>Visualization</code>
 * update begins the animation <code>Transition</code>
 *
 * @eventType flare.animate.TransitionEvent
 */
[Event(name="start", type="flare.animate.TransitionEvent")]

/**
 * Dispatched when an animating <code>Visualization</code>
 * update completes the animation <code>Transition</code>
 *
 * @eventType flare.animate.TransitionEvent
 */
[Event(name="end", type="flare.animate.TransitionEvent")]


/**
 * Specifies the opaque background color of the control.
 * The default value is <code>undefined</code>.
 * If this style is undefined, the control has a transparent background.
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]


/*--- PADDING STYLES --*/

/**
 * Number of pixels between the component's left border
 * and the left edge of its content area.
 *
 * @default 0
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 * Number of pixels between the component's right border
 * and the right edge of its content area.
 *
 * @default 0
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 * Number of pixels between the component's bottom border
 * and the bottom edge of its content area.
 *
 * @default 0
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 * Number of pixels between the component's top border
 * and the top edge of its content area.
 *
 * @default 0
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]


/**
 * The class <code>FlareVisBase</code> provides a common implementation
 * for visual controls based upon the prefure.flare <code>Visualization</code>.
 * The class is only intended to be used as a base implementation
 * for custom controls and is not intended to be directly instantiated.
 *
 * @author Chris Gemignani
 * @author Sal Uryasev
 */
[Bindable]
public class FlareVisBase extends UIComponent {


  // Invoke the class constructor to initialize the CSS defaults.
  classConstructor();
  
  private static function classConstructor():void {
    CSSUtil.setDefaultsFor("org.juicekit.charts.FlareVisBase",
    { paddingLeft: 0
      , paddingRight: 0
      , paddingTop: 0
      , paddingBottom: 0
    }
            );
    // Note: The backgroundColor style property is undefined to support
    // specifing a transparent background.
  }


  /**
   * Constructor
   */
  public function FlareVisBase() {
    super();
    addEventListener(ResizeEvent.RESIZE, onResize);
    
    ChangeWatcher.watch(this, 'baseOperators', createOperators);
    ChangeWatcher.watch(this, 'extraOperators', createOperators);
    ChangeWatcher.watch(this, 'baseControls', createControls);
    ChangeWatcher.watch(this, 'extraControls', createControls);
    
    setDefaults();
    
    vis = makeVisualization();
    if (vis) {
      initVisualization();
    }
        
  }

 /**
  * This function is meant to be overwritten by subclasses.
  * It is to be used to set defaults for parameters.
  */ 
  protected function setDefaults():void {
  }
  
  /**
   * Stores reference to the prefuse.flare <code>Visualization</code> context.
   */
  public var vis:Visualization = null;
  
  /**
   * @private
   */
  override protected function createChildren():void {
    super.createChildren();

//    if (!vis) {
//      vis = makeVisualization();
//      if (vis) {
//        initVisualization();
     addChild(vis);
//      }
//    }
  }
  
    /**
   * Create a prefuse.flare <code>Visualization</code> instance.
   *
   * @return Returns a prefuse.flare <code>Visualization</code> instance.
   */
  protected function makeVisualization():Visualization {
    // Create the Visualization instance.
    return new Visualization();
  }


  /**
   * Initialize the control's prefuse.flare
   * <code>Visualization</code> instance. Derived classes should
   * override this function to add operators to the
   * <code>vis</code> object.
   */
  protected function initVisualization():void {
    addEventListeners();
  }


  /**
   * Add any event listeners to the <code>Visualization</code> instance.
   */
  protected function addEventListeners():void {
    // Hook mouse events.
    vis.addEventListener(MouseEvent.CLICK, signalDataMouseEvent);
    vis.addEventListener(MouseEvent.DOUBLE_CLICK, signalDataMouseEvent);
    vis.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    vis.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
  }


  /**
   * Remove any event listeners from the <code>Visualization</code> instance.
   */
  protected function removeEventListeners():void {
    // Hook mouse events.
    vis.removeEventListener(MouseEvent.CLICK, signalDataMouseEvent);
    vis.removeEventListener(MouseEvent.DOUBLE_CLICK, signalDataMouseEvent);
    vis.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    vis.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
  }


  /**
   * Handle mouse out events.
   */
  protected function onMouseOut(event:MouseEvent):void {
    const ds:DataSprite = event.target as DataSprite;
    if (!ds) {
      return;
    }

    signalDataMouseEvent(event);
  }


  /**
   * Handle mouse over events.
   */
  protected function onMouseOver(event:MouseEvent):void {
    const ds:DataSprite = event.target as DataSprite;
    if (!ds) {
      return;
    }

    signalDataMouseEvent(event);
  }


  /**
   * Dispatch <code>DataMouseEvent</code> events.
   */
  protected function signalDataMouseEvent(event:MouseEvent):void {
    if (event.target is DataSprite) {
      callLater(function():void {
        dispatchEvent(new DataMouseEvent(event, DataSprite(event.target).data, DataSprite(event.target)));
      });
    }
  }


  /**
   * Helper function to produce high-order alpha bits from
   * a Number ranging from 0.0 to 1.0 inclusive.
   *
   * @param alpha Is a <code>Number</code> value ranging from 0.0 to 1.0
   * inclusive where 0.0 is transparent and 1.0 is opaque.
   *
   * @return Returns high-order byte encoding of the alpha value.
   */
  protected static function numToAlphaBits(alpha:Number):uint {
    return Math.round(alpha * 255) << 24;
  }


  /**
   * Convert an RGB color value and alpha specification into a flare
   * compatible ARGB color value.
   *
   * @param rgbColor Is a <code>uint</code> holding the red, green, and
   * blue bytes in the lower three bytes.
   *
   * @param alpha Is a <code>Number</code> value ranging from 0.0 to 1.0
   * inclusive where 0.0 is transparent and 1.0 is opaque.
   *
   * @return Returns a flare compatible ARGB color <code>uint</code>.
   */
  protected static function toARGB(rgbColor:uint, alpha:Number):uint {
    const alphaBits:uint = numToAlphaBits(alpha);
    return rgbColor | alphaBits;
  }


  /**
   * Return a flare-style data property string.
   */
  protected function asFlareProperty(propertyName:String):String {
    return "data." + propertyName;
  }


  /**
   * Store the transitionPeriod property.
   */
  private var _transitionPeriod:Number = 0.5;

  /**
   * Specifies the animation transition time period in seconds. The
   * default value is <code>NaN</code> which disables animation.
   *
   * @default NaN
   */
  [Inspectable(category="General")]
  public function set transitionPeriod(seconds:Number):void {
    _transitionPeriod = seconds;
  }

  /**
   * @private
   */
  public function get transitionPeriod():Number {
    return _transitionPeriod;
  }


  /**
   * Signal a TransitionEvent.START event on the transient Transitioner
   * to the listener(s).
   */
  private function onStartTransition(event:TransitionEvent):void {
    dispatchEvent(new TransitionEvent(TransitionEvent.START, event.transition));
    event.transition.removeEventListener(TransitionEvent.START, onStartTransition);
  }

  /**
   * Signal a TransitionEvent.END event on the transient Transitioner
   * to the listener(s).
   */
  private function onEndTransition(event:TransitionEvent):void {
    dispatchEvent(new TransitionEvent(TransitionEvent.END, event.transition));
    event.transition.removeEventListener(TransitionEvent.END, onEndTransition);
    // Force a flush of Flare's unrendered changes.
    DirtySprite.renderDirty();
  }

  /**
   * Call the <code>update</code> method on the visualization. The
   * <code>transitionPeriod</code> property is used to determine
   * whether animation is appropriate. If animation is appropriate,
   * this method will signal <code>TransitionEvent.START</code>
   * and <code>TransitionEvent.END</code> to any listeners.
   */
  protected function updateVisualization():void {
    if (vis && vis.data !== null && vis.data.length > 0) {
      if (isNaN(transitionPeriod) || transitionPeriod <= 0) {
        vis.update();
        // Force a flush of flare's unrendered changes.
        DirtySprite.renderDirty();
      }
      else {
        const t:Transitioner = vis.update(transitionPeriod);
        if (hasEventListener(TransitionEvent.START)) {
          t.addEventListener(TransitionEvent.START, onStartTransition);
        }
        if (hasEventListener(TransitionEvent.END)) {
          t.addEventListener(TransitionEvent.END, onEndTransition);
        }
        t.play();
      }
    }
  }


  /**
   * @private
   */
  override protected function measure():void {
    var defaultWidth:Number = 0;
    var defaultHeight:Number = 0;

    if (vis) {
      defaultWidth = vis.bounds.width;
      defaultHeight = vis.bounds.height;
    }

    // Add in the padding.
    defaultWidth += getStyle("paddingLeft") + getStyle("paddingRight");
    defaultHeight += getStyle("paddingTop") + getStyle("paddingBottom");

    measuredMinWidth = measuredWidth = defaultWidth;
    measuredMinHeight = measuredHeight = defaultHeight;
  }


  /**
   * Translate control resizing into Visualization bounds updates.
   */
  private function onResize(event:ResizeEvent):void {
    if (vis) {
      const r:Rectangle = calcPaddedBounds(width, height);
      vis.x = r.x;
      vis.y = r.y;
      vis.bounds = r;
    }
  }


  /**
   * Calculates a <code>Rectangle</code> inset by any padding styles.
   *
   * @param w Is the maximum width before any padding is subtracted.
   *
   * @param h Is the maximum height before any padding is subtracted.
   *
   * @return Returns a rectangle inset by the padding styles.
   */
  protected function calcPaddedBounds(w:Number, h:Number):Rectangle {
    const paddingLeft:Number = getStyle("paddingLeft");
    const paddingTop:Number = getStyle("paddingTop");
    const r:Rectangle = new Rectangle();
    // TODO: Padding values are getting doubled when visualizations render
    // this adjusts for the doubling when drawing backgrounds, but we
    // need to investigate the fundamental cause
    r.x = paddingLeft;
    r.y = paddingTop;
    r.width = w - (paddingLeft + getStyle("paddingRight"));
    r.height = h - (paddingTop + getStyle("paddingBottom"));
    return r;
  }


  /**
   * @private
   */
  override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
    if (unscaledWidth === 0 && unscaledHeight === 0) {
      return;
    }

    // Clear the default graphics.
    const g:Graphics = this.graphics;
    g.clear();

    const backgroundColor:* = getStyle("backgroundColor");
	const hasBgColor:Boolean = StyleManager.getStyleManager(moduleFactory).isValidStyleValue(backgroundColor);

    // Draw a background?
    if (hasBgColor) {
      const r:Rectangle = vis.bounds;
      //const r:Rectangle = calcPaddedBounds(unscaledWidth, unscaledHeight);

      g.lineStyle();
      g.beginFill(backgroundColor);
      g.drawRect(r.x, r.y, r.width, r.height);
      g.endFill();
    }

    // Force an update to the visualization to handle resizing.
    if (vis && vis.data) {
      updateVisualization();
    }
  }  

  /**
   * <p>Registers an <code>actionMap</code> object. This is a
   * simple object containing a sequence of keys and values.
   * The keys represent bindable public variables, and the values are
   * actions to perform when the variable changes. Values can be
   * strings or functions with signature <code>function(e:PropertyChangeEvent):void</code>
   * or an Array of strings and functions.</p>
   *
   * <p>If the value is a string the property represented by the dotted string
   * is changed to the new value of the key. For instance:</p>
   *
   * <pre>
   * rev: 'vis.xyAxes.xReverse'
   * </pre>
   *
   * <p>If public variable <code>rev</code> changes, the new value is set into
   * <code>vis.xyAxes.xReverse</code></p>
   *
   * <p>If the value is a function, the function is passed the
   * <code>PropertyChangeEvent</code> when the <code>key</code> changes.</p>
   *
   * <p>If the value is an Array, all of the elements of the Array are evaluated
   * either as Strings or as functions.</p>
   */
  public function registerActions(actionMap:Object):void {
    for (var k:String in actionMap) {
      ChangeWatcher.watch(this, k, applyPropertyChange);
      registeredActionMap[k] = actionMap[k];
    }
  }

  /**
   * A proxy for Flare properties. The key is the
   * local property that may change. The value is either
   * a property that the new value should be assigned to,
   * or a function that will receive the PropertyChangeEvent.
   */
  private var registeredActionMap:Object = {}


  /**
   * A list of deferred property changes.
   *
   * These will be applied when data is set on the visualization.
   */
  private var propertyChangeQueue:Array = [];


  /**
   * Apply all the property changes in <code>propertyChangeQueue</code>.
   */
  private function clearPropertyChangeQueue():void {
    var _queue:Array = propertyChangeQueue.slice();
    propertyChangeQueue = [];
    for each (var e:PropertyChangeEvent in _queue) {
      applyPropertyChange(e);
    }
  }


  /**
   * Evaluated if any of the keys in <code>actionMap</code>
   * change.
   *
   * @param e a PropertyChangeEvent, ChangeWatchers are set up
   * by registerActions
   *
   * @private
   */
  private function applyPropertyChange(e:PropertyChangeEvent):void {
    function handleAction(source:*, a:*, e:PropertyChangeEvent):void {
      if (a is String) {
        try {
          var s:String = a as String;
          var dataProp:Boolean = false;

          // if the property is preceded by
          // @, we are setting a reference to one of the
          // data fields.
          if (s.charAt(0) == '@') {
            s = s.substr(1);
            dataProp = true;
          }

          var newVal:* = e.newValue;

          // TODO: this appears to be broken.
		  // Test if fixed with Property bugfix.
          if (dataProp) {
            // make sure the new value is preceeded by 'data.'
            if (newVal.toString().substr(0, 5) != 'data.') {
              newVal = asFlareProperty(newVal.toString());
            }
          }
          Property.$(s).setValue(source, newVal);
        } catch (e:Error) {
          trace('Error in setting property change in FlareVisBase');
        }
      } else if (a is Function) {
        a(e);
      }
    }

    var prop:Object = e.property;
    if (vis == null || vis.data == null) {
      // store the property change to be applied later
      // when the visualization exists and has data
      propertyChangeQueue.push(e.clone());
    } else {
      clearPropertyChangeQueue();
      if (registeredActionMap.hasOwnProperty(prop)) {
        var action:* = registeredActionMap[prop];
        if (action is Array) {
          for each (var itm:* in action) {
            handleAction(this, itm, e);
          }
        } else {
          handleAction(this, action, e);
        }
      }
      invalidateProperties();
    }
  }


  override protected function commitProperties():void {
    super.commitProperties();
    updateVisualization();
  }


  /**
   * <p>Add operators to <code>vis.operators</code>.</p>
   *
   * <p>The creation of <code>vis.operators</code> is <i>deferred</i>
   * until data is assigned to the visualization. This avoids problems
   * with scale bindings in the Flare framework.</p>
   *
   * <p>Subclasses should place the base operators needed for
   * the visualization in <code>baseOperators</code>.</p>
   */
  protected function createOperators(e:* = null):void {
    vis.operators.clear();
    var op:Operator;
    for each (op in baseOperators.source) {
      vis.operators.add(op);
    }
    for each (op in extraOperators.source) {
      vis.operators.add(op);
    }
    invalidateProperties();
  }

  /**
   * <p>Add com.ingenix.trendview.controls to <code>vis.com.ingenix.trendview.controls</code>.</p>
   *
   * <p>The creation of <code>vis.com.ingenix.trendview.controls</code> is <i>deferred</i>
   * until data is assigned to the visualization.</p>
   *
   * <p>Subclasses should place all base com.ingenix.trendview.controls needed for the
   * visualization in <code>baseControls</code>.</p>
   */
  protected function createControls(e:* = null):void {
    vis.controls.clear();
    var ctrl:Control;
    for each (ctrl in baseControls.source) {
      vis.controls.add(ctrl);
    }
    for each (ctrl in extraControls.source) {
      vis.controls.add(ctrl);
    }
    invalidateProperties();
  }

  /**
   * Operators that are used in every visualization
   */
  protected var baseOperators:ArrayCollection = new ArrayCollection([]);

  /**
   * Operators that are added by the user of the visualization.
   */
  public var extraOperators:ArrayCollection = new ArrayCollection([]);

  /**
   * Controls that are used in every visualization.
   */
  protected var baseControls:ArrayCollection = new ArrayCollection([]);

  /**
   * Controls that are added by the user of the visualization.
   */
  public var extraControls:ArrayCollection = new ArrayCollection([]);


  /**
   * Update the visualization.  This event may be called manually, or by
   * an event on <code>vis.data</code>
   */ 
  public function updateData(event:DataEvent = null):void {
    styleVis();
    styleNodes();
    styleEdges();
    invalidateProperties();
    dispatchEvent(new Event("dataUpdate"));
  }

  /**
   * dataProvider takes a DataArrayCollection (preferred), ArrayCollection,
   * or Data object and passes it to the underlying Flare visualization object.
   */
  public function set dataProvider(value:Object):void {
    if (value != null) {
      var newValue:Data;
      
      if (value is Data) {
        newValue = value as Data;
      }
      else if (value is ArrayCollection && (value as ArrayCollection).length > 0) {
        newValue = Data.fromArray(value.source);
      }
      else return;
    }
    
    if (newValue !== vis.data) {
      var dataFirstLoad:Boolean = vis.data==null ? true : false;
      
      if (vis.data != null) vis.data.removeEventListener(DataEvent.UPDATE, updateData);
      newValue.addEventListener(DataEvent.UPDATE, updateData);
      vis.data = newValue;

      if (dataFirstLoad) {
        createOperators();
        createControls();
      }
      styleNodes();
      styleEdges();
      styleVis();

      // Apply any cached, data bound changes
      clearPropertyChangeQueue();
      invalidateProperties();
    }
  }

  /**
   * A hook to set properties for nodes <b>after</b> new data is assigned.
   *
   * <p>Subclasses should override this.</p>
   */
  protected function styleNodes():void {
  }


  /**
   * A hook to set properties for edges <b>after</b> new data is assigned.
   * 
   * <p>Subclasses should override this.</p>
   */
  protected function styleEdges():void {
  }


  /**
   * A hook to set properties for visualization <b>after</b> new data is assigned and
   * operators are created. 
   * 
   * <p>Subclassess should override this.</p>
   */
  protected function styleVis():void {
  }

}
}