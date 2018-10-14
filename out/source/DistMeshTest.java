import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.ArrayList; 
import java.util.Comparator; 
import java.util.Collections; 
import java.util.HashSet; 
import java.util.Iterator; 
import processing.core.PApplet; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class DistMeshTest extends PApplet {








Triangulator triangulator;

public void setup() {
  

  ArrayList<TPoint> points = new ArrayList<TPoint>();
  float x0 = width * 0.5f; // spiral center X
  float y0 = height * 0.5f; // spiral center Y
  float radius = (width > height) ? width * 0.3f : height * 0.3f;
  float nturns = 2;   // non-dimensional
  float radialStep = radius / nturns; // px
  int npoints = 10;

  for(int i = 0; i < npoints; i++) {
    float theta = map(i, 0, npoints - 1, 0, TWO_PI * nturns);
    float rho = radialStep / (TWO_PI) * theta;
    float x = x0 + rho * cos(theta);
    float y = y0 + rho * sin(theta);
    TPoint point = new TPoint(x, y);
    points.add(point);
  }

  triangulator = new Triangulator(points);
  triangulator.triangulate();

  noLoop();
}

public void draw() {
  strokeWeight(0.25f);
  for(Triangle triangle : triangulator.triangles) {
    line(triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y);
    line(triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y);
    line(triangle.p3.x, triangle.p3.y, triangle.p1.x, triangle.p1.y);
    float x = (triangle.p1.x + triangle.p2.x + triangle.p3.x) / 3;
    float y = (triangle.p1.y + triangle.p2.y + triangle.p3.y) / 3;
    pushStyle();
    textAlign(CENTER, CENTER);
    textSize(8);
    fill(0);
    text(triangulator.triangles.indexOf(triangle), x, y);
    popStyle();
  }
  
  for (TPoint p : triangulator.points) {
    pushStyle();
    textAlign(CENTER, CENTER);
    textSize(8);
    fill(0);
    StringBuilder sb = new StringBuilder();
    for (TPoint cp : p.connectedPoints) {
      int cpindex = triangulator.points.indexOf(cp);
      sb.append(cpindex + ",");
    }
    //sb.deleteCharAt(sb.length() - 1);
    int index = triangulator.points.indexOf(p);
    text(index + ":(" + sb.toString() + ")", p.x + 5, p.y + 5);
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
  public ArrayList<TEdge>    edgeBuffer;
  public Triangle            superTriangle;

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
    float xmid = (xmax + xmin) * 0.5f;
    float ymid = (ymax + ymin) * 0.5f;
    // set up the SuperTriangle ...
    superTriangle = new Triangle();
    superTriangle.p1 = new TPoint(xmid - 2.0f * dmax, ymid - dmax, 0.0f);
    superTriangle.p2 = new TPoint(xmid, ymid + 2.0f * dmax, 0.0f);
    superTriangle.p3 = new TPoint(xmid + 2.0f * dmax, ymid - dmax, 0.0f);
    // ... and adding it to the triangles arraylist
    triangles.add(superTriangle);

    // Set up the edge buffer.
    edgeBuffer = new ArrayList<TEdge>();
  
    /*
      Include each point one at a time into the existing mesh
    */
    for (TPoint p : points) {
      TPoint circle = new TPoint();
      // If the point (xp, yp) lies inside the circumcircle then the
      // three edges of that triangle are added to the edge buffer
      // and that triangle is removed.
      edgeBuffer.clear();
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
          edgeBuffer.add(new TEdge(t.p1, t.p2));
          edgeBuffer.add(new TEdge(t.p2, t.p3));
          edgeBuffer.add(new TEdge(t.p3, t.p1));
          triangles.remove(j);
        }
      }
      // Tag multiple edges
      // Note: if all triangles are specified anticlockwise then all
      // interior edges are opposite pointing in direction.
      for (int j = 0; j < edgeBuffer.size() - 1; j++) {
        TEdge e1 = (TEdge) edgeBuffer.get(j);
        for (int k = j + 1; k < edgeBuffer.size(); k++) {
          TEdge e2 = (TEdge) edgeBuffer.get(k);
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
      for (int j = 0; j < edgeBuffer.size(); j++) {
        TEdge e = (TEdge) edgeBuffer.get(j);
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
    System.out.printf("Triangulator.edgeBuffer.size()     = %-3d\n", edgeBuffer.size());
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

  public void updateForces() {

  }

  public void updatePositions() {

  }
}
  public void settings() {  size(600, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "DistMeshTest" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
