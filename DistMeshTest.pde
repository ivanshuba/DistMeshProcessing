import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import processing.core.PApplet;

Triangulator triangulator;

void setup() {
  size(600, 600);
  

  // float theta = normalizedIndex * 6 * PConstants.TWO_PI;
  // float radius = normalizedIndex * fieldWidth / 2f;
  // float centerX = fieldWidth * 0.5f;
  // float centerY = fieldHeight * 0.5f;
  // float x = PApplet.cos(theta) * radius;
  // float y = PApplet.sin(theta) * radius;
  // return new PVector(centerX + x, centerY + y);
  ArrayList<TPoint> points = new ArrayList<TPoint>();
  for(int i = 0; i < 20; i++) {
    float normalizedIndex = (float) i / 100;
    float theta = normalizedIndex * 6 * PConstants.TWO_PI;
    float radius = normalizedIndex * width / 2f;

    TPoint point = new TPoint(random(width * 0.25, width * 0.75), random(height * 0.25, height * 0.75));
    points.add(point);
  }

  triangulator = new Triangulator(points);
  triangulator.triangulate();

  noLoop();
}

void draw() {
  strokeWeight(0.25f);
  for(Triangle triangle : triangulator.triangles) {
    line(triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y);
    line(triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y);
    line(triangle.p3.x, triangle.p3.y, triangle.p1.x, triangle.p1.y);
    float x = (triangle.p1.x + triangle.p2.x + triangle.p3.x) / 3;
    float y = (triangle.p1.y + triangle.p2.y + triangle.p3.y) / 3;
    pushStyle();
    textAlign(CENTER, CENTER);
    textSize(12);
    fill(0);
    text(triangulator.triangles.indexOf(triangle), x, y);
    popStyle();
  }
  
  // pushStyle();
  // strokeWeight(3);
  // stroke(100, 10, 10);
  // line(triangulator.triangles.get(0).p1.x, triangulator.triangles.get(0).p1.y, triangulator.triangles.get(0).p2.x, triangulator.triangles.get(0).p2.y);    
  // line(triangulator.triangles.get(0).p2.x, triangulator.triangles.get(0).p2.y, triangulator.triangles.get(0).p3.x, triangulator.triangles.get(0).p3.y);    
  // line(triangulator.triangles.get(0).p3.x, triangulator.triangles.get(0).p3.y, triangulator.triangles.get(0).p1.x, triangulator.triangles.get(0).p1.y);    
  // popStyle();

  // pushStyle();
  // line(triangulator.superTriangle.p1.x, triangulator.superTriangle.p1.y, triangulator.superTriangle.p2.x, triangulator.superTriangle.p2.y);    
  // line(triangulator.superTriangle.p2.x, triangulator.superTriangle.p2.y, triangulator.superTriangle.p3.x, triangulator.superTriangle.p3.y);    
  // line(triangulator.superTriangle.p3.x, triangulator.superTriangle.p3.y, triangulator.superTriangle.p1.x, triangulator.superTriangle.p1.y);    
  // popStyle();
}

public class TPoint extends PVector {
  //public float x, y, z;
  ArrayList<TPoint> connectedPoints;
  PVector force;
  float stiffness = 1.2;

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

