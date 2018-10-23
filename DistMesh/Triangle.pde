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