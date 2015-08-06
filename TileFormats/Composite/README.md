# Composite

## Notes

**Use cases**: Flexibility for streaming heterogeneous datasets, e.g., streaming buildings and trees as separate layers, or as one layer.

From the main spec:

>> How do 3D Tiles support heterogeneous datasets?

> Geospatial datasets are heterogeneous: 3D buildings are different from terrain, which is different from point clouds, which are different from vector data, and so on.

> 3D Tiles support heterogeneous data by allowing different tile formats in a tileset, e.g., a tileset may contain tiles for 3D buildings, tiles for instanced 3D trees, and tiles for point clouds, all using different tile formats.

> We expect 3D Tiles will also support heterogeneous datasets by concatenating different tile formats into one tile, a _composite_; in the example above, a tile may have a short header followed by the content for the 3D buildings, instanced 3D trees, and point clouds.

> Supporting heterogeneous datasets with both inter-tile (different tile formats in the same tileset) and intra-tile (different tile formats in the same tile) options will allow conversion tools to make trade-offs between number of requests, optimal type-specific subdivision, and how visible/hidden layers are streamed.