## 3D Tiles Tile Formats

The [tile content](../README.md#tile-content) in a 3D Tiles tileset represents the renderable content of a tile. It is referred to with the `content.uri` of the tile JSON.

The primary tile format in 3D Tiles 1.1 is the [glTF Tile Format](glTF/). It is built on [glTF 2.0](https://github.com/KhronosGroup/glTF) and allows modeling many different use cases and different forms of renderable content in 3D Tiles.

### Legacy Tile Formats

The following tile formats have been part of 3D Tiles 1.0, and have been superseded by the [glTF Tile Format](glTF/).

Legacy Format|Uses
---|---
[Batched 3D Model (`b3dm`)](Batched3DModel/)|Heterogeneous 3D models
[Instanced 3D Model (`i3dm`)](Instanced3DModel/)|3D model instances
[Point Cloud (`pnts`)](PointCloud/)|Massive number of points
[Composite (`cmpt`)](Composite/)|Concatenate tiles of different formats into one tile

See the [migration guide](glTF/README.md#appendix-a-migration-from-legacy-tile-formats) for further information about how these use cases can be modeled based on the glTF tile format.