  public void calculateForces() {

  }
}

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
    boolean val = false;
    if (tp.equals(p1) || tp.equals(p2) || tp.equals(p3)) {
      val = true;
    }
    return val;
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
  public ArrayList<TEdge>    edges;
  public Triangle superTriangle;

  public Triangulator(ArrayList<TPoint> points) {
    this.points = points;
  }

  public void triangulate() {
    /*
      Triangulation subroutine
      Takes as input vertices (Points) in ArrayList points
      Returned is a list of triangular faces in the ArrayList triangles 
      These triangles are arranged in a consistent clockwise order.
    */

    triangles = new ArrayList<Triangle>(); // for the Triangles
    HashSet<Triangle> complete = new HashSet<Triangle>(); // for complete Triangles

    /*
      Create SuperTriangle
      This is a triangle which encompasses all the sample points.
      The supertriangle coordinates are added to the end of the
      vertex list. The supertriangle is the first triangle in
      the triangle list.
    */
    // sort points arraylist in increasing x values
    Collections.sort(points, new XComparator());
    //  Find the maximum and minimum X and Y coordinates from all the points
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
    // calculate width and height of the bounding rectangle for the whole bunch of points 
    float dx = xmax - xmin;
    float dy = ymax - ymin;
    // find out what is larger - width or height of the boundary rectangle
    float dmax = (dx > dy) ? dx : dy;
    // find the center of the boundary rectangle
    float xmid = (xmax + xmin) / 2.0f;
    float ymid = (ymax + ymin) / 2.0f;
    // set up the SuperTriangle
    superTriangle = new Triangle();
    superTriangle.p1 = new TPoint(xmid - 2.0f * dmax, ymid - dmax, 0.0f);
    superTriangle.p2 = new TPoint(xmid, ymid + 2.0f * dmax, 0.0f);
    superTriangle.p3 = new TPoint(xmid + 2.0f * dmax, ymid - dmax, 0.0f);
    triangles.add(superTriangle);
    // System.out.printf("Triangulator.superTriangle.p1.x    = %-4.4f\n", superTriangle.p1.x);
    // System.out.printf("Triangulator.superTriangle.p1.y    = %-4.4f\n", superTriangle.p1.y);
    // System.out.printf("Triangulator.superTriangle.p2.x    = %-4.4f\n", superTriangle.p2.x);
    // System.out.printf("Triangulator.superTriangle.p2.y    = %-4.4f\n", superTriangle.p2.y);
    // System.out.printf("Triangulator.superTriangle.p3.x    = %-4.4f\n", superTriangle.p3.x);
    // System.out.printf("Triangulator.superTriangle.p3.y    = %-4.4f\n", superTriangle.p3.y);
    

    /*
      Include each point one at a time into the existing mesh
    */
    edges = new ArrayList<TEdge>();
    for (TPoint p : points) {
      TPoint circle = new TPoint();
      /*
        Set up the edge buffer.
        If the point (xp, yp) lies inside the circumcircle then the
        three edges of that triangle are added to the edge buffer
        and that triangle is removed.
      */
      edges.clear();
      for (int j = triangles.size() - 1; j >= 0; j--) {
        Triangle t = (Triangle) triangles.get(j);
        if (complete.contains(t)) {
          continue;
        }

        boolean inside = circumCircle(p, t, circle);

        if (circle.x + circle.z < p.x) {
          complete.add(t);
        }
        if (inside) {
          edges.add(new TEdge(t.p1, t.p2));
          edges.add(new TEdge(t.p2, t.p3));
          edges.add(new TEdge(t.p3, t.p1));
          triangles.remove(j);
        }
      }

      /*
        Tag multiple edges
        Note: if all triangles are specified anticlockwise then all
        interior edges are opposite pointing in direction.
      */
      for (int j = 0; j < edges.size() - 1; j++) {
        TEdge e1 = (TEdge) edges.get(j);
        for (int k = j + 1; k < edges.size(); k++) {
          TEdge e2 = (TEdge) edges.get(k);
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

      /*
        Form new triangles for the current point
        Skipping over any tagged edges.
        All edges are arranged in clockwise order.
      */
      for (int j = 0; j < edges.size(); j++) {
        TEdge e = (TEdge) edges.get(j);
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

    System.out.println();
    System.out.printf("Triangulator.points.size()    = %-3d\n", points.size());
    System.out.printf("Triangulator.edges.size()     = %-3d\n", edges.size());
    System.out.printf("Triangulator.triangles.size() = %-3d\n", triangles.size());
    System.out.printf("Triangulator.complete.size() = %-3d\n", complete.size());
    
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

    dx = t.p2.x - circle.x;
    dy = t.p2.y - circle.y;
    rsqr = dx * dx + dy * dy;
    circle.z = PApplet.sqrt(rsqr);

    dx = p.x - circle.x;
    dy = p.y - circle.y;
    drsqr = dx * dx + dy * dy;

    return drsqr <= rsqr;
  }

  public void calculateForces() {

  }
}
