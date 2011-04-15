/*
* -*- Mode: Actionscript -*-
* *************************************************************************
*
* Copyright 2007-2009 Juice, Inc.
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
*
* *************************************************************************
*/

package org.juicekit.controls {
	import flare.display.DirtySprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.juicekit.animate.TransitionEvent;
	import org.juicekit.events.DataMouseEvent;
	import org.juicekit.util.Property;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;



	
	/**
	 *
	 * The <code>TreeMapZoomControl</code> class provides a zoom-in/out
	 * companion control for the <code>TreeMapControl</code>. Clicks on a
	 * <code>TreeMapControl</code> cause the focus to zoom into branch nodes of
	 * treemap. Clicks on the <code>TreeMapZoomControl</code> button path
	 * zoom-out to the corresponding branch nodes.
	 *
	 * @see org.juicekit.visual.controls.TreeMapControl
	 *
	 * @author Shalini Kataria
	 */
	public class SparkTreeMapZoomControl extends HGroup {
		/**
		 * This array contains all the Nodesprites from the root node to the current node.
		 */
		private var pathNodes:Array;
		
		/**
		 * Contains the LinkButton View from the root node to the current node.
		 */
		private var breadcrumbs:Array;
		
		/**
		 * Contains the root node in the treemap data.
		 */
		private var rootNode:NodeSprite;
		
		/**
		 * Watches the "data" property of Treemap.
		 */
		private var treemapDataWatcher:ChangeWatcher;
		
		/**
		 * Watches the "labelEncodingField" property of the Treemap.
		 */
		private var lblEncFieldWatcher:ChangeWatcher;
		
		/**
		 * Holds the "labelEncodingField" of the treemap control.
		 */
		public var labelField:String;
		
		
		/**
		 * Constructor.
		 */
		public function SparkTreeMapZoomControl()
		{
			super(); 
			this.setStyle("verticalAlign", "middle");
			breadcrumbs = new Array();
		}
		
		
		/**
		 * Zoom the treemap on a click
		 * 
		 * @default true
		 */
		public var zoomOnClick:Boolean = true;
		
		/**
		 * Zoom the treemap on a double click
		 * 
		 * @default false
		 */
		public var zoomOnDoubleClick:Boolean = false;
		
		
		/**
		 * Store the "tree" property.
		 */
		private var _tree:TreeMapControl;
		
		/**
		 * References the companion <code>TreeMapControl</code>.
		 *
		 * @see org.juicekit.visual.controls.TreeMapControl
		 */
		public function set tree(treemap:TreeMapControl):void
		{
			if (treemap === _tree) return;
			
			if (_tree) {
				resetView();
				// Unhook _tree.
				_tree.removeEventListener(DataMouseEvent.CLICK, onClickTreeMapControl);
				_tree.removeEventListener(DataMouseEvent.DOUBLE_CLICK, onClickTreeMapControl);
				
				if (treemapDataWatcher) {
					treemapDataWatcher.unwatch();
					treemapDataWatcher = null;
				}
				if (lblEncFieldWatcher) {
					lblEncFieldWatcher.unwatch();
					lblEncFieldWatcher = null;
				}
			}
			
			_tree = treemap;
			
			if (_tree) {
				_tree.doubleClickEnabled = true;
				// Hook _tree.
				_tree.addEventListener(DataMouseEvent.CLICK, onClickTreeMapControl, false, 0, true);
				_tree.addEventListener(DataMouseEvent.DOUBLE_CLICK, onClickTreeMapControl, false, 0, true);
				treemapDataWatcher = ChangeWatcher.watch(_tree, "data", onTreeDataChanged);
				lblEncFieldWatcher = BindingUtils.bindProperty(this, "labelField", _tree, "labelEncodingField");
			}
		}
		
		/**
		 * @private
		 */
		public function get tree():TreeMapControl
		{
			return _tree;
		}
		
		
		/**
		 * This is the event handler defined by the changeWatcher.
		 * It is executed whenever the data for treemap is updated.
		 */
		public function onTreeDataChanged(event:FlexEvent):void
		{
			if (tree.data == null) {
				resetView();
			}
			if (tree.dataRoot != null) {
				this.rootNode = tree.dataRoot; //update the rootNode to point to the dataRoot of this new data set
				gotoNode(rootNode);
			}
		}
		
		
		/**
		 * This event handler is executed when a click or double click event occurs on a treemap.
		 * It updates the path to the target node.
		 */
		private function onClickTreeMapControl(event:DataMouseEvent):void
		{
			if (event.type == DataMouseEvent.CLICK && !zoomOnClick) return;
			if (event.type == DataMouseEvent.DOUBLE_CLICK && !zoomOnDoubleClick) return;
				
			gotoNode(event.sender as NodeSprite);
			beginTransition();
		}
		
		
		/**
		 * Handles the click event on the LinkButtons.
		 * It zooms-out of the treemap to the clicked LinkButton(nodeSprite).
		 */
		private function onClickZoomOut(event:MouseEvent):void
		{
			// Map button to node sprite.
			const ix:int = breadcrumbs.indexOf(event.target);
			callLater(function():void
			{
				zoomToTargetNode(pathNodes[ix]);
				beginTransition();
			});
		}
		
		
		/**
		 * Provide transition effects for zooming into and out of
		 * the TreeMapControl.
		 */
		private function beginTransition():void
		{
			// Make fancy with the animation.
			_tree.addEventListener(TransitionEvent.END, onEndTransition, false, 0, true);
		}
		
		
		private function onEndTransition(event:TransitionEvent):void
		{
			_tree.removeEventListener(TransitionEvent.END, onEndTransition);
			
			// Force flare to render everything.
			// This prevents some visual errors where the boxes haven't fully
			// animated to their end positions
			callLater(function():void
			{
				DirtySprite.renderDirty();
			});
		}
		
		
		/**
		 * Called with the rootNode whenever data is modified and
		 * is called with the clicked node when treemap is clicked.
		 */
		private function gotoNode(node:NodeSprite):void
		{
			const targetDepth:uint = breadcrumbs.length + 1;
			const targetNode:NodeSprite = getParentNode(node, targetDepth);
			zoomToTargetNode(targetNode);
		}
		
		
		/**
		 * Gets the correct node to zoom-in to.
		 */
		private function getParentNode(node:NodeSprite, atDepth:uint):NodeSprite
		{
			var retVal:NodeSprite = node;
			while (retVal.depth > atDepth) {
				retVal = retVal.parentNode;
			}
			return retVal;
		}
		
		
		/**
		 * Zoom into the node.
		 *
		 * If the node doesn't have any children, zooming is disabled
		 */
		private function zoomToTargetNode(targetNode:NodeSprite):void
		{
			if (targetNode.childDegree == 0) {
				return;
			}
			const prop:Property = Property.$("data." + labelField);
			_tree.dataRoot = targetNode; //update the treemap view
			resetView();
			pathNodes = makeNodePath(rootNode, targetNode);
			breadcrumbs = makePathView(pathNodes, targetNode, prop);
		}
		
		
		/**
		 * Populates an array with all the nodesprites from the root node to the target node.
		 */
		private function makeNodePath(fromNode:NodeSprite, toNode:NodeSprite):Array
		{
			var nodePathArray:Array;
			var ix:int;
			
			if (toNode !== fromNode) {
				// Construct a path from node to root.
				nodePathArray = new Array(toNode.depth);
				ix = 0;
				while (toNode.parentNode) {
					nodePathArray[ix++] = toNode.parentNode;
					toNode = toNode.parentNode;
				}
				
				// Transform the path to root to node.
				nodePathArray = nodePathArray.reverse();
			}
			else {
				// Empty path.
				nodePathArray = new Array();
			}
			return nodePathArray;
		}
		
		
		/**
		 * This function makes a VIEW (interface) containing LinkButtons for
		 * all the path nodes in the array.
		 */
		private function makePathView(pathNodes:Array, hereNode:NodeSprite, labelProp:org.juicekit.util.Property):Array
		{
			// Return button mapping list.
			const retVal:Array = new Array(pathNodes.length);
			
			var retValIx:int = 0;
			
			// Create path buttons.
			var label:Label;
			for each (var node:NodeSprite in pathNodes) {
				label = new Label();
				label.addEventListener(MouseEvent.ROLL_OVER, highlightLabel);
				label.addEventListener(MouseEvent.ROLL_OVER, noHighlightLabel);
				label.text = labelProp.getValue(node);
				label.styleName = "treeMapZoomButton";
				label.addEventListener(MouseEvent.CLICK, onClickZoomOut, false, 0, true);
				this.addElement(label);
				
				retVal[retValIx++] = label;
			}
			
			// Create "Here" label.
			label = new Label();
			label.text = labelProp.getValue(hereNode);
			label.mouseEnabled = false;
			label.mouseChildren = false;
			label.styleName = "treeMapZoomCurrentLabel";
			this.addElement(label);
			
			return retVal;
		}
		
		
		private function highlightLabel(e:MouseEvent):void {
			(e.currentTarget as Label).setStyle('textDecoration', 'underline');
		}
		
		
		private function noHighlightLabel(e:MouseEvent):void {
			(e.currentTarget as Label).setStyle('textDecoration', 'underline');
		}
		
		/**
		 * Removes all elements from this control while
		 * removing event listeners.
		 */
		private function resetView():void
		{
			var child:IVisualElement;
						
			while (numElements > 0) {
				child = getElementAt(0);
				if (child.hasEventListener(MouseEvent.CLICK)) {
					child.removeEventListener(MouseEvent.CLICK, onClickZoomOut);
				}
				this.removeElementAt(0);
			}
		}
		
		
		/**
		 * This function returns the depth (number of LinkButtons) of this control.
		 */
		public function get zoomDepth():uint
		{
			return breadcrumbs.length;
		}
	}
}
