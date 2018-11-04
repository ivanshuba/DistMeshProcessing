/*****************************************************************************************
 *
 *****************************************************************************************/
public class TPoint extends PVector {
  //public float x, y, z;
  ArrayList<TPoint> connectedPoints;
  ArrayList<TPoint> checkedPoints;
  //PVector position;
  PVector velocity;
  PVector acceleration;

  // Artificial mass (change to increase convergence)
  float mass = 10f;
  // Artificial damping (change to increase convergence)
  float damping = 0.8f;


  public TPoint() {
    connectedPoints = new ArrayList<TPoint>(0);
    checkedPoints = new ArrayList<TPoint>(0);
    velocity = new PVector();
    acceleration = new PVector();
  }

  public TPoint(float x, float y) {
    this.x = x;
    this.y = y;
    this.z = 0;
    connectedPoints = new ArrayList<TPoint>();
    checkedPoints = new ArrayList<TPoint>(0);
    velocity = new PVector();
    acceleration = new PVector();
  }

  public TPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    connectedPoints = new ArrayList<TPoint>();
    checkedPoints = new ArrayList<TPoint>(0);
    velocity = new PVector();
    acceleration = new PVector();
  }

  // public TPoint(PVector v) {
  //   this.x = v.x;
  //   this.y = v.y;
  //   this.z = v.z;
  //   connectedPoints = new ArrayList<TPoint>();
  //   checkedPoints = new ArrayList<TPoint>(0);
  //   velocity = new PVector();
  //   acceleration = new PVector();
  // }

  public void addConnectedPoint(TPoint p) {
    if (!connectedPoints.contains(p)) {
      connectedPoints.add(p);
    }
  }

  public ArrayList<TPoint> getConnectedPoints() {
    return connectedPoints;
  }

  public PVector asPVector() {
    return new PVector(x, y);
  }

  float distanceTo(PVector p) {
    return PVector.dist(this.asPVector(), p);
  }

  // presumably support accumulation of several forces
  public void applyForce(PVector force) {
    PVector f = force.get();
    f.div(mass);
    acceleration.add(f);
  }

  public void updatePosition() {
    velocity.add(acceleration);
    velocity.mult(damping);
    this.add(velocity);
    acceleration.mult(0);
  }

  // PVector calculateForceFrom(TPoint neighbour) {
  //   PVector vectorDist = PVector.sub(position, neighbour.position);
  //   float floatDist = vectorDist.mag();
  //   float stretch = floatDist - prefferableLength;
  //   vectorDist.normalize();
  //   PVector force = vectorDist.mult(-1f * k * stretch);
  //   return new PVector(0.0, 0.0);
  // }

  public String toString() {
    return "[" + x + ":" + y + "]";
  }
}