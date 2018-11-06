import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import processing.core.PApplet;
import org.gicentre.utils.move.*;    // For the zoomer.

Delaunay triangulation;
ArrayList<TPoint> points;

DistMeshOptimizer distMeshOptimizer;

ZoomPan zoomer;    // This should be declared outside any methods.
PVector mousePos;  // Stores the mouse position.

boolean drawTriangles = false;
boolean drawPoints = true;
boolean drawEdges = true;
boolean drawText = false;
boolean doOptimize = false;
double delay = millis();
float textHeight = 8;

void setup() {
  size(600, 600);

  textFont(createFont("courier", 128));

  zoomer = new ZoomPan(this);  // Initialise the zoomer.
  zoomer.setMouseMask(SHIFT);  // Only zoom if the shift key is down.
  zoomer.setZoomMouseButton(LEFT);
  zoomer.setZoomScale(0.5);
  
  points = new ArrayList<TPoint>();
  //spiralSeed(points);
  randomSeed(points, 300);

  triangulation = new Delaunay();
  triangulation.triangulate(points);
  triangulation.debug();

  distMeshOptimizer = new DistMeshOptimizer();
}

void draw() {
  background(230);
  pushMatrix();                          // Store a copy of the unzoomed screen transformation.
  zoomer.transform();                    // Enable the zooming/panning.
  mousePos = zoomer.getMouseCoord();
  drawTriangulation();
  popMatrix();                           // Restore the unzoomed screen transformation.

  if (doOptimize) {
    distMeshOptimizer.optimize(triangulation);
  }
  
  //surface.setTitle(mousePos.x + ":" + mousePos.y);
  drawDebugInfo();
}

void randomSeed(ArrayList<TPoint> points, int npoints) {
  for (int i = 0; i < npoints; i++) {
    points.add(new TPoint(random(width * 0.1, width * 0.9), random(height * 0.1, height * 0.9)));
  }
}

void spiralSeed(ArrayList<TPoint> points) {
  float x0 = width * 0.5; // spiral center X
  float y0 = height * 0.5; // spiral center Y
  float radius = (width > height) ? width * 0.3 : height * 0.3;
  float nturns = 2;   // non-dimensional
  float radialStep = radius / nturns; // px
  int npoints = 6;

  for (int i = 0; i < npoints; i++) {
    float theta = map(i, 0, npoints - 1, 0, TWO_PI * nturns);
    float rho = radialStep / (TWO_PI) * theta;
    float x = x0 + rho * cos(theta);
    float y = y0 + rho * sin(theta);
    TPoint point = new TPoint(x, y);
    points.add(point);
  }
}

void drawDebugInfo() {
  fill(0);
  textAlign(LEFT, BOTTOM);
  textSize(10);
  text("points.size():" + triangulation.points.size(), 10, 20);
  text("triangles.size():" + triangulation.triangles.size(), 10, 30);
  textSize(26);
  text("optimize.enabled: " + str(doOptimize).toUpperCase(), 10, height - 10);
  textSize(16);
  text("FPS:" + int(frameRate), width - 60, 20);
  textSize(28);
  textAlign(CENTER, CENTER);
  text("Press 'O' to enable/disable optimization", width * 0.5, 40);
  text("Click right mouse button to add point", width * 0.5, 80);
}

void drawTriangulation(){
  // draw edges
  if (drawEdges) {
    pushMatrix();
    for (TEdge edge : triangulation.edges) {
        pushStyle();
        strokeWeight(0.5f);
        stroke(50, 100, 50);
        line(edge.p1.x, edge.p1.y, edge.p2.x, edge.p2.y);
        if (drawText) {
          String edgeIndex = str(triangulation.edges.indexOf(edge));
          String p1Index = str(triangulation.points.indexOf(edge.p1));
          String p2Index = str(triangulation.points.indexOf(edge.p2));
          String info = edgeIndex + ":(" + p1Index + "," + p2Index + ")";
          textAlign(CENTER, CENTER);
          textSize(textHeight);
          fill(100, 100, 200);
          text(info, (edge.p1.x + edge.p2.x) * 0.5f + 5, (edge.p1.y + edge.p2.y) * 0.5f  + 5);
        }
        popStyle();
    }
    popMatrix();
  }
  // draw triangles
  if (drawTriangles) {
    pushMatrix();
    for (Triangle triangle : triangulation.triangles) {
      pushStyle();
      strokeWeight(0.5f);
      line(triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y);
      line(triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y);
      line(triangle.p3.x, triangle.p3.y, triangle.p1.x, triangle.p1.y);
      float x = (triangle.p1.x + triangle.p2.x + triangle.p3.x) / 3;
      float y = (triangle.p1.y + triangle.p2.y + triangle.p3.y) / 3;
      if (drawText) {
        textAlign(CENTER, CENTER);
        textSize(textHeight);
        fill(0);
        text(
          triangulation.triangles.indexOf(triangle) + ":" +
          triangulation.points.indexOf(triangle.p1) + "," +
          triangulation.points.indexOf(triangle.p2) + "," +
          triangulation.points.indexOf(triangle.p3)
          , x, y);
      }
      popStyle();
    }
    popMatrix();
  }
  // draw points
  if (drawPoints) {
    for (TPoint p : triangulation.points) {
      pushStyle();
      StringBuilder sb = new StringBuilder();
      for (TPoint cp : p.connectedPoints) {
        int cpindex = triangulation.points.indexOf(cp);
        sb.append(cpindex + ",");
      }
      if (p.connectedPoints.size() > 0) {
        sb.deleteCharAt(sb.length() - 1);
      }
      fill(250);
      //point(p.x, p.y);
      ellipse(p.x, p.y, p.sz, p.sz);
      int index = triangulation.points.indexOf(p);
      if (drawText) {
        textAlign(LEFT, CENTER);
        textSize(textHeight);
        fill(0);
        text(index + ":(" + sb.toString() + ")", p.x, p.y - 10);
      }
      popStyle();
    }
  }
}

void mousePressed() {
  if (mouseButton == RIGHT) {
    if (millis() - delay > 200) {
      TPoint point = new TPoint(mousePos.x, mousePos.y);
      point.setSize(25);
      point.setMass(100);
      points.add(point);
      triangulation.triangulate(points);
      //triangulation.debug();
      delay = millis();
    }
  }
}

void keyPressed() {
  if (key == 'e') {
    drawEdges = !drawEdges;
  }
  if (key == 'r') {
    drawTriangles = !drawTriangles;
  }
  if (key == 'd') {
    triangulation.debug();
  }
  if (key == 't') {
    drawText = !drawText;
  }
  if (key == 'p') {
    drawPoints = !drawPoints;
  }
  if (key == 'o') {
    //distMeshOptimizer.optimize(triangulation);
    doOptimize = !doOptimize;
  }
}
