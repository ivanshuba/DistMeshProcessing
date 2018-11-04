class DistMeshOptimizer {

  public void optimize(Delaunay triangulation) {
    // loop until optimization is converged by some criteria
    updateForces(triangulation);
    updatePositions(triangulation);
    triangulation.update();
  }

  public void updateForces(Delaunay triangulation) {
    for (TEdge edge : triangulation.edges) {
      edge.updateForce();
    }
  }

  public void updatePositions(Delaunay triangulation) {
    for (TPoint point : triangulation.points) {
      point.updatePosition();
    }
  }
}
