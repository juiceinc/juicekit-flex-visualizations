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

package flare.analytics.cluster
{
import flare.vis.data.DataList;

import org.juicekit.animate.Transitioner;
import org.juicekit.util.math.IMatrix;

/**
 * Hierarchically clusters a network based on inferred community structure.
 * The result is a cluster tree in which each merge is chosen so as to
 * maximize within-cluster linkage while minimizing between-cluster linkage.
 * This class uses <a href="http://arxiv.org/abs/cond-mat/0309508">Newman's
 * fast algorithm for detecting community structure</a>. Optionally allows
 * clients to provide an edge weight function indicating the strength of
 * ties within the network.
 */
public class CommunityStructure extends HierarchicalCluster
{
  /** A function defining edge weights in the graph. */
  public var edgeWeights:Function = null;

  // --------------------------------------------------------------------

  /**
   * Creates a new community structure instance
   */
  public function CommunityStructure()
  {
  }

  /** @inheritDoc */
  public override function operate(t:Transitioner = null):void
  {
    calculate(visualization.data.group(group), edgeWeights);
  }

  /**
   * Calculates the community structure clustering. As a result of this
   * method, a cluster tree will be computed and graph nodes will be
   * annotated with both community and sequence indices.
   * @param list the data list to cluster
   * @param w an edge weighting function. If null, each edge will be
   *  given weight one.
   */
  public function calculate(list:DataList, w:Function = null):void
  {
    compute(list.adjacencyMatrix(w));
    _tree = buildTree(list);
    labelNodes();
  }

  /** Computes the clustering */
  private function compute(G:IMatrix):void
  {
    _merges = new MergeEdge(-1, -1);
    _qvals = [];
    _size = G.rows;
    var i:int, j:int, k:int, s:int, t:int, v:Number;
    var Q:Number = 0, Qmax:Number = 0, dQ:Number, dQmax:Number = 0, imax:int;

    // initialize normalized matrix
    var N:int = G.rows, Z:IMatrix = G.clone();
    for (i = 0; i < N; ++i) Z.set(i, i, 0); // clear diagonal
    Z.scale(1 / Z.sum); // normalize matrix

    // initialize column sums and edge list
    var E:MergeEdge = new MergeEdge(-1, -1);
    var e:MergeEdge = E, m:MergeEdge = _merges;
    var eMax:MergeEdge = new MergeEdge(0, 0);
    var A:Array = new Array(N);

    for (i = 0; i < N; ++i) {
      A[i] = 0;
      for (j = 0; j < N; ++j) {
        if ((v = Z.get(i, j)) != 0) {
          A[i] += v;
          e = e.add(new MergeEdge(i, j));
        }
      }
    }

    // run the clustering algorithm
    for (var ii:int = 0; ii < N - 1 && E.next; ++ii) {
      dQmax = Number.NEGATIVE_INFINITY;
      eMax.update(0, 0);

      // find the edge to merge
      for (e = E.next; e != null; e = e.next) {
        i = e.i;
        j = e.j;
        if (i == j) continue;
        dQ = Z.get(i, j) + Z.get(j, i) - 2 * A[i] * A[j];
        if (dQ > dQmax) {
          dQmax = dQ;
          eMax.update(i, j);
        }
      }

      // perform merge on graph
      i = eMax.i;
      j = eMax.j;
      if (j < i) {
        i = eMax.j;
        j = eMax.i;
      }
      var na:Number = 0;
      for (k = 0; k < N; ++k) {
        v = Z.get(i, k) + Z.get(j, k);
        if (v != 0) {
          na += v;
          Z.set(i, k, v);
          Z.set(j, k, 0);
        }
      }
      for (k = 0; k < N; ++k) {
        v = Z.get(k, i) + Z.get(k, j);
        if (v != 0) {
          Z.set(k, i, v);
          Z.set(k, j, 0);
        }
      }
      A[i] = na;
      A[j] = 0;
      for (e = E.next; e != null; e = e.next) {
        s = e.i;
        t = e.j;
        if ((i == s && j == t) || (i == t && j == s)) {
          e.remove();
        } else if (s == j) {
          e.i = i;
        } else if (t == j) {
          e.j = i;
        }
      }

      Q += dQmax;
      if (Q > Qmax) {
        Qmax = Q;
        imax = ii;
      }
      _qvals.push(Q);
      m = m.add(new MergeEdge(i, j));
    }
  }

} // end of class CommunityStructure
}