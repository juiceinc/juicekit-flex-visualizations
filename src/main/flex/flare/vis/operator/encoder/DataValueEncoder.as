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

package flare.vis.operator.encoder
{
    import flare.vis.data.Data;
    import flare.vis.data.DataSprite;
    
    import org.juicekit.animate.Transitioner;
    import org.juicekit.util.Property;
    
    
    /**
     * Encodes properties by directly copying values from the data object
     * to the DataSprite properties.
     */
    public class DataValueEncoder extends Encoder
    {
        
        private var _transform:Function = null;
        
        /** 
         * The transformation to use on the source property
         */
        public function set transform(value:Function):void
        {
            _transform = value;
        }
        
        public function get transform():Function
        {
            return _transform;
        }
        
        
        // --------------------------------------------------------------------
        
        /**
         * Creates a new DataValueEncoder.
         * 
         * @param source the source property in data to copy values from 
         * @param target the target property on the DataSprite to copy values to
         * @param group the data group to process
         * @param transform an optional transformation to perform on the source
         * @param filter an optional filtering function that determines which
         * items to operate on
         */
        public function DataValueEncoder(source:String, 
                                         target:String,
                                         group:String = Data.NODES, 
                                         transform:Function = null,
                                         filter:* = null)
        {
            super(source, target, group);
            this.transform = transform;
            this.filter = filter;
        }
        
        /** @inheritDoc */
        protected override function encode(val:Object):*
        {
            return val;
        }
        
        
        /** @inheritDoc */
        override public function operate(t:Transitioner = null):void
        {
            if (!canBindToData()) return;
            
            _t = (t != null ? t : Transitioner.DEFAULT);
            var p:Property = Property.$(_binding.property);
            _binding.updateBinding();
            
            if (visualization) {
                if (transform != null) {
                    visualization.data.visit(function(d:DataSprite):void {
                        _t.setValue(d, _target, transform(encode(p.getValue(d))));
                    }, _binding.group, _filter);
                } else {
                    visualization.data.visit(function(d:DataSprite):void {
                        _t.setValue(d, _target, encode(p.getValue(d)));
                    }, _binding.group, _filter);
                }
            }
            
            var targetProp:Property = Property.$(_target);
            if (dataProvider) {
                dataProvider.disableAutoUpdate();
                for each (var row:Object in dataProvider) {
                    var oldValue:Object = targetProp.getValue(row);
                    var newValue:Object = encode(p.getValue(row));
                    if (transform != null) newValue = transform(newValue);
                    _t.setValue(row, _target, newValue);
                    dataProvider.itemUpdated(row, _target, oldValue, newValue); 
                }
                dataProvider.enableAutoUpdate();
            }
            
            _t = null;
        }
        
    } // end of class DataValueEncoder
}