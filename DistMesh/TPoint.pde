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

  public PVector asPVector() {
    return new PVector(x, y);
  }

  float distanceTo(PVector p) {
    return PVector.dist(this.asPVector(), p);
  }
}