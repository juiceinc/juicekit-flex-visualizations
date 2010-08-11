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

package flare.vis.operator.filter
{

import flare.vis.data.DataSprite;
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;
import flare.vis.operator.Operator;

import flash.utils.Dictionary;

import org.juicekit.animate.Transitioner;

/**
 * Filter operator that sets visible all items within a specified graph
 * distance from a set of focus nodes.
 */
public class GraphDistanceFilter extends Operator
{
  /** An array of focal NodeSprites. */
  public var focusNodes:/*NodeSprite*/Array;
  /** Graph distance within which which items wll be visible. */
  public var distance:int;
  /** Flag indicating which graph links to traverse. */
  public var links:int;

  /**
   * Creates a new GraphDistanceFilter.
   * @param focusNodes an array of focal NodeSprites. Graph distance is
   *  measured as the minimum number of edge-hops to one of these nodes.
   * @param distance graph distance within which items will be visible
   * @param links flag indicating which graph links to traverse. The
   *  default value is <code>NodeSprite.GRAPH_LINKS</code>.
   */
  public function GraphDistanceFilter(focusNodes:Array = null,
                                      distance:int = 1, links:int = 3/*NodeSprite.GRAPH_LINKS*/)
  {
    this.focusNodes = focusNodes;
    this.distance = distance;
    this.links = links;
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    t = (t == null ? Transitioner.DEFAULT : t);

    // initialize breadth-first traversal
    var q:Array = [], depths:Dictionary = new Dictionary();
    for each (var fn:NodeSprite in focusNodes) {
      depths[fn] = 0;
      fn.visitEdges(function(e:EdgeSprite):void {
        depths[e] = 1;
        q.push(e);
      }, links);
    }

    // perform breadth-first traversal
    var xe:EdgeSprite, xn:NodeSprite, d:int;
    while (q.length > 0) {
      xe = q.shift();
      d = depths[xe];
      // -- fix to bug 1924891 by goosebumps4all
      if (depths[xe.source] == undefined) {
        xn = xe.source;
      } else if (depths[xe.target] == undefined) {
        xn = xe.target;
      } else {
        continue;
      }
      // -- end fix
      depths[xn] = d;

      if (d == distance) {
        xn.visitEdges(function(e:EdgeSprite):void {
          if (depths[e.target] == d && depths[e.source] == d) {
            depths[e] = d + 1;
          }
        }, links);
      } else {
        xn.visitEdges(function(e:EdgeSprite):void {
          if (depths[e] == undefined) {
            depths[e] = d + 1;
            q.push(e);
          }
        }, links);
      }
    }

    // now set visibility based on traversal results
    visualization.data.visit(function(ds:DataSprite):void {
      var visible:Boolean = (depths[ds] != undefined);
      var alpha:Number = visible ? 1 : 0;
      var obj:Object = t.$(ds);

      obj.alpha = alpha;
      if (ds is NodeSprite) {
        var ns:NodeSprite = ds as NodeSprite;
        ns.expanded = (visible && depths[ds] < distance);
      }
      if (t.immediate) {
        ds.visible = visible;
      } else {
        obj.visible = visible;
      }
    });
  }

} // end of class GraphDistanceFilter
}