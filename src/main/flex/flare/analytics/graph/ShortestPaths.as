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

package flare.analytics.graph
{
import flare.vis.data.Data;
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;
import flare.vis.operator.Operator;

import org.juicekit.animate.Transitioner;
import org.juicekit.util.Property;
import org.juicekit.util.heap.FibonacciHeap;
import org.juicekit.util.heap.HeapNode;

/**
 * Calculates the shortest paths to a source node using Dijkstra's algorithm.
 * Nodes are annotated with both the total distance and their incoming edge
 * along the shortest path.
 */
public class ShortestPaths extends Operator
{
  private var _d:Property = Property.$("props.distance");
  private var _p:Property = Property.$("props.predecessor");
  private var _e:Property = Property.$("props.onpath");
  private var _w:Function = null;

  /** The source node from which to compute the shortest paths. */
  public var source:NodeSprite;

  /** A function determining edge weights used in the shortest path
   *  calculation. When setting this value, one can pass in either a
   *  Function, which should take an EdgeSprite as input and return a
   *  Number as output, or a String, in which case the string will be
   *  used as a property name from which to retrieve the edge weight
   *  value from an EdgeSprite instance. If the value is null (the
   *  default) all edges will be assumed to have weight 1.
   *
   *  <p><b>NOTE:</b> Edge weights must be greater than or equal to zero!
   *  </p> */
  public function get edgeWeight():Function {
    return _w;
  }

  public function set edgeWeight(w:*):void {
    if (w == null) {
      _w = null;
    } else if (w is String) {
      _w = Property.$(String(w)).getValue;
    } else if (w is Function) {
      _w = w;
    } else {
      throw new Error("Unrecognized edgeWeight value. " +
                      "The value should be a Function or String.");
    }
  }

  /** The property in which to store the link distance. This property
   *  is used to annotate nodes with the minimum link distance to one of
   *  the source nodes. The default value is "props.distance". */
  public function get distanceField():String {
    return _d.name;
  }

  public function set distanceField(f:String):void {
    _d = Property.$(f);
  }

  /** The property in which to store incoming edges along a shortest
   *  path. This property is used to annotate nodes with the incoming
   *  along a shortest path from one of the source nodes. By following
   *  sequential incoming edges, one can recreate the shortest path from
   *  the nearest source node. The default value is "props.incoming". */
  public function get incomingField():String {
    return _p.name;
  }

  public function set incomingField(f:String):void {
    _p = Property.$(f);
  }

  /** The property in which to store a path inclusion flag for edges.
   *  This property is used to mark edges as belonging to one of the
   *  computed shortest paths: <code>true</code> indicates that the edge
   *  participates in a shortest path, <code>false</code> indicates that
   *  the edge does not lie along a shortest path. The default value is
   *  "props.onpath". */
  public function get onpathField():String {
    return _p.name;
  }

  public function set onpathField(f:String):void {
    _p = Property.$(f);
  }

  // --------------------------------------------------------------------

  /**
   * Creates a new ShortestPaths operator.
   * @param source the source node from which to measure shortest paths
   * @param edgeWeight the edge weight values. This can either be a
   *  <code>Function</code> that returns weight values or a
   *  <code>String</code> providing the name of a property to look up on
   *  <code>EdgeSprite</code> instances.
   */
  public function ShortestPaths(source:NodeSprite = null,
                                edgeWeight:* = null)
  {
    this.source = source;
    this.edgeWeight = edgeWeight;
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    calculate(visualization.data, source, _w);
  }

  /**
   * Calculates the shortest paths from a source node.
   * @param data the data set containing a graph
   * @param n the source node from which to measure path lengths
   * @param w a function returning weight values for edges. If null,
   *  all edges will be assumed to have equal weight.
   */
  public function calculate(data:Data, s:NodeSprite, w:Function = null):void
  {
    var u:NodeSprite, ud:HeapNode, dg:int;
    var dir:Boolean = data.directedEdges;

    // initialize heap and node distances
    var heap:FibonacciHeap = new FibonacciHeap();
    data.edges.setProperty(_e.name, false);
    data.nodes.visit(function(n:NodeSprite):void {
      _p.setValue(n, null);
      n.props.heapNode = heap.insert(n);
    });
    heap.decreaseKey(HeapNode(s.props.heapNode), 0);

    while (!heap.empty) {
      ud = heap.removeMin();
      u = NodeSprite(ud.data);
      u.visitEdges(function(e:EdgeSprite):void {
        var v:NodeSprite = e.other(u);
        var vd:HeapNode = v.props.heapNode;
        var ew:Number = (w == null ? 1 : w(e));
        // ensure edge weight is non-negative
        if (ew < 0)
          throw new Error("Edge weights must be non-negative!");

        // perform the relaxation
        if (vd.key > ud.key + ew) {
          heap.decreaseKey(vd, ud.key + ew);
          _p.setValue(v, e);
        }
      }, dir ? NodeSprite.OUT_LINKS : NodeSprite.GRAPH_LINKS);
    }

    data.nodes.visit(function(n:NodeSprite):void {
      var hn:HeapNode = n.props.heapNode;
      delete n.props.heapNode;
      _d.setValue(n, hn.key);
      var e:EdgeSprite = _p.getValue(n);
      if (e) _e.setValue(e, true);
    });
  }

  public function getShortestPathTo(v:NodeSprite):Array
  {
    var path:Array = [v], e:EdgeSprite;
    while ((e = _p.getValue(v)) != null) {
      path.unshift(v = e.other(v));
    }
    return path;
  }

} // end of class ShortestPaths
}