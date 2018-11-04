/*
 *  ported from paul bourke's triangulate.c
 *  http://astronomy.swin.edu.au/~pbourke/modelling/triangulate/
 *
 *  fjenett, 20th february 2005, offenbach-germany.
 *  contact: http://www.florianjenett.de/
 *
 *      adapted to take a Vector of Point3f objects and return a Vector of Triangles
 *      (and generally be more Java-like and less C-like in usage - 
 *       and probably less efficient but who's benchmarking?)
 *      Tom Carden, tom (at) tom-carden.co.uk 17th January 2006
 *
 *      adapted to get rid of those ugly Vector and Point3f objects. it now takes an
 *      ArrayList of Point objects and return an ArrayList of Triangles objects.
 *      see what Sun thinks about Vector objects here:
 *      http://java.sun.com/developer/technicalArticles/Collections/Using/index.html
 *      antiplastik, 28 june 2010, paris-france
 *
 */
public class Triangulator {   
  public ArrayList<TEdge>    edges;
  public ArrayList<TPoint>   points;
  public ArrayList<Triangle> triangles;
  public Triangle            superTriangle;

  public Triangulator() {
  }

  /*
    Triangulation subroutine.
   Takes the ArrayList of vertices (TPoints) as an input.
   Returns an ArrayList of triangles.
   These triangles are arranged in a consistent clockwise order.
   */
  public void triangulate(ArrayList<TPoint> points) {
    this.points = points;
    // Initialize ArrayList for Edges to be returned
    edges = new ArrayList<TEdge>();
    // Initialize ArrayList for Triangles to be returned
    triangles = new ArrayList<Triangle>(); 
    // Initialize HashSet for "complete" Triangle set 
    HashSet<Triangle> complete = new HashSet<Triangle>(); 

    createSuperTriangle();

    ///////////////////////////////////////////////////////////////////////////////////////////////// 
    //
    // Start adding points and creating new triangles (using SuperTriangle as a basis for initial 
    // caluations)
    //
    // 1. Set up the edge buffer.
    ArrayList<TEdge> edgeBuffer = new ArrayList<TEdge>();
    // 2. Iterate through all the points in ArrayList. Process each point one at a time.
    for (TPoint p : points) {
      TPoint circle = new TPoint();
      // Set up the edge buffer.
      edgeBuffer.clear();
      // iterate through all the triangles present in the ArrayList
      for (int i = triangles.size() - 1; i >= 0; i--) {
        Triangle t = (Triangle) triangles.get(i);
        if (complete.contains(t)) {
          continue;
        }
        // If the point (xp,yp) lies inside the circumcircle then the
        // three edges of that triangle are added to the edge buffer
        // and that triangle is removed.
        boolean inside = circumCircle(p, t, circle);
        if (circle.x + circle.z < p.x) {
          complete.add(t);
        }
        if (inside) {
          edgeBuffer.add(new TEdge(t.p1, t.p2));
          edgeBuffer.add(new TEdge(t.p2, t.p3));
          edgeBuffer.add(new TEdge(t.p3, t.p1));
          triangles.remove(i);
        }
      }
      // Tag (remove???) multiple edges
      // Note: if all triangles are specified anticlockwise then all
      // interior edges are opposite pointing in direction.
      for (int i = 0; i < edgeBuffer.size() - 1; i++) {
        TEdge e1 = (TEdge) edgeBuffer.get(i);
        for (int j = i + 1; j < edgeBuffer.size(); j++) {
          TEdge e2 = (TEdge) edgeBuffer.get(j);
          if (e1.p1 == e2.p2 && e1.p2 == e2.p1) {
            e1.p1 = null;
            e1.p2 = null;
            e2.p1 = null;
            e2.p2 = null;
          }
          /* Shouldn't need the following, see note above */
          if (e1.p1 == e2.p1 && e1.p2 == e2.p2) {
            e1.p1 = null;
            e1.p2 = null;
            e2.p1 = null;
            e2.p2 = null;
          }
        }
      }
      // Form new triangles for the current point.
      // Skipping over any tagged edges.
      // All edges are arranged in clockwise order.
      for (int i = 0; i < edgeBuffer.size(); i++) {
        TEdge e = (TEdge) edgeBuffer.get(i);
        if (e.p1 == null || e.p2 == null) {
          continue;
        }
        triangles.add(new Triangle(e.p1, e.p2, p));
      }
    }

    /*
      Remove triangles with supertriangle vertices
     */
    for (int i = triangles.size() - 1; i >= 0; i--) {
      Triangle t = (Triangle) triangles.get(i);
      if (t.sharesVertex(superTriangle)) {
        triangles.remove(i);
      }
    }

    updateNeighbourPoints();
    updateEdgeList();
    //debug();
  }

  /*
   * Collect connected points for each point
   * !!! Very ineffective, must be optimized in future !!!
   */
  private void updateNeighbourPoints() {
    for (TPoint p : points) {
      for (Triangle t : triangles) {
        if (t.contains(p)) {
          ArrayList<TPoint> neighbours = t.getNeighbours(p);
          for (TPoint neighbour : neighbours) {
            p.addConnectedPoint(neighbour);
          }
        }
      }
    }
  }

  private void updateEdgeList() {
    edges.clear();
    for (TPoint p : points) {
      for (TPoint neighbour : p.getConnectedPoints()) {
        if (neighbour.checkedPoints.contains(p) || p.checkedPoints.contains(neighbour)) {
          continue;
        }
        edges.add(new TEdge(p, neighbour));
        neighbour.checkedPoints.add(p);
        p.checkedPoints.add(neighbour);
      }
    }
    for (TPoint p : points) {
      p.connectedPoints.clear();
      p.checkedPoints.clear();
      p.connectedPoints.clear();
    }
  }

  private void createSuperTriangle() {
    ///////////////////////////////////////////////////////////////////////////////////////////////// 
    //
    // Start creating the SuperTriangle
    // This is a triangle which encompasses all the sample points.
    // The supertriangle coordinates are added to the end of the
    // vertex list. The supertriangle is the first triangle in
    // the triangle list.
    //
    // 1. Sort points arraylist in increasing x values
    Collections.sort(points, new XComparator());
    // 2. Start finding the maximum and minimum X and Y coordinates from the list of all the points
    float xmin = ((TPoint) points.get(0)).x;
    float ymin = ((TPoint) points.get(0)).y;
    float xmax = xmin;
    float ymax = ymin;
    for (TPoint p : points) {
      if (p.x < xmin) xmin = p.x;
      if (p.x > xmax) xmax = p.x;
      if (p.y < ymin) ymin = p.y;
      if (p.y > ymax) ymax = p.y;
    } 
    // 3. calculate width and height of the bounding rectangle for the whole bunch of points 
    float dx = xmax - xmin;
    float dy = ymax - ymin;
    // 4. Find out what is larger - width or height of the boundary rectangle
    float dmax = (dx > dy) ? dx : dy;
    // 5. Find the center of the boundary rectangle
    float xmid = (xmax + xmin) * 0.5f;
    float ymid = (ymax + ymin) * 0.5f;
    // 6. Set up the SuperTriangle ...
    superTriangle = new Triangle();
    superTriangle.p1 = new TPoint(xmid - 2.0f * dmax, ymid - dmax, 0.0f);
    superTriangle.p2 = new TPoint(xmid, ymid + 2.0f * dmax, 0.0f);
    superTriangle.p3 = new TPoint(xmid + 2.0f * dmax, ymid - dmax, 0.0f);
    // 7. ... and add it to the Triangles ArrayList
    triangles.add(superTriangle);
    //
    // Stop creating the SuperTriangle
    //
    /////////////////////////////////////////////////////////////////////////////////////////////////   
  }

  public void debug() {
    System.out.println();
    System.out.printf("points.size()    = %-3d\n", points.size());
    System.out.printf("edges.size()    = %-3d\n", edges.size());
    System.out.printf("triangles.size() = %-3d\n", triangles.size());
    System.out.println();

    println("--TRIANGLES-------------------------------------------------------------------------------");
    for (Triangle t : triangles) {
      System.out.printf("[%3d]: [%3d][%3d][%3d]\n", triangles.indexOf(t), points.indexOf(t.p1), points.indexOf(t.p2), points.indexOf(t.p3));
    } 
    println("--EDGES-----------------------------------------------------------------------------------");
    for (TEdge edge : edges) {
      System.out.printf("[%3d]: [%3d][%3d]\n", edges.indexOf(edge), points.indexOf(edge.p1), points.indexOf(edge.p2));
    }
    println("--POINTS----------------------------------------------------------------------------------");
    for (TPoint p : points) {
      System.out.printf("[%3d]: ", points.indexOf(p));
      for (TPoint connectedPoint : p.getConnectedPoints()) {
        System.out.printf("[%3d] ", points.indexOf(connectedPoint));
      }
      println();
    }
  }

  private class XComparator implements Comparator<TPoint> {
    public int compare(TPoint p1, TPoint p2) {
      if (p1.x < p2.x) {
        return -1;
      } else if (p1.x > p2.x) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  /*
   This might be needed later for refactoring.
   /////////////////////////////////////////////////////////////////////////////////////
   // Author: Ivan Shuba
   // This is a modified version, taken from JFrameP.
   	// Returns absolute position of a center point as PVector.
   	public PVector getCenterPoint(PVector sp, PVector ep, PVector mp) {
   		PVector ar, aa, bb;
   
   		aa = PVector.sub(mp, sp);
   		bb = PVector.sub(ep, sp);
   		float bb2 = bb.mag() * bb.mag();
   		float aa2 = aa.mag() * aa.mag();
   
   		ar = PVector.div(
   		    PVector.add(
   	          PVector.mult(aa, bb2 * (aa2 - aa.dot(bb))), 
   PVector.mult(bb, aa2 * (bb2 - aa.dot(bb)))
   ), 
   ((aa.cross(bb)).mag() * (aa.cross(bb)).mag()) * 2);
   		if (PApplet.abs(sp.x - ep.x) < PApplet.EPSILON) {
   			return new PVector(sp.x + ar.x, (sp.y + ep.y) * 0.5f);
   		} else if (PApplet.abs(sp.y - ep.y) < PApplet.EPSILON) {
   			return new PVector((sp.x + ep.x) * 0.5f, sp.y + ar.y);
   		} else {
   			return new PVector(sp.x + ar.x, sp.y + ar.y);
   		}
   	}
   */

  /*
    The original version of the circumcircle test.
   
    Note: Actually, because it was written in C, it is designed such way that it 
    "returns" several types of data.
    1. The boolean value is passed directly as a returned value. It is equal true, if
       the point 'p' is INSIDE of the circumscribed circle, more specifically, if the 
       radius of circumscribed circle is greater than distance between the center of
       this circle and the point 'p' that is passed as an argument.
    2. Also, implicitly, the method also "returns" the coordinates of point 'circle'.
    3. Also, implicitly, the radius of the circumscribed circle is "returned" as Z 
       value of the point 'circle'.
  */
  private boolean circumCircle(TPoint p, Triangle t, TPoint circle) {

    float m1, m2, mx1, mx2, my1, my2;
    float dx, dy, rsqr, drsqr;

    /* Check for coincident points */
    if (PApplet.abs(t.p1.y - t.p2.y) < PApplet.EPSILON && PApplet.abs(t.p2.y - t.p3.y) < PApplet.EPSILON) {
      System.err.println("CircumCircle: Points are coincident.");
      return false;
    }

    if (PApplet.abs(t.p2.y - t.p1.y) < PApplet.EPSILON) {
      m2 = -(t.p3.x - t.p2.x) / (t.p3.y - t.p2.y);
      mx2 = (t.p2.x + t.p3.x) / 2.0f;
      my2 = (t.p2.y + t.p3.y) / 2.0f;
      circle.x = (t.p2.x + t.p1.x) / 2.0f;
      circle.y = m2 * (circle.x - mx2) + my2;
    } else if (PApplet.abs(t.p3.y - t.p2.y) < PApplet.EPSILON) {
      m1 = -(t.p2.x - t.p1.x) / (t.p2.y - t.p1.y);
      mx1 = (t.p1.x + t.p2.x) / 2.0f;
      my1 = (t.p1.y + t.p2.y) / 2.0f;
      circle.x = (t.p3.x + t.p2.x) / 2.0f;
      circle.y = m1 * (circle.x - mx1) + my1;
    } else {
      m1 = -(t.p2.x - t.p1.x) / (t.p2.y - t.p1.y);
      m2 = -(t.p3.x - t.p2.x) / (t.p3.y - t.p2.y);
      mx1 = (t.p1.x + t.p2.x) / 2.0f;
      mx2 = (t.p2.x + t.p3.x) / 2.0f;
      my1 = (t.p1.y + t.p2.y) / 2.0f;
      my2 = (t.p2.y + t.p3.y) / 2.0f;
      circle.x = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
      circle.y = m1 * (circle.x - mx1) + my1;
    }

    // ? this calculates the distance between ANY (here, p2) point
    // ? of the triangle and the center point, i.e. - the radius of 
    // ? circumscribed circle. This value is set to the Z coordinate of 
    // ? the returned TPoint (what a messy tricks - single responsibility
    // ? principle is violated)
    dx = t.p2.x - circle.x;
    dy = t.p2.y - circle.y;
    rsqr = dx * dx + dy * dy;
    circle.z = PApplet.sqrt(rsqr); 

    // aparently, this calculates the distance between the center and 
    // the point. if this distance is larger than the radius of the 
    // circumscribed CIRCLE, then it means that the point is located 
    // outside of the CIRCLE.
    // ??? but if the point is located inside circumscribed CIRCLE, it 
    // this still doesn't exclude the possibility that point can be 
    // located outside the TRIANGLE
    dx = p.x - circle.x;
    dy = p.y - circle.y;
    drsqr = dx * dx + dy * dy;

    return drsqr <= rsqr;
  }
}
