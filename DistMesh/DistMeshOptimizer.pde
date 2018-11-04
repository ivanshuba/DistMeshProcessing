class DistMeshOptimizer {

  public void optimize(Delaunay triangulation) {
    // loop until optimization is converged by some criteria
  }

  public void updateTriangulation(Delaunay triangulation) {
    for (TPoint point : triangulation.points) {
      for (TPoint neighbour : point.connectedPoints) {
        
      }
    }
  }
}
