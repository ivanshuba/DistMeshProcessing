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

	//public PVector getCenterPoint(PVector sp, PVector ep, PVector mp) {
	public PVector getCenterPoint() {
 		PVector ar, aa, bb;
    PVector sp = p1.asPVector();
    PVector mp = p2.asPVector();
    PVector ep = p3.asPVector();

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

    PVector center;          
		if (PApplet.abs(sp.x - ep.x) < PApplet.EPSILON) {
			center = new PVector(sp.x + ar.x, (sp.y + ep.y) * 0.5f);
		} else if (PApplet.abs(sp.y - ep.y) < PApplet.EPSILON) {
			center = new PVector((sp.x + ep.x) * 0.5f, sp.y + ar.y);
		} else {
			center = new PVector(sp.x + ar.x, sp.y + ar.y);
		}
    return center;
	}

  public boolean isPointInsideCircumCircle(TPoint p) {
    PVector center = getCenterPoint();
    float r = p.distanceTo(p1.asPVector());
    float d = p.distanceTo(center);
    return (d < r ? true : false);
  }
}