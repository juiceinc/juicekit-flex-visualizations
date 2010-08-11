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
import flare.vis.data.DataList;
import flare.vis.data.NodeSprite;
import flare.vis.operator.Operator;

import org.juicekit.animate.Transitioner;
import org.juicekit.util.Property;

/**
 * Calculates betweenness centrality measures for nodes in a graph.
 * The algorithm used is due to Ulrik Brandes, as published in the
 * <a href="http://www.inf.uni-konstanz.de/algo/publications/b-fabc-01.pdf">
 * Journal of Mathematical Sociology, 25(2):163-177, 2001</a>.
 */
public class BetweennessCentrality extends Operator
{
  private var _bc:Property = Property.$("props.centrality");

  /** The property in which to store the centrality score. This property
   *  is used to annotate nodes with their betweenness centrality score.
   *  The default value is "props.centrality". */
  public function get centralityField():String {
    return _bc.name;
  }

  public function set centralityField(f:String):void {
    _bc = Property.$(f);
  }

  /** Flag indicating the type of links to follow in the graph. The
   *  default is <code>NodeSprite.GRAPH_LINKS</code>. */
  public var links:int = NodeSprite.GRAPH_LINKS;

  /**
   * Creates a new BetweennessCentrality operator.
   */
  public function BetweennessCentrality()
  {
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    calculate(visualization.data);
  }

  /**
   * Calculates the betweenness centrality values for the given data set.
   * @param data the data set for which to compute centrality measures
   */
  public function calculate(data:Data):void
  {
    var nodes:DataList = data.nodes;
    var N:int = nodes.length, i:int;
    var n:NodeSprite, v:NodeSprite, w:NodeSprite;
    var si:Score, sv:Score, sw:Score;

    nodes.visit(function(n:NodeSprite):void {
      _bc.setValue(n, 0);
      n.props._score = new Score();
    });

    for (i = 0; i < N; ++i) {
      nodes.visit(function(n:NodeSprite):void {
        n.props._score.reset();
      });
      n = nodes[i];
      si = n.props._score;
      si.paths = 1;
      si.distance = 0;

      var stack:Array = [];
      var queue:Array = [n];

      while (queue.length > 0) {
        stack.push(v = queue.shift());
        si = v.props._score;

        v.visitNodes(function(w:NodeSprite):void {
          var sv:Score = si, sw:Score = w.props._score;
          if (sw.distance < 0) {
            queue.push(w);
            sw.distance = sv.distance + 1;
          }
          if (sw.distance == sv.distance + 1) {
            sw.paths += sv.paths;
            sw.predecessors.push(v);
          }
        }, links);
      }
      while (stack.length > 0) {
        w = stack.pop();
        sw = w.props._score;
        for each (v in sw.predecessors) {
          sv = v.props._score;
          sv.dependency += (sv.paths / sw.paths) * (1 + sw.dependency);
        }
        if (w !== n) sw.centrality += sw.dependency;
      }
    }

    nodes.visit(function(n:NodeSprite):void {
      _bc.setValue(n, n.props._score.centrality);
      delete n.props._score;
    });
  }

} // end of class BetweennessCentrality
}
import org.juicekit.util.Arrays;


/** Helper class for storing intermediate centrality computations */
class Score {
  public var dependency:Number = 0;
  public var distance:Number = -1;
  public var paths:Number = 0;
  public var predecessors:Array = [];
  public var centrality:Number = 0;

  public function reset():void {
    Arrays.clear(predecessors);
    dependency = 0;
    distance = -1;
    paths = 0;
  }

  public function Score() {
    super();
  }
}