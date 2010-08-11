package flare.analytics.graph {
import flare.vis.Visualization;
import flare.vis.data.DataSprite;
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;
import flare.vis.events.VisualizationEvent;

import flash.events.Event;

import org.juicekit.util.Arrays;


/**
 * K-nearest Neighbor Spacial Search
 * Algorithm used from http://blogs.msdn.com/devdev/archive/2007/06/07/k-nearest-neighbor-spatial-search.aspx
 *
 * If the distance from (x,y) to the closest node is greater than maxDistance,
 * this returns null.  Otherwise, it returns the closest node. Passing -1 for maxDistance
 * means maxDistance is ignored.
 * 
 * edgeParent determines whether the parent of edge-matching nodes should come back as an edge 'edge',
 * or one of its 'node' sources
 *
 * @author Sal Uryasev
 */
public class NearestNeighbor {

  private var vis:Visualization;


  public function NearestNeighbor(vis:Visualization, edgeSplits:uint=3, edgeParent:String='node'):void {
    //public function NearestNeighbor(f:FlareVisBase, edgeSplits:uint=3, edgeParent:String='node'):void {
    this.edgeParent = edgeParent;
    this.edgeSplits = edgeSplits;
    this.vis = vis;
    // this.vis = f.vis
    this.vis.addEventListener(VisualizationEvent.UPDATE, function(e:Event):void {
      quadTree = null;
    });
  }
  
  private var edgeParent:String = 'node';
  
  private var edgeSplits:uint = 3;


  private function setupNearestNeighbor():void {
    var rawNodeList:Array = Arrays.copy(vis.data.nodes.list);
    
    var rawEdgeList:Array = Arrays.copy(vis.data.edges.list);
    for each (var e:EdgeSprite in rawEdgeList) {
      //Do not run for the first and last point, as these are covered by the nodeList
      for (var i:uint=1; i<edgeSplits; i++) {
        rawNodeList.push({parent: edgeParent=='node' ? e.source : e, 
                          x: e.source.x + i *(e.target.x - e.source.x)/edgeSplits,
                          y: e.source.y + i *(e.target.y - e.source.y)/edgeSplits})
      }
    }
    
    quadTree = new QuadTree(vis.x, vis.y, vis.x + vis.width, vis.y + vis.height);
    for each (var n:Object in rawNodeList)
      quadTree.addChild(n);
  }

  private var quadTree:QuadTree;


  public function nearestNode(x:Number, y:Number, maxDistance:int = -1):DataSprite {
    if (quadTree === null)
      setupNearestNeighbor();

    var queue:Array = [quadTree];

    while (queue.length != 0) {

      //Sort by the closest node or QuadTree
      queue.sort(function(a:*, b:*):int {
          var distanceA:Number;
          var distanceB:Number;
          if (a is QuadTree) distanceA = (a as QuadTree).sqDistance(x, y);
          else if (a is Object) distanceA = Math.pow(x - vis.x - a.x, 2) + Math.pow(y - vis.y - a.y, 2);

          if (b is QuadTree) distanceB = (b as QuadTree).sqDistance(x, y);
          else if (b is Object) distanceB = Math.pow(x - vis.x - b.x, 2) + Math.pow(y - vis.y - b.y, 2);

          if (distanceA < distanceB)return -1;
          if (distanceA == distanceB)return 0;
          return 1;
        });

      // We found the closest node, so go ahead and return that node.
      // This section can be modified to find the nearest X nodes.
      if (!(queue[0] is QuadTree))
        break;

      var q:QuadTree = (queue.shift() as QuadTree);
      var k:Array = q.children();
      queue = queue.concat(k);
    }

    // Catch empty nodeset
    if (queue.length == 0)
      return null;

    // Only return the node if it is less than maxDistance away
    if (maxDistance < 0 || Math.pow(x - vis.x - queue[0].x, 2) +
      Math.pow(y - vis.y - queue[0].y, 2) <= Math.pow(maxDistance, 2)) {
        if (queue[0] is NodeSprite) return queue[0];
        else if (queue[0] is Object) return queue[0]['parent'];
      }

    return null;
  }

}
}


