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


package org.juicekit.controls {
    import flare.scale.ScaleType;
    import flare.vis.data.Data;
    import flare.vis.data.DataList;
    import flare.vis.data.DataSprite;
    import flare.vis.data.NodeSprite;
    import flare.vis.data.Tree;
    import flare.vis.operator.Operator;
    import flare.vis.operator.encoder.ColorEncoder;
    import flare.vis.operator.encoder.Encoder;
    import flare.vis.operator.encoder.PropertyEncoder;
    import flare.vis.operator.layout.TreeMapLayout;
    
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    
    import org.juicekit.events.JuiceKitEvent;
    import org.juicekit.flare.label.Labels;
    import org.juicekit.palette.ColorPalette;
    import org.juicekit.util.helper.CSSUtil;
    
    include "../../../../shared/styles/metadata/TextStyles.as";
    
    
    /**
     * Possible labelColorStrategy values are: <code>blackwhite</code> adaptively choose black or
     * white depending on the background color, <code>glow</code> apply a white glow around
     * letters or <code>none</code> don't apply any effect.
     *
     * Deprecation warning: This default will be changed to <code>blackwhite</code> in
     * JuiceKit 2.0.
     *
     * @default "glow"
     */
    [Style(name="labelColorStrategy", type="String", enumeration="blackwhite,glow,none", inherit="no")]
    
    
    /**
     * Determines the vertical position of text within the cell.
     * Possible values are <code>"top"</code>, <code>"middle"</code>,
     * or <code>"bottom"</code>.
     *
     * @default "top"
     */
    [Style(name="textPosition", type="String", enumeration="top,middle,bottom", inherit="yes")]
    
    /**
     * Determines the alpha transparency values for rectangle strokes.
     * The first array alpha value maps to the
     * first level of data in the data tree, the second alpha value maps
     * to second level of data in the data tree, and so forth. Any data levels
     * deeper than the array has elements use the last element to determine
     * alpha value.
     *
     * @default [1.0]
     */
    [Style(name="strokeAlphas", type="Array", arrayType="Number", inherit="no")]
    
    /**
     * Each array element determines the color of the rectangles' stroke at a
     * given depth in the data tree. The first array stroke color maps to the
     * first level of data in the data tree, the second array stroke color maps
     * to second level of data in the data tree, and so forth. Any data levels
     * deeper than the array has elements use the last element to determine
     * stroke color. For example, <code>[0x00000000, 0xffFFFFFF]</code> specifies
     * that the root rectangle does not have a stroke color but all subsequent
     * data depths have a opaque white stroke.
     *
     * @default [0x00000000]
     */
    [Style(name="strokeColors", type="Array", arrayType="uint", format="Color", inherit="no")]
    
    /**
     * Each array element determines the thickness of the rectangles' stroke at a
     * given depth in the data tree. The first array stroke thickness maps to the
     * first level of data in the data tree, the second array stroke thickness maps
     * to second level of data in the data tree, and so forth. Any data levels
     * deeper than the array has elements use the last element to determine
     * stroke thickness. For example, <code>[0, 1.0]</code> specifies
     * that the root rectangle does not have a stroke thickness but all subsequent
     * data depths have a 1-pixel stroke thickness.
     *
     * Determines the thickness of the rectangles' stroke.
     *
     * @default [0]
     */
    [Style(name="strokeThicknesses", type="Array", arrayType="Number", format="Length", inherit="no")]
    
    /**
     * Determines the alpha transparency value for rectangle colors.
     *
     * @default 1.0
     */
    [Style(name="encodedColorAlpha", type="Number", inherit="no")]
    
    /**
     * Determines the fill color for rectangles near the minimum of a
     * range of data values.
     *
     * @default 0xFF0000
     */
    [Style(name="minEncodedColor", type="uint", format="Color", inherit="no")]
    
    /**
     * Determines the fill color for rectangles near the middle of a
     * range of data values.
     *
     * @default 0x000000
     */
    [Style(name="midEncodedColor", type="uint", format="Color", inherit="no")]
    
    /**
     * Determines the fill color for rectangles near the maximum of a
     * range of data values.
     *
     * @default 0x00FF00
     */
    [Style(name="maxEncodedColor", type="uint", format="Color", inherit="no")]
    
    
    /**
     * The TreeMapControl class visualizes large hierarchical data sets.
     * Data properties are used to encode both the rectangles' size and color.
     *
     * @author Jon Buffington
     */
    public class TreeMapControl extends FlareControlBase {
        
        
        // Invoke the class constructor to initialize the CSS defaults.
        classConstructor();
        
        
        private static function classConstructor():void {
            CSSUtil.setDefaultsFor("org.juicekit.visual.controls.TreeMapControl", {fontColor: 0x000000, textPosition: "top", strokeAlphas: [1.0], strokeColors: [0x000000], strokeThicknesses: [0], encodedColorAlpha: 1.0, minEncodedColor: 0xFF0000, midEncodedColor: 0x000000, maxEncodedColor: 0x00FF00, labelColorStrategy: 'glow'});
        }
        
        
        /**
         * Constructor.
         */
        public function TreeMapControl() {
            super();
        }
        
        
        /**
         * Is property name used for text styling?
         */
        private function isTextStyle(styleProp:String):Boolean {
            const textStyleProps:Array = ["fontColor", "fontFamily", "fontSize", "fontStyle", "fontWeight", "textAlign", "textPosition", "labelColorStrategy"];
            return textStyleProps.indexOf(styleProp) !== -1;
        }
        
        
        /**
         * Is property name used for visualization layout styling?
         */
        private function isLayoutStyle(styleProp:String):Boolean {
            const paletteStyleProps:Array = ["minEncodedColor", "midEncodedColor", "maxEncodedColor", "encodedColorAlpha", "strokeAlphas", "strokeColors", "strokeThicknesses"];
            
            return paletteStyleProps.indexOf(styleProp) !== -1;
        }
        
        
        /**
         * Note changes to styles.
         */
        private var _labelStyleChanged:Boolean = false;
        
        /**
         * Note changes to styles.
         */
        private var _layoutStyleChanged:Boolean = false;
        
        /**
         * Return the treemap leaf data as an ArrayCollection
         */
        [Bindable(event='dataRootChange')]
        public function toArrayCollection():ArrayCollection {
            if (vis && vis.data && vis.data.group('leaves')) {
                return vis.data.group('leaves').toArrayCollection();
            }
            else return new ArrayCollection([]);
        }
        
        [Bindable(event='dataRootChange')]
        public function CSVToClipboard():* {
            return toArrayCollection();
        }
        
        
        /**
         * @private
         */
        override public function styleChanged(styleProp:String):void {
            super.styleChanged(styleProp);
            
            const allStyles:Boolean = !styleProp || styleProp == "styleName";
            if (!allStyles) {
                if (isTextStyle(styleProp)) {
                    _labelStyleChanged = true;
                } else if (isLayoutStyle(styleProp)) {
                    _layoutStyleChanged = true;
                }
            }
            invalidateProperties();
        }
        
        
        //-----------------------------
        // emphasizing
        // Warning: this code is provisional and likely to be reworked soon.
        //-----------------------------
        
        /**
         * Mapping of names to anonymous functions
         */
        private var emphasizeList:Dictionary = new Dictionary();
        
        private var _defaultEmphasizeEffect:Object = {fillColor: 0xffbbbbbb};
        
        public function get defaultEmphasizeEffect():Object {
            return _defaultEmphasizeEffect;
        }
        
        /**
         * A PropertyEncoding to apply to matched nodes.
         */
        public function set defaultEmphasizeEffect(val:Object):void {
            _defaultEmphasizeEffect = val;
            var e:PropertyEncoder = vis.operators.getOperatorAt(OP_IX_EMPHASIZER) as PropertyEncoder;
            e.values = val;
            _extraOperatorsChanged = true;
            invalidateProperties();
        }
        
        /**
         * Append emphasizers and deemphasizers to the emphasizeList
         *
         * emphasize can be passed a function that takes a DataSprite and returns a boolean
         * Alternatively, the default behavior is a simple string match for the val
         */
        public function emphasize(val:String, testFunction:Function = null):void {
            if (val.length >= 1) {
                emphasizeList[val] = (testFunction != null) ? testFunction : 'default';
                updateEmphasizer();
            }
        }
        
        
        public function deemphasize(val:String):void {
            if (val.length >= 1) {
                delete emphasizeList[val];
                updateEmphasizer();
            }
        }
        
        
        public function emphasizerReset():void {
            emphasizeList = new Dictionary();
            updateEmphasizer();
        }
        
        
        /**
         * Runs the emphasizer effect.
         */
        public function updateEmphasizer():void {
            if (vis==null || vis.data==null) return;
            var emphasizer_default:DataList = new DataList('emphasizer_default');
            vis.data.nodes.visit(function(d:DataSprite):void {
                for (var elem:String in emphasizeList) {
                    if (emphasizeList[elem] is Function) {
                        if (emphasizeList[elem](d)) {
                            emphasizer_default.add(d);
                        }
                    } else if (((d as NodeSprite).depth > 0) && (d.data.name !== undefined) && d.data.name.toLowerCase().indexOf(elem.toLowerCase()) != -1)
                        emphasizer_default.add(d);
                    
                    //Add all nodes whose parent nodes are emphasized
                    if (emphasizer_default.contains((d as NodeSprite).parentNode))
                        emphasizer_default.add(d);
                }
            });
            
            vis.data.addGroup('emphasizer_default', emphasizer_default);
            _extraOperatorsChanged = true;
            invalidateProperties();
        }
        
        
        //------------------------------
        // colors
        //------------------------------
        
        
        /**
         * Preferred min and max colors for the color encoder
         */
        private var _preferredMinColor:Number = NaN;
        
        private var _preferredMaxColor:Number = NaN;
        
        /**
         * Specifies the minimum value used
         * to encode a treemap rectangle's color.
         *
         * @default "color"
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set preferredMinColor(property:Number):void {
            _preferredMinColor = property;
            _colorEncodingUpdated = true;
            invalidateProperties();
        }
        
        /**
         * @private
         */
        public function get preferredMinColor():Number {
            return _preferredMinColor;
        }
        
        /**
         * Specifies the maximum used
         * to encode a treemap rectangle's color.
         *
         * @default "color"
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set preferredMaxColor(property:Number):void {
            _preferredMaxColor = property;
            _colorEncodingUpdated = true;
            invalidateProperties();
        }
        
        /**
         * @private
         */
        public function get preferredMaxColor():Number {
            return _preferredMaxColor;
        }
        
        /**
         * Get the Flare ColorEncoder
         */
        public function getColorEncoder():ColorEncoder {
            return vis.operators.getOperatorAt(OP_IX_COLOR) as ColorEncoder;
        }
        
        
        /**
         * @private
         */
        override protected function commitProperties():void {
            super.commitProperties();
            
            var updateTreemap:Boolean = false;
            
            if (vis) {
                const colorEncoder:Encoder = vis.operators.getOperatorAt(OP_IX_COLOR) as Encoder;
                const treeMapLayout:TreeMapLayout = vis.operators.getOperatorAt(OP_IX_LAYOUT) as TreeMapLayout;
                const labels:Labels = vis.operators.getOperatorAt(OP_IX_LABEL) as Labels;
                
                if (_colorEncodingUpdated) {
                    _colorEncodingUpdated = false;
                    
                    colorEncoder.source = asFlareProperty(_colorEncodingField);
                    colorEncoder.palette = colorPalette;
                    if (!isNaN(preferredMinColor))
                        colorEncoder.scale.preferredMin = preferredMinColor;
                    if (!isNaN(preferredMaxColor))
                        colorEncoder.scale.preferredMax = preferredMaxColor;
                    
                    updateTreemap = true;
                }
                
                if (_layoutStyleChanged) {
                    _layoutStyleChanged = false;
                    
                    styleNodes();
                    
                    updateTreemap = true;
                }
                
                if (_sizeEncodingUpdated) {
                    _sizeEncodingUpdated = false;
                    
                    treeMapLayout.sizeField = asFlareProperty(_sizeEncodingField);
                    
                    updateTreemap = true;
                }
                
                if (_maxDepthUpdated) {
                    _maxDepthUpdated = false;
                    
                    treeMapLayout.maxDepth = maxDepth;
                    
                    updateTreemap = true;
                }
                
                if (_labelEncodingUpdated) {
                    _labelEncodingUpdated = false;
                    
                    labels.source = asFlareProperty(_labelEncodingField);
                    
                    updateTreemap = true;
                }
                
                if (_labelStyleChanged || _labelDepthUpdated) {
                    var lfr:PLabelFormatter;
                    
                    if (_labelStyleChanged) {
                        _labelStyleChanged = false;
                        _labelDepthUpdated = false;
                        
                        lfr = new PLabelFormatter(this, _minLabelDepth + (dataRoot != null ? dataRoot.depth : 0), _maxLabelDepth + (dataRoot != null ? dataRoot.depth : 0));
                        labels.labelFormatter = lfr;
                    } else if (_labelDepthUpdated) {
                        _labelDepthUpdated = false;
                        lfr = labels.labelFormatter as PLabelFormatter;
                        lfr.minLabelDepth = _minLabelDepth + (dataRoot != null ? dataRoot.depth : 0);
                        lfr.maxLabelDepth = _maxLabelDepth + (dataRoot != null ? dataRoot.depth : 0);
                    }
                    labels.colorStrategy = getStyle('labelColorStrategy');
                    
                    updateTreemap = true;
                }
                
                if (_nodeStyleUpdated) {
                    _nodeStyleUpdated = false;
                    vis.data.nodes.visit(function(d:DataSprite):void {
                        d.filters = nodeFlashFilters;
                    });
                    updateTreemap = true;
                }
                
                if (_leavesChanged) {
                    _leavesChanged = false;
                    calculateLeaves();
                    updateTreemap = true;
                }
                
                if (_truncatePropertyChanged) {
                    _truncatePropertyChanged = false;
                    
                    labels.truncateToFit = _truncateToFit;
                    
                    updateTreemap = true;
                }
                
                if (_extraOperatorsChanged) {
                    _extraOperatorsChanged = false;
                    updateTreemap = true;
                }
                
                if (this.data is Tree) {
                    styleNodes();
                    if (newDataLoaded) {
                        newDataLoaded = false;
                        
                        vis.data.edges.setProperty("visible", false);
                        
                        updateTreemap = true;
                    }
                    
                    if (dataRootChanged) {
                        updateTreemap = true;
                        dataRootChanged = false;
                        dispatchEvent(new JuiceKitEvent(JuiceKitEvent.DATA_ROOT_CHANGE));
                    }
                    
                    if (updateTreemap) {
                        updateVisualization();
                    }
                }
            }
        }
        
        //----------------------------------------
        // data and dataRoot
        //----------------------------------------
        
        
        /**
         * Holds reference to flag indicating the data root was changed.
         */
        private var dataRootChanged:Boolean = false;
        
        
        /**
         * Holds the depth of the current data root. Used for to calculate
         * styling if styleFromDataRoot is true
         */
        private var rootDepth:int = 0;
        
        
        /**
         * Are node line width and line color (strokeColors, strokeThickness,
         * strokeAlpha) styling based the depth from the data root
         * or from the base of the tree.
         */
        public var styleFromDataRoot:Boolean = false;
        
        
        /**
         * Sets the a data set's <code>root</code> reference to the
         * <code>nodeSprite</code> parameter.
         *
         * @param nodeSprite Reference to a <code>NodeSprite</code> within
         * the <code>data</code> property current instance.
         */
        [Bindable(event="dataRootChange")]
        public function set dataRoot(nodeSprite:NodeSprite):void {
            if (!nodeSprite) {
                throw new ArgumentError("NodeSprite must exist within the data tree.");
            }
            if (vis && vis.tree) {
                rootDepth = nodeSprite.depth;
                const labels:Labels = vis.operators.getOperatorAt(OP_IX_LABEL) as Labels;
                
                // if data has already been set and the developer has not
                // requested a _freezeColor state
                if (vis.data != null && _freezeColorRequest == null) {
                    _doFreezeColors(freezeColorsOnDataRootChange);
                }
                
                vis.tree.nodes.setProperty("visible", false);
                // Set the old labels invisible
                labels.setLabelVisible(dataRoot, false, maxDepth);
                vis.tree.selectedRoot = nodeSprite;
                // Make the new labels visible
                labels.setLabelVisible(dataRoot, true, maxDepth);
                
                dataRootChanged = true;
                _leavesChanged = true;
                _labelDepthUpdated = true;
                invalidateProperties();
            } else {
                throw new ArgumentError("A visualization must already have data to manipulate the root.");
            }
        }
        
        
        /**
         * @private
         */
        public function get dataRoot():NodeSprite {
            if (vis && vis.data) {
                if (vis.tree.selectedRoot)
                    return vis.tree.selectedRoot;
                else
                    return vis.tree.root;
            }
            return null;
        }
        
        
        /**
         * Flag whether a new data set is loaded or not.
         */
        private var newDataLoaded:Boolean = false;
        
        
        /**
         * Sets the data value to a <code>Tree</code> data
         * object used for rendering the size and color attributes
         * of the treemap visualization.
         *
         * @see flare.vis.data.Tree
         */
        override public function set data(value:Object):void {
            value = value is Tree ? value : null;
            newDataLoaded = value !== this.data;
            
            if (newDataLoaded) {
                // if data has already been set and the developer has not
                // requested a _freezeColor state
                if (vis.data != null && _freezeColorRequest == null) {
                    _doFreezeColors(freezeColorsOnDataChange);
                }
                vis.data = value as Tree;
                super.data = value;
                dataRootChanged = true;
            }
            
            _leavesChanged = true;
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        override public function get data():Object {
            return super.data;
        }
        
        
        //----------------------------------------
        // leaf and branch calculations
        //----------------------------------------
        
        /**
         * @private
         *
         * Calculate leaves and branches groups
         *
         * Leaves are displayed while branches are hidden.
         */
        private function calculateLeaves():void {
            if (vis.data) {
                var leaves:DataList = new DataList('leaves');
                var branches:DataList = new DataList('branches');
                var visible_nodes:DataList = new DataList('visible_nodes');
                
                vis.tree.nodes.setProperty("visible", false);
                vis.tree.selectedRoot.visitTreeDepthFirst(function(d:DataSprite):void {
                    var nodeDepth:int = int((d as NodeSprite).depth) - int(dataRoot.depth);
                    d.visible = true;
                    if (nodeDepth < 0)
                        d.visible = false;
                    else if ((d as NodeSprite).data[_sizeEncodingField] as Number <= 0)
                        //This is a bugfix that prevents nodes from lingering on screen when the
                        //size field changes from one with a value to one with zero.
                        d.visible = false;
                    else if (nodeDepth == maxDepth || (nodeDepth < maxDepth && (d as NodeSprite).childDegree == 0)) {
                        leaves.add(d);;
                        visible_nodes.add(d);
                    } else if (nodeDepth < maxDepth) {
                        branches.add(d);
                        visible_nodes.add(d);
                    }
                    else
                        d.visible = false;
                }, false, maxDepth);
                
                vis.data.addGroup('leaves', leaves);
                vis.data.addGroup('branches', branches);
                vis.data.addGroup('visible_nodes', visible_nodes);
                updateEmphasizer();
            }
        }
        
        /**
         * Do the leaves and branches need to be recalculated.
         */
        private var _leavesChanged:Boolean = false;
        
        
        //----------------------------------------
        // color
        //----------------------------------------
        
        /**
         * Return a color palette for interpolating color values
         * from the <code>colorEncodingField</code>'s data value.
         */
        protected function get colorPalette():ColorPalette {
            const alphaBits:uint = numToAlphaBits(getStyle("encodedColorAlpha"));
            const minColor:uint = getStyle("minEncodedColor") | alphaBits;
            const midColor:uint = getStyle("midEncodedColor") | alphaBits;
            const maxColor:uint = getStyle("maxEncodedColor") | alphaBits;
            if (rawColorPalette == null) {
                return ColorPalette.diverging(minColor, midColor, maxColor);
            } else {
                return ColorPalette.fromString(rawColorPalette);
            }
        }
        
        /**
         * The color palette set by the user. This is evaluated into a
         * ColorPalette with ColorPalette.fromString()
         *
         * @see flare.util.palette.ColorPalette;
         */
        private var rawColorPalette:* = null;
        
        [Bindable]
        public function set palette(v:*):void {
            if (v != null && v !== this.palette) {
                rawColorPalette = v;
                _colorEncodingUpdated = true;
                invalidateProperties();
            }
        }
        
        public function get palette():* {
            return rawColorPalette;
        }
        
        
        /**
         * Disable color scale updates, for instance when drilling
         * through the treemap
         */
        [Inspectable(type=Boolean)]
        public function set freezeColors(v:Boolean):void {
            _freezeColorRequest = v;
            _doFreezeColors(v);
        }
        
        
        public function get freezeColors():Boolean {
            const colorEncoder:Encoder = vis.operators.getOperatorAt(OP_IX_COLOR) as Encoder;
            return colorEncoder.scale.ignoreUpdates;
        }
        
        
        private function _doFreezeColors(v:Boolean):void {
            const colorEncoder:Encoder = vis.operators.getOperatorAt(OP_IX_COLOR) as Encoder;
            colorEncoder.scale.ignoreUpdates = v;
        }
        
        /**
         * Have the colors been frozen at the developers request?
         *
         * @default null, the user has not specified a desired
         * freezeColors state
         */
        private var _freezeColorRequest:Object = null;
        
        
        /**
         * Freeze the color range when the data root changes.
         *
         * If true, colors will be frozen when the data root changes.
         *
         * If false, colors will be unfrozen and the color scale
         * will be recalculated when the data root changes.
         *
         * @default true
         */
        public var freezeColorsOnDataRootChange:Boolean = true;
        
        /**
         * Recalculate the color range when the data changes.
         *
         * If true, colors will be frozen when the data changes.
         *
         * If false, the color scale will be recalculated
         * when the data changes.
         *
         * @default false
         */
        public var freezeColorsOnDataChange:Boolean = false;
        
        
        /**
         * Apply a scale to the color encoder.
         */
        private function setupColorEncoder(colorEncoder:Encoder):void {
            // Null assignment forces the scale min or max to use minumum or
            // maximum values from the data.
            colorEncoder.scale.preferredMin = isNaN(_minColorNumber) ? null : _minColorNumber;
            colorEncoder.scale.preferredMax = isNaN(_maxColorNumber) ? null : _maxColorNumber;
        }
        
        
        /**
         * Store the colorEncodingField property.
         */
        private var _colorEncodingField:String = "color";
        private var _colorEncodingUpdated:Boolean = false;
        
        
        /**
         * Specifies a data <code>Object</code> property's name used
         * to encode a treemap rectangle's color.
         *
         * @default "color"
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set colorEncodingField(propertyName:String):void {
            _colorEncodingField = propertyName;
            _colorEncodingUpdated = true;
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        public function get colorEncodingField():String {
            return _colorEncodingField;
        }
        
        /**
         * Maximum depth for visibility in treemap
         */
        private var _maxDepth:int = 100;
        private var _maxDepthUpdated:Boolean = false;
        
        
        [Inspectable(category="General")]
        [Bindable]
        public function set maxDepth(value:int):void {
            _maxDepth = value;
            _maxDepthUpdated = true;
            _colorEncodingUpdated = true;
            if (vis && vis.data != null) {
                _leavesChanged = true;      
                invalidateProperties();
            }
        }
        
        
        public function get maxDepth():int {
            return _maxDepth;
        }
        
        
        /**
         * Stores the color mapping range properties.
         */
        private var _minColorNumber:Number = NaN;
        private var _maxColorNumber:Number = NaN;
        
        
        /**
         * Sets a specific numeric range used to map <code>data</code> values
         * to color values where data values less than <code>min</code> are mapped
         * to <code>minEncodedColor</code> and data values greater than
         * <code>max</code> are mapped to <code>maxEncodedColor</code>.
         *
         * @param min Contains the smallest data value to encode
         * to a color.
         *
         * @param max Contains the largest data value to encode
         * to a color.
         */
        public function setColorScaleRange(min:Number, max:Number):void {
            _minColorNumber = min;
            _maxColorNumber = max;
            _colorEncodingUpdated = true;
            invalidateProperties();
        }
        
        
        /**
         * Forces the color mapping range to be determined by the minimum
         * and maximum <code>data</code> values. This is the default algorithm for
         * <code>TreeMapControl</code> instances.
         */
        public function unsetColorScaleRange():void {
            _minColorNumber = NaN;
            _maxColorNumber = NaN;
            _colorEncodingUpdated = true;
            invalidateProperties();
        }
        
        
        //----------------------------------------
        // size
        //----------------------------------------
        
        /**
         * Store the sizeEncodingField property.
         */
        private var _sizeEncodingField:String = "size";
        private var _sizeEncodingUpdated:Boolean = false;
        
        
        /**
         * Specifies a data <code>Object</code> property's name used
         * to encode a treemap rectangle's visual size.
         *
         * @default "size"
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set sizeEncodingField(propertyName:String):void {
            _sizeEncodingField = propertyName;
            _sizeEncodingUpdated = true;
            _colorEncodingUpdated = true;
            if (vis && vis.data != null)
                _leavesChanged = true;
            
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        public function get sizeEncodingField():String {
            return _sizeEncodingField;
        }
        
        
        //----------------------------------------
        // labels
        //----------------------------------------
        
        /**
         * Store the labelEncodingField property.
         */
        private var _labelEncodingField:String = "label";
        private var _labelEncodingUpdated:Boolean = false;
        
        
        /**
         * Specifies a data <code>Object</code> property's name used
         * to encode a treemap rectangle's label.
         *
         * @default "label"
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set labelEncodingField(propertyName:String):void {
            _labelEncodingField = propertyName;
            _labelEncodingUpdated = true;
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        public function get labelEncodingField():String {
            return _labelEncodingField;
        }
        
        
        private var _labelDepthUpdated:Boolean = false;
        
        /**
         * Stores the minLabelDepth property.
         */
        private var _minLabelDepth:int = 1;
        
        
        /**
         * Sets the minimum hierarchy depth that labels will be applied
         * to the visualization's rectangles. The default is <code>-1</code>
         * indicating there is no minimum.
         *
         * @default -1
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set minLabelDepth(value:int):void {
            _minLabelDepth = value;
            _labelDepthUpdated = true;
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        public function get minLabelDepth():int {
            return _minLabelDepth;
        }
        
        
        /**
         * Stores the maxLabelDepth property.
         */
        private var _maxLabelDepth:int = 1;
        
        
        /**
         * Sets the maximum hierarchy depth that labels will be applied
         * to the visualization's rectangles. The default is <code>-1</code>
         * indicating there is no maximum.
         *
         * @default -1
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set maxLabelDepth(value:int):void {
            _maxLabelDepth = value;
            _labelDepthUpdated = true;
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        public function get maxLabelDepth():int {
            return _maxLabelDepth;
        }
        
        
        private var _truncatePropertyChanged:Boolean = false;
        
        /**
         * Store the truncateToFit property.
         */
        private var _truncateToFit:Boolean = false;
        
        
        /**
         * Specifies whether label strings should be truncated to fit within its
         * rectangle's width.
         *
         * @default false
         */
        [Inspectable(category="General")]
        [Bindable]
        public function set truncateToFit(flag:Boolean):void {
            _truncateToFit = flag;
            _truncatePropertyChanged = true;
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        public function get truncateToFit():Boolean {
            return _truncateToFit;
        }
        
        
        // Assign constants for visualization operator positions.
        private static const OP_IX_COLOR:int = 0;
        private static const OP_IX_LAYOUT:int = 1;
        private static const OP_IX_LABEL:int = 2;
        
        private static const OP_IX_EMPHASIZER:int = 4;
        
        
        /**
         * @private
         */
        override protected function initVisualization():void {
            // Create an empty initial bounds.
            vis.bounds = new Rectangle(0, 0, 0, 0);
            
            // Initialize rendering pipeline
            
            vis.operators.add(createColorEncoder());
            vis.operators.add(createTreeMapLayout());
            vis.operators.add(createLabelLayout());
            vis.operators.add(new PropertyEncoder({fillAlpha: 0.01}, 'branches'));
            vis.operators.add(new PropertyEncoder(defaultEmphasizeEffect, 'emphasizer_default'));
            createExtraOperators();
            
            super.initVisualization();
        }
        
        
        private function createExtraOperators():void {
            // Pop off all the extra operators
            while (vis.operators.length > 5) {
                vis.operators.removeOperatorAt(vis.operators.length - 1);
            }
            // add all the extra operators back in
            for each (var op:Operator in extraOperators) {
                vis.operators.add(op);
            }
        }
        
        
        /**
         * Extra operators to include in the visualization.
         *
         * @param v an array of Flare Operator classes that will be
         * added after the core operators needed to create the treemap.
         *
         */
        public function set extraOperators(v:Array):void {
            _extraOperators = v;
            createExtraOperators();
            _extraOperatorsChanged = true;
            invalidateProperties();
        }
        
        
        /**
         * @private
         */
        public function get extraOperators():Array {
            return _extraOperators;
        }
        
        /**
         * Stores the extra operators
         */
        private var _extraOperators:Array = [];
        
        /**
         * Flag that indicates whether the extra operators have
         * been changed
         */
        private var _extraOperatorsChanged:Boolean = false;
        
        
        /**
         * Return a ARGB color value for a given depth.
         */
        private static function computeARGB(rgbColors:Array, alphas:Array, depth:uint):uint {
            if (!alphas) {
                alphas = [];
                for each (var o:Object in rgbColors) {
                    alphas.push(1);
                }
            }
            const alphaBits:uint = numToAlphaBits(alphas[Math.min(alphas.length - 1, depth)]);
            const rgbColor:uint = rgbColors[Math.min(rgbColors.length - 1, depth)];
            return rgbColor | alphaBits;
        }
        
        
        /**
         * An array of Flash filters to apply to each node.
         */
        public function set nodeFlashFilters(v:Array):void {
            _nodeFlashFilters = v;
            _nodeStyleUpdated = true;
            invalidateProperties();
        }
        
        
        public function get nodeFlashFilters():Array {
            return _nodeFlashFilters;
        }
        
        /**
         * Stores the node flash filters
         */
        private var _nodeFlashFilters:Array = [];
        private var _nodeStyleUpdated:Boolean = false;
        
        
        /**
         * Apply node stylings to each NodeSprite.
         */
        private function styleNodes():void {
            // Guard against data not being available.
            if (!vis || !vis.data)
                return;
            
            const alphas:Array = getStyle("strokeAlphas");
            const colors:Array = getStyle("strokeColors");
            
            const lineWidths:Array = getStyle("strokeThicknesses");
            const lastIxLineWidths:uint = lineWidths.length - 1;
            
            var adjustedDepth:int = 0;
            vis.tree.nodes.visit(function(n:NodeSprite):void {
                if (styleFromDataRoot) {
                    adjustedDepth = Math.max(0, n.depth - rootDepth);
                } else {
                    adjustedDepth = n.depth;
                }
                n.lineWidth = lineWidths[Math.min(lastIxLineWidths, adjustedDepth)];
                // Hide zero-width lines.
                if (n.lineWidth === 0) {
                    n.lineAlpha = 0;
                } else {
                    n.lineColor = computeARGB(colors, alphas, adjustedDepth);
                }
            });
        }
        
        
        /*
        * Create a brightness filter to highlight the current
        * mouse cursor position on an treemap instance.
        */
        private static const brightnessMatrix:Array = [1, 0, 0, 0, 30, 0, 1, 0, 0, 30, 0, 0, 1, 0, 30, 0, 0, 0, 1, 0];
        private static const brightnessFilter:ColorMatrixFilter = new ColorMatrixFilter(brightnessMatrix);
        
        /*
        * Internal property name used to preserve node filters prior
        * to applying the brightness filter.
        */
        private static const FILTERS_PROP:String = "#FILTERS#";
        
        
        /**
         * @inheritDoc
         */
        override protected function onMouseOut(event:MouseEvent):void {
            super.onMouseOut(event);
            
            const ns:NodeSprite = event.target as NodeSprite;
            if (ns) {
                if (ns.props.hasOwnProperty(FILTERS_PROP)) {
                    ns.filters = ns.props[FILTERS_PROP];
                    delete ns.props[FILTERS_PROP];
                } else if (ns.filters && ns.filters.length > 0) {
                    ns.filters = [];
                }
            }
        }
        
        
        /**
         * @inheritDoc
         */
        override protected function onMouseOver(event:MouseEvent):void {
            super.onMouseOver(event);
            
            const ns:NodeSprite = event.target as NodeSprite;
            if (ns !== null && ns.childDegree == 0 && highlightRollOver) {
                if (ns.filters && ns.filters.length > 0) {
                    ns.props[FILTERS_PROP] = ns.filters;
                    ns.filters.push(brightnessFilter);
                    ns.filters = ns.filters;
                } else {
                    ns.filters = [brightnessFilter];
                }
            }
        }
        
        
        [Inspectable(category="General")]
        /**
         * Specifies whether the TreeMapControl should provide a highlighting
         * effect on mouse roll-over. The effect is to increase the brightness
         * of the rectangle color.
         *
         * @default true
         */
        public var highlightRollOver:Boolean = true;
        
        
        private function createColorEncoder():ColorEncoder {
            return new ColorEncoder(asFlareProperty(_colorEncodingField), freezeColorsOnDataRootChange ? 'leaves' : 'leaves', "fillColor", ScaleType.LINEAR_PERCENTILE10, colorPalette);
        }
        
        
        private function createTreeMapLayout():Operator {
            return new TreeMapLayout(asFlareProperty(sizeEncodingField), maxDepth);
        }
        
        
        private function createLabelLayout():Operator {
            const lfr:PLabelFormatter = new PLabelFormatter(this, _minLabelDepth + (dataRoot != null ? dataRoot.depth : 0), _maxLabelDepth + (dataRoot != null ? dataRoot.depth : 0));
            return new Labels(asFlareProperty(_labelEncodingField), 'visible_nodes', lfr, _truncateToFit, getStyle('labelColorStrategy'));
        }
        
    }
}


/**
 * @private
 */

import flare.vis.data.DataSprite;
import flare.vis.data.NodeSprite;

import mx.core.UIComponent;

import org.juicekit.flare.label.ILabelFormatter;
import org.juicekit.flare.label.LabelFormat;

class PLabelFormatter implements ILabelFormatter {
    public var fmt:LabelFormat;
    public var minLabelDepth:int;
    public var maxLabelDepth:int;
    
    
    public function PLabelFormatter(component:UIComponent, minLabelDepth:int, maxLabelDepth:int) {
        this.minLabelDepth = minLabelDepth;
        this.maxLabelDepth = maxLabelDepth;
        
        const fontColor:uint = component.getStyle("fontColor");
        const fontFamily:String = component.getStyle("fontFamily");
        const fontSize:Number = component.getStyle("fontSize");
        const fontStyle:String = component.getStyle("fontStyle");
        const fontWeight:String = component.getStyle("fontWeight");
        const textAlign:String = component.getStyle("textAlign");
        const textPosition:String = component.getStyle("textPosition");
        
        fmt = new LabelFormat(fontFamily, fontSize, fontColor, fontWeight === "bold", fontStyle === "italic");
        switch (textAlign) {
            case "left":
                fmt.horizontalAnchor = LabelFormat.LEFT;
                break;
            case "center":
                fmt.horizontalAnchor = LabelFormat.CENTER;
                break;
            case "right":
                fmt.horizontalAnchor = LabelFormat.RIGHT;
                break;
        }
        switch (textPosition) {
            case "top":
                fmt.verticalAnchor = LabelFormat.TOP;
                break;
            case "middle":
                fmt.verticalAnchor = LabelFormat.MIDDLE;
                break;
            case "bottom":
                fmt.verticalAnchor = LabelFormat.BOTTOM;
                break;
        }
    }
    
    
    public function labelFormat(dataSprite:DataSprite):LabelFormat {
        const depth:int = (dataSprite as NodeSprite).depth;
        if ((minLabelDepth === -1 || depth >= minLabelDepth) && (maxLabelDepth === -1 || depth <= maxLabelDepth)) {
            return fmt;
        }
        return null;
    }
}
