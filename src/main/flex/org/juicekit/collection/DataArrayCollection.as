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

package org.juicekit.collection {
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.DataEvent;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	import mx.utils.UIDUtil;
	
	import org.juicekit.util.Property;
	import org.juicekit.collections.JKArrayCollection;
	
	/**
	 * The DataArrayCollection class is a wrapper class that exposes an ArrayCollection.
	 * Flare Data objects can be created that are synced to the content of the
	 * ArrayCollection. When <code>set source</code> is called on the ArrayCollection,
	 * the Flare Data NodeSprites will be updated according to <code>mergeStrategy</code>.
	 *
	 * A Flare <code>Stats</code> object allows statistics to be accessed for the
	 * wrapped ArrayCollection.
	 *
	 * @author Sal Uryasev
	 * @author Chris Gemignani
	 *
	 **/
	public class DataArrayCollection extends JKArrayCollection {
		public function DataArrayCollection(source:Array = null) {
			super(source);
		}
		
		
		
		//-----------------------
		// key generation
		//-----------------------
		
		/**
		 * A class variable to calculate unique keys
		 */
		private static var keyID:int = 0;
		
		/**
		 * Determines how to find duplicates
		 *
		 * <p>If an Array of Strings are passed in
		 * the Strings are treated as Flare Property lookups.</p>
		 *
		 * <p>If a Function is passed, the function is evaluated
		 * on each object in the list returning a String.</p>
		 */
		public function set keyVars(v:Array):void {
			_keyVars = v;
			_keyLookup = null;
			_keyProperties = v.map(function(element:String, index:int, array:Array):Property {
				return Property.$(element);
			});
			createKey = function(o:Object):String {
				var result:Array = _keyProperties.map(function(prop:Property, index:int, array:Array):String {
					if (prop.getValue(o) === undefined) throw new Error("Data passed to DataArrayCollection always must have the values in keyVars defined.");
					return prop.getValue(o).toString();
				});
				return result.join('#');
			}
		}
		
		public function get keyVars():Array {
			return _keyVars;
		}
		
		private var _keyVars:Array = [];
		private var _keyProperties:Array = [];
		
		
		/**
		 * Create a key for an object in this list
		 *
		 * <p>The default key creation algorithm generates a unique
		 * ID for each element in the list. The key creation algorithm
		 * can be replaced by setting <code>keyVars</code> to an
		 * Array or a Function.</p>
		 */
		private var createKey:Function = defaultCreateKey;
		
		private static var defaultCreateKey:Function = function(itm:Object):String {
			keyID += 1;
			return keyID.toString();
		};
		
		/**
		 * Storage for the keyLookup object
		 */
		private var _keyLookup:Object;
		
		/**
		 * A mapping of keys to Objects that is used to determine
		 * if a new Object should be merged with an existing Object.
		 *
		 */
		private function get keyLookup():Object {
			// regenerate the keyLookup
			if (_keyLookup == null && this.length > 0) {
				_keyLookup = {};
				const len:int = this.length;
				for (var i:int = 0; i < len; i++) {
					var itm:Object = this.list.getItemAt(i);
					_keyLookup[createKey(itm)] = itm;
				}
			}
			return _keyLookup;
		}
		
		/**
		 * Storage for the nodeLookup object
		 */
		private var nodeLookup:Dictionary = new Dictionary();
		
		
		/**
		 * When creating an additional data list, add respective
		 * node lookups for the datalist in question.
		 *
		 * Returns an Array of the added nodes
		 */
		private function addNodeLookup(uid:String):Array {
			var result:Array = [];
			_data[uid].nodes.visit(function(d:DataSprite):void {
				var key:String = createKey(d.data);
				if (nodeLookup[key] === undefined) {
					nodeLookup[key] = {};
				}
				nodeLookup[key][uid] = d;
				result.push(d);
			});
			return result;
		}
		
		
		//-----------------------
		// mergeStrategy
		//-----------------------
		
		/**
		 * Replace contents when <code>source</code> is set.
		 */
		public static const REPLACE:String = 'replace';
		
		/**
		 * Merge new content using <code>keyLookup</code>.
		 * If a key does not exist in the new source, it
		 * will be deleted from the list.
		 */
		public static const REPLACE_MERGE:String = 'replacemerge';
		
		/**
		 * Merge new content using <code>keyLookup</code>.
		 * If a key does not exist in the new source, it
		 * will be retained in the list.
		 */
		public static const MERGE:String = 'merge';
		
		public var mergeStrategy:String = DataArrayCollection.REPLACE;
		
		
		//-----------------------
		// data
		//-----------------------
		
		/** Internal set of data groups. */
		protected var _data:Object = {
		};
		
		/**
		 * Removes a Data object.
		 * @param callingObject the name of the data to remove
		 * @return the removed Flare Data object
		 *
		 * untested
		 */
		public function removeData(callingObject:Object):Data
		{
			var uid:String;
			if (callingObject is String) {
				uid = callingObject as String;
			}
			else {
				uid = UIDUtil.getUID(callingObject);
			}
			var data:Data = _data[uid];
			//Todo: Clearout nodeLookup of the offending uid
			if (data) {
				delete _data[uid];
			}
			return data;
		}
		
		/**
		 * Retrieves the data object with the given name.
		 *
		 * @param callingObject the name of the data
		 * @return the Flare Data object
		 */
		public function data(callingObject:Object):Data
		{
			var uid:String;
			if (callingObject is String) {
				uid = callingObject as String;
			}
			else {
				uid = UIDUtil.getUID(callingObject);
			}
			
			if (_data[uid] === undefined) {
				createNodesFromArrayCollection(uid);
			}
			return _data[uid] as Data;
		}
		
		/**
		 * @private
		 *
		 * Load the Data object with the given name with the node
		 * sprites existing in the DataArrayCollection at this
		 * time.
		 */
		private function createNodesFromArrayCollection(name:String):void {
			if (_data[name] === undefined) {
				_data[name] = new Data();
			}
			var data:Data = _data[name];
			var row:Object;
			var node:NodeSprite;
			var idx:int = 0;
			var len:int = list.length;
			for (idx = 0; idx < len; idx++) {
				row = list.getItemAt(idx);
				node = data.addNode(list.getItemAt(idx));
			}
		}
		
		//-----------------------
		// concurrency control
		//-----------------------
		/**
		 *
		 *
		 *
		 */
		private var _sourceGenerationInProgress:Boolean = false;
		
		private var _sourceGenerationQueue:Array = [];
		
		//-----------------------
		// source
		//-----------------------
		
		
		/**
		 *  The source of data in the ArrayCollection.
		 *  The ArrayCollection object does not represent any changes that you make
		 *  directly to the source array. Always use
		 *  the ICollectionView or IList methods to modify the collection.
		 */
		override public function get source():Array {
			return super.source;
		}
		
		
		/**
		 *  @private
		 */
		override public function set source(s:Array):void {
			if ((mergeStrategy == DataArrayCollection.MERGE || mergeStrategy == DataArrayCollection.REPLACE_MERGE) && (keyVars == null || keyVars.length == 0)) {
				throw new Error("Please set keyVars if choosing the DataArrayCollection.MERGE or DataArrayCollection.REPLACE_MERGE mergeStrategy");
			}
			
			if (_sourceGenerationInProgress) {
				_sourceGenerationQueue.push(s);
				// TODO: Figure out how to add a compiler warning
				trace("Warning: DataArrayCollection source is getting set more than once");
				return;
			}
			else {
				_sourceGenerationInProgress = true;
			}
			
			var doDispatchDataUpdateEvent:Boolean = false;
			var dispatchDataUpdateEventKey:String = '';
			
			var uid:String;
			//      if (s != null) {
			//        trace('setting source for ', s.length, mergeStrategy);
			//      } else {
			//        trace('setting source for null');
			//      }
			var starttime:Number = getTimer();
			
			if (mergeStrategy == DataArrayCollection.REPLACE || length == 0) {
				super.source = s;
				nodeLookup = new Dictionary;
				for (uid in _data) {
					// Delete and recreate all the nodes in the accompanying lists
					(_data[uid] as Data).clear();
					createNodesFromArrayCollection(uid);
					var createdNodeList:Array = addNodeLookup(uid);
					_data[uid].dispatchEvent(new DataEvent(DataEvent.UPDATE, createdNodeList, _data[uid].nodes));
				}
			} else if (mergeStrategy == DataArrayCollection.MERGE || mergeStrategy == DataArrayCollection.REPLACE_MERGE) {
				if (mergeStrategy == DataArrayCollection.REPLACE_MERGE) {
					// clonedKeyLookup keeps track of keys to delete from the
					// final result.
					var clonedKeyLookup:Object = cloneObj(keyLookup) as Object;
				}
				
				var cnt:int = 0;
				for each (var itm:Object in s) {
					cnt += 1;
					var k:String = createKey(itm);
					if (keyLookup[k] !== undefined) {
						if (mergeStrategy == DataArrayCollection.REPLACE_MERGE) {
							delete clonedKeyLookup[k];
						}
						var st:Number = getTimer();
						var existingItm:Object = keyLookup[k];
						// Copy the new object into the old object
						// performing ListCollectionView appropriate
						// itemUpdated
						for (var prop:String in itm) {
							var v:Object = itm[prop];
							var oldv:Object = existingItm[prop];
							if (v != oldv) {
								existingItm[prop] = v;
								list.itemUpdated(existingItm, prop, oldv, v);
								
								// Launch an event for each updated node
								for (uid in _data) {
									if (nodeLookup[k] !== undefined && nodeLookup[k][uid] !== undefined) {
										// Inform the dataList that the node has been updated.
										_data[uid].nodes.update(nodeLookup[k][uid]);
									}
								}
								doDispatchDataUpdateEvent = true;
								dispatchDataUpdateEventKey = k;
							}
						}
					} else {
						list.addItem(itm);
						keyLookup[k] = itm;
						//For each Datalist, create a new node and new node lookup
						//TODO: launch node creation event
						for (uid in _data) {
							var n:NodeSprite = (_data[uid] as Data).addNode(itm);
							if (nodeLookup[k] === undefined) {
								nodeLookup[k] = {};
							}
							nodeLookup[k][uid] = n;
							doDispatchDataUpdateEvent = true;
							dispatchDataUpdateEventKey = k;
						}
						
					}
				}
				
				// If we're doing a replace merge, delete the items
				// that were not found in source.
				if (mergeStrategy == DataArrayCollection.REPLACE_MERGE) {
					for (var idx:int = (list.length - 1); idx >= 0; idx--) {
						var deleteItm:Object = list.getItemAt(idx);
						var deleteKey:String = createKey(deleteItm);
						if (clonedKeyLookup[deleteKey] !== undefined) {
							list.removeItemAt(idx);
							// Delete the appropriate nodesprites from all related lists
							if (nodeLookup[deleteKey] !== undefined) {
								for (uid in nodeLookup[deleteKey]) {
									_data[uid].remove(nodeLookup[deleteKey][uid]);
								}
								delete nodeLookup[deleteKey];
								delete keyLookup[deleteKey];
								
								doDispatchDataUpdateEvent = true;
								dispatchDataUpdateEventKey = k;
							}
						}
					}
				}
				
				if (doDispatchDataUpdateEvent) {
					for (uid in _data) {
						_data[uid].dispatchEvent(new DataEvent(DataEvent.UPDATE, nodeLookup[dispatchDataUpdateEventKey] !== undefined ? nodeLookup[dispatchDataUpdateEventKey][uid] : {}, _data[uid].nodes));
					}
				}
				
				/**
				 * Limit the number of Flare DataEvents dispatched to a single
				 * event.
				 *
				 * Dispatching an event for every change causes performance to
				 * be very slow.
				 */
			}
			
			trace('DataArrayCollection set source: ', (getTimer() - starttime).toString() + 'ms');
			
			// Rerun the source function if we have a queue
			_sourceGenerationInProgress = false;
			if (_sourceGenerationQueue.length > 0) {
				this.source = _sourceGenerationQueue.pop();
			}
			
		}
		
	}
}