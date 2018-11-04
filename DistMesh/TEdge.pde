

/*****************************************************************************************
 *
 *****************************************************************************************/
public class TEdge {
  // This length must be changed depending on `weight` of each word-node (extend TPoint)
  float prefferableLength = 50f;
  // Artificial stiffness (change to increase convergence)
  float k = 0.997f;
  // 
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

  public void updateForce() {
    // Vector pointing from p1 to p2
    PVector force = PVector.sub(p1.asPVector(), p2.asPVector());
    // the distance between them
    float dist = force.mag();
    // The stretch - difference between current and prefferable length 
    float stretch = dist - prefferableLength;

    // Calculate the actual force vector according to the Hook's law
    // F = k * stretch
    force.normalize();
    force.mult(-1 * k * stretch);
    p1.applyForce(force);
    force.mult(-1);
    p2.applyForce(force);
  }
}