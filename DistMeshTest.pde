import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import processing.core.PApplet;

Triangulator triangulator;
ArrayList<TPoint> points;

import org.gicentre.utils.move.*;    // For the zoomer.
ZoomPan zoomer;    // This should be declared outside any methods.
PVector mousePos;  // Stores the mouse position.
boolean drawTriangles, drawComplete = true;
double delay = millis();

void setup() {
  size(600, 600);

  textFont(createFont("courier", 128));

  zoomer = new ZoomPan(this);  // Initialise the zoomer.
  zoomer.setMouseMask(SHIFT);  // Only zoom if the shift key is down.

  points = new ArrayList<TPoint>();
  //spiralSeed(points);
  randomSeed(points, 4);

  triangulator = new Triangulator(points);
  triangulator.triangulate();

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

void draw() {
  background(230);
  pushMatrix();    // Store a copy of the unzoomed screen transformation.
  zoomer.transform(); // Enable the zooming/panning.
  mousePos = zoomer.getMouseCoord();
  drawTriangles();
  surface.setTitle(mousePos.x + ":" + mousePos.y);
}

void drawTriangles(){
  if(drawTriangles) {
    for (Triangle triangle : triangulator.triangles) {
      pushStyle();
      strokeWeight(0.5f);
      line(triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y);
      line(triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y);
      line(triangle.p3.x, triangle.p3.y, triangle.p1.x, triangle.p1.y);
      float x = (triangle.p1.x + triangle.p2.x + triangle.p3.x) / 3;
      float y = (triangle.p1.y + triangle.p2.y + triangle.p3.y) / 3;
      textAlign(CENTER, CENTER);
      textSize(8);
      fill(0);
      text(
        triangulator.triangles.indexOf(triangle) + ":" + 
        triangulator.points.indexOf(triangle.p1) + "," + 
        triangulator.points.indexOf(triangle.p2) + "," + 
        triangulator.points.indexOf(triangle.p3)  
        , x, y);
      popStyle();
    }
  }

  if(drawComplete){
    for (Triangle triangle : triangulator.triangles) {
      pushStyle();
      if(triangulator.triangles.indexOf(triangle) == 0) {
        strokeWeight(3f);
        stroke(20, 100, 20, 50);
      } else {
        strokeWeight(0.5f);
        stroke(0);
      }
      line(triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y);
      line(triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y);
      line(triangle.p3.x, triangle.p3.y, triangle.p1.x, triangle.p1.y);
      float x = (triangle.p1.x + triangle.p2.x + triangle.p3.x) / 3;
      float y = (triangle.p1.y + triangle.p2.y + triangle.p3.y) / 3;
      textAlign(CENTER, CENTER);
      textSize(8);
      fill(0);
      text(
        triangulator.triangles.indexOf(triangle) + ":" + 
        triangulator.points.indexOf(triangle.p1) + "," + 
        triangulator.points.indexOf(triangle.p2) + "," + 
        triangulator.points.indexOf(triangle.p3)  
        , x, y);
      popStyle();
    }
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
  // line(triangulator.superTriangle.p1.x, triangulator.superTriangle.p1.y, triangulator.superTriangle.p2.x, triangulator.superTriangle.p2.y);    
  // line(triangulator.superTriangle.p2.x, triangulator.superTriangle.p2.y, triangulator.superTriangle.p3.x, triangulator.superTriangle.p3.y);    
  // line(triangulator.superTriangle.p3.x, triangulator.superTriangle.p3.y, triangulator.superTriangle.p1.x, triangulator.superTriangle.p1.y);    
  // popStyle();
  popMatrix();    // Restore the unzoomed screen transformation.
}


void mousePressed() {
  if (mouseButton == RIGHT) {
    if (millis() - delay > 300) {
      points.add(new TPoint(mousePos.x, mousePos.y));
      triangulator.triangulate();
      delay = millis();
    }
  }
}

void keyPressed() {
  if (key == '1') {
    drawComplete = !drawComplete;
    println("drawComplete:" + drawComplete);
  }
  if (key == '2') {
    drawTriangles = !drawTriangles;
    println("drawTriangles:" + drawTriangles);
  }
}