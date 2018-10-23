

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