# Vector Data

## Notes

**Use cases**: Traditional geospatial features: points, polylines, and polygons.  Replacing KML.

**Format**
* Combination of binary (for positions, normals, etc.) and JSON (for labels, other metadata, etc.).
* Concise representations for Cesium's [set of geometries](http://cesiumjs.org/2013/11/04/Geometry-and-Appearances/), including extrusions, and billboards and labels.
   * Need to carefully select the representation for the best trade-off between conciseness and runtime processing.  For example, polygons will likely be pre-triangulated since it only adds indices to the payload, but will be subdivided at runtime since the operation is fast and increases the vertex payload significantly.
* Metadata for cracking, morphing, and perhaps label declutter.

Could also name this a `Geometry` tile.