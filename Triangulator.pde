/*****************************************************************************************
 *
 *****************************************************************************************/
public class TPoint extends PVector {
  //public float x, y, z;
  ArrayList<TPoint> connectedPoints;

  public TPoint() {
    connectedPoints = new ArrayList<TPoint>();
  }

  public TPoint(float x, float y) {
    this.x = x;
    this.y = y;
    connectedPoints = new ArrayList<TPoint>();
  }

  public TPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    connectedPoints = new ArrayList<TPoint>();
  }

  public TPoint(PVector v) {
    this.x = v.x;
    this.y = v.y;
    this.z = v.z;
    connectedPoints = new ArrayList<TPoint>();
  }

  public void addConnectedPoint(TPoint p) {
    if (!connectedPoints.contains(p)) {
      connectedPoints.add(p);
    }
  }

  public ArrayList<TPoint> getConnectedPoints() {
    return connectedPoints;
  }
}

/*****************************************************************************************
 *
 *****************************************************************************************/
public class TEdge {
  public TPoint p1, p2;

  public TEdge() {
    p1 = null;
    p2 = null;
  }

  public TEdge(TPoint p1, TPoint p2) {
    this.p1 = p1;
    this.p2 = p2;
  }

  public TPoint getOppositePoint(TPoint tp) {
    TPoint val = null;
    if (tp.equals(p1)) {
      val = p2;
    } else if (tp.equals(p2)) {
      val = p1;
    }
    return val;
  }
}

/*****************************************************************************************
 *
 *****************************************************************************************/
public class Triangle {

  public TPoint p1, p2, p3;

  public Triangle() {
    p1 = null;
    p2 = null;
    p3 = null;
  }

  public Triangle(TPoint p1, TPoint p2, TPoint p3) {
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
  }

  public boolean sharesVertex(Triangle other) {
    return p1 == other.p1 || p1 == other.p2 || p1 == other.p3 ||
        p2 == other.p1 || p2 == other.p2 || p2 == other.p3 ||
        p3 == other.p1 || p3 == other.p2 || p3 == other.p3;
  }

  public boolean contains(TPoint tp) {
    // boolean val = false;
    // if (tp.equals(p1) || tp.equals(p2) || tp.equals(p3)) {
    //   val = true;
    // }
    // return val;
    return (tp.equals(p1) || tp.equals(p2) || tp.equals(p3));
  }

  public ArrayList<TPoint> getNeighbours(TPoint tp) {
    ArrayList<TPoint> neighbours = null;
    if (tp.equals(p1)) {
      neighbours = new ArrayList<TPoint>();
      neighbours.add(p2);
      neighbours.add(p3);
    } else if (tp.equals(p2)) {
      neighbours = new ArrayList<TPoint>();
      neighbours.add(p1);
      neighbours.add(p3);
    } else if (tp.equals(p3)) {
      neighbours = new ArrayList<TPoint>();
      neighbours.add(p1);
      neighbours.add(p2);
    }
    return neighbours;
  }

}

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
  public ArrayList<TPoint>   points;
  public ArrayList<Triangle> triangles;
  public ArrayList<TEdge>    edgeBuffer;
  public Triangle            superTriangle;
  public HashSet<Triangle>   complete;

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
    // Initialize ArrayList for Triangles to be returned
    triangles = new ArrayList<Triangle>(); 
    // Initialize HashSet for "complete" Triangle set (why??? only for checking "if it is already in the set?")
    complete = new HashSet<Triangle>(); 

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

    ///////////////////////////////////////////////////////////////////////////////////////////////// 
    //
    // Start adding points and creating new triangles (using SuperTriangle as a basis for initial 
    // caluations)
    //
    // 1. Set up the edge buffer.
    edgeBuffer = new ArrayList<TEdge>();
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

    /*
     * Collect connected points for each point
     */
    for (TPoint p : points) {
      // System.out.printf("[%3d]: \n", points.indexOf(p));
      for (Triangle t : triangles) {
        if (t.contains(p)) {
          ArrayList<TPoint> neighbours = t.getNeighbours(p);
          for (TPoint neighbour : neighbours) {
            // System.out.printf("\t[%3d]", points.indexOf(neighbour));
            p.addConnectedPoint(neighbour);
          }
        // } else {
            // print("\t------------");
        }
        // println();
        //System.out.printf("[%3d]:", points.indexOf(p));
      } 
    }

    //debug();

  }

  public void debug() {
    System.out.println();
    System.out.printf("points.size()    = %-3d\n", points.size());
    System.out.printf("edgeBuffer.size()= %-3d\n", edgeBuffer.size());
    System.out.printf("triangles.size() = %-3d\n", triangles.size());
    System.out.printf("complete.size()  = %-3d\n", complete.size());
    System.out.println();

    for (Triangle t : triangles) {
      System.out.printf("[%3d]: [%3d][%3d][%3d]\n", triangles.indexOf(t), points.indexOf(t.p1), points.indexOf(t.p2), points.indexOf(t.p3));
    } 
    println("-------------------------------------------------------------------------------------");
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
      }
      else if (p1.x > p2.x) {
        return 1;
      }
      else {
        return 0;
      }
    }
  }

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

  /////////////////////////////////////////////////////////////////////////////////////
  // Original version of the circumcircle test
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
    }
    else if (PApplet.abs(t.p3.y - t.p2.y) < PApplet.EPSILON) {
      m1 = -(t.p2.x - t.p1.x) / (t.p2.y - t.p1.y);
      mx1 = (t.p1.x + t.p2.x) / 2.0f;
      my1 = (t.p1.y + t.p2.y) / 2.0f;
      circle.x = (t.p3.x + t.p2.x) / 2.0f;
      circle.y = m1 * (circle.x - mx1) + my1;
    }
    else {
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