/**
 * QuadTree class is a specialized data structure that can be split into four other QuadTrees.
 */
class QuadTree {

  public function QuadTree(_x1:Number, _y1:Number, _x2:Number, _y2:Number, maxDepth:uint = 8, maxNodes:uint = 4):void {
    _maxNodes = maxNodes;
    //maxDepth not yet implemented
    _maxDepth = maxDepth;
    x1 = _x1;
    x2 = _x2;
    y1 = _y1;
    y2 = _y2;
  }

  private var _maxNodes:uint;
  private var _maxDepth:uint;

  // Array of nodes
  private var nodes:Array = [];

  private var leafNode:Boolean = true;

  private var _tl:QuadTree;


  public function get tl():QuadTree {
    if (_tl === null)
      _tl = new QuadTree(x1, y1, x1 + (x2 - x1) / 2, y1 + (y2 - y1) / 2, _maxDepth - 1);
    return _tl;

  }


  public function set tl(q:QuadTree):void {
    _tl = q;
  }


  private var _tr:QuadTree;


  public function get tr():QuadTree {
    if (_tr === null)
      _tr = new QuadTree(x1 + (x2 - x1) / 2, y1, x2, y1 + (y2 - y1) / 2, _maxDepth - 1);
    return _tr;
  }


  public function set tr(q:QuadTree):void {
    _tr = q;
  }


  private var _bl:QuadTree;


  public function get bl():QuadTree {
    if (_bl === null)
      _bl = new QuadTree(x1, y1 + (y2 - y1) / 2, x1 + (x2 - x1) / 2, y2, _maxDepth - 1);
    return _bl;
  }


  public function set bl(q:QuadTree):void {
    _bl = q;
  }


  private var _br:QuadTree;


  public function get br():QuadTree {
    if (_br === null)
      _br = new QuadTree(x1 + (x2 - x1) / 2, y1 + (y2 - y1) / 2, x2, y2, _maxDepth - 1);
    return _br;
  }


  public function set br(q:QuadTree):void {
    _br = q;
  }


  public function addChild(newN:Object):void {
    nodes.push(newN);
    if (!leafNode || nodes.length > _maxNodes) {
      leafNode = false;
      while (nodes.length > 0) {
        var n:Object = nodes.pop();
        // Add the node to the correct quadron
        if (n.x < x1 || n.x > x2 || n.y < y1 || n.y > y2) {
          // This node is in the wrong place.
          trace('Node is being placed into the wrong box: x: ' + n.x + ', y: ' + n.y);
          return;
        }
        else if (n.x < x1 + (x2 - x1) / 2 && n.y < y1 + (y2 - y1) / 2) {
          tl.addChild(n);
        }
        else if (n.x < x1 + (x2 - x1) / 2) {
          bl.addChild(n);
        }
        else if (n.y < y1 + (y2 - y1) / 2) {
          tr.addChild(n);
        }
        else {
          br.addChild(n);
        }
      }
    }
  }


  public function children():Array {
    if (leafNode) {
      // return children
      return nodes;
    }
    else {
      // return child boxes
      var a:Array = [];
      _tl !== null ? a.push(tl) : null;
      _tr !== null ? a.push(tr) : null;
      _bl !== null ? a.push(bl) : null;
      _br !== null ? a.push(br) : null;
      return a;
    }
  }


  public function sqDistance(x:uint, y:uint):Number {
    // Calculate (squared) distance of self to node
    var result:Number = 0;
    if (x > x2)
      result += Math.pow(x - x2, 2);
    if (x < x1)
      result += Math.pow(x1 - x, 2);
    if (y > y2)
      result += Math.pow(y - y2, 2);
    if (y < y1)
      result += Math.pow(y1 - y, 2);
    return result;
  }

  public var x1:Number;
  public var x2:Number;
  public var y1:Number;
  public var y2:Number;

}