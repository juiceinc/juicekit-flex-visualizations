/*
 * Copyright (c) 2007-2010 Regents of the University of California.
 *   All rights reserved.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 *   3.  Neither the name of the University nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *   ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 *   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *   SUCH DAMAGE.
 */

package flare.vis.events
{
import flare.vis.data.DataList;
import flare.vis.data.DataSprite;
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;

import flash.events.Event;

/**
 * Event fired when a data collection is modified.
 */
public class DataEvent extends Event
{
  /** A data added event. */
  public static const ADD:String = "add";
  /** A data removed event. */
  public static const REMOVE:String = "remove";
  /** A data updated event. */
  public static const UPDATE:String = "update";

  /** @private */
  protected var _items:Array;
  /** @private */
  protected var _item:Object;
  /** @private */
  private var _list:DataList;

  /** The number of items in this data event. */
  public function get length():int {
    return _items ? _items.length : 1;
  }

  /** The list of effected data items. */
  public function get items():Array {
    if (_items == null) _items = [_item];
    return _items;
  }

  /** The data list (if any) the items belong to. */
  public function get list():DataList {
    return _list;
  }

  /** The first element in the event list as an Object. */
  public function get object():Object {
    return _item;
  }

  /** The first element in the event list as a DataSprite. */
  public function get item():DataSprite {
    return _item as DataSprite;
  }

  /** The first element in the event list as a NodeSprite. */
  public function get node():NodeSprite {
    return _item as NodeSprite;
  }

  /** The first element in the event list as an EdgeSprite. */
  public function get edge():EdgeSprite {
    return _item as EdgeSprite;
  }

  /**
   * Creates a new DataEvent.
   * @param type the event type (ADD, REMOVE, or UPDATE)
   * @param items the DataSprite(s) that were added, removed, or updated
   * @param list (optional) the data list that was modified
   */
  public function DataEvent(type:String, items:*, list:DataList = null)
  {
    super(type, false, true);
    if (items is Array) {
      _items = items;
      _item = _items[0];
    } else {
      _items = null;
      _item = items;
    }
    _list = list;
  }

  /** @inheritDoc */
  public override function clone():Event
  {
    return new DataEvent(type, _items ? _items : _item, _list);
  }

} // end of class DataEvent
}