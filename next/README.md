# 3D Tiles Next

## Overview

**3D Tiles Next** is a set of new capabilities for the future of 3D Tiles. These capabilities are provided as extensions to the [3D Tiles 1.0](../specification) specification, which may be incorporated into 3D Tiles 2.0 in the future.

- [Tile Content](#tile-content) — glTF 2.0 content may be referenced directly as tile content, without intermediate formats. Tiles may reference multiple contents, useful for visual organization and UI management similar to map layers. glTF is the future of 3D Tiles. In the future, 3D Tiles 1.0 formats (B3DM, I3DM, PNTS) will be represented as glTF models.
- [Implicit Tiling](#implicit-tiling) — Common subdivision schemes and spatial index patterns may be declared without listing bounding volumes exhaustively. Enables new algorithms and optimization including faster traversal, raycasting, random access, and spatial queries.
- [Metadata](#metadata) — 3D Tiles Next dramatically expands the usefulness and flexibility of metadata in 3D Tiles, adding: a well-defined type system, new encoding options (e.g. JSON or binary), and a wide range of granularity options. Metadata may be associated with high-level objects like tilesets, tiles, or tile content groups, or may have fine-grained associations with individual vertices and texels on glTF 2.0 geometry.

## Tile Content

_**Overview:** glTF 2.0 content may be referenced directly as tile content, without intermediate formats. Tiles may reference multiple contents, useful for visual organization and UI management similar to map layers. glTF is the future of 3D Tiles. In the future, 3D Tiles 1.0 formats (B3DM, I3DM, PNTS) will be represented as glTF models._

|   | Extension |
|---|-----------|
| <img src="figures/content-gltf.png" width="600px" alt="Tileset with glTF content"> | [`3DTILES_content_gltf`](../extensions/3DTILES_content_gltf) (3D Tiles 1.0 extension) <br> Allows references to glTF models (`.gltf` `.glb`) directly in `tile.content`, without intermediate formats. This allows for easier integration with software producing the standard glTF files, but not formats specific to 3D Tiles like B3DM, I3DM, and PNTS. |
| <img src="figures/multiple-contents.png" width="600px" alt="Tileset with multiple contents"> | [`3DTILES_multiple_contents`](../extensions/3DTILES_multiple_contents) (3D Tiles 1.0 extension) <br> Allows storing more than one content model per tile. In effect, this extension enables storing more than one content in a single region of space. Contents can be organized in various ways — e.g. map layers or arbitrary groupings — and becomes particularly useful when combined with content group metadata. |

## Implicit Tiling

_**Overview:** Common subdivision schemes and spatial index patterns may be declared without listing bounding volumes exhaustively. Enables new algorithms and optimization including faster traversal, raycasting, random access, and spatial queries. Improves interoperability with geospatial formats and libraries such as CDB, TMS, WMTS, and S2._

|   | Extension |
|---|-----------|
| <img src="figures/implicit-tiling-small.png" width="600px" alt="Implicit Tiling"> | [`3DTILES_implicit_tiling`](../extensions/3DTILES_implicit_tiling) (3D Tiles 1.0 extension) <br> Implicit tiling is an alternate method for describing tileset structure. Binary subtree files represent which tiles and contents exist within a fixed subdivision structure, such that tiles can be uniquely identified by their coordinates. The compact tree representation enables improved tree traversal algorithms, raycasting, and faster spatial queries. |
| <img src="figures/s2.png" width="600px" alt="S2 Tiling Scheme"> | [`3DTILES_bounding_volume_S2`](../extensions/3DTILES_bounding_volume_S2) (3D Tiles 1.0 extension) <br> Enables the use of [S2 Geometry](http://s2geometry.io/) as a bounding volume and tiling scheme. Particularly when combined with `3DTILES_implicit_tiling`, S2 is well suited for global scale tilesets, minimizing distortion near the poles. Cells at the same level of detail have approximately equal area. |

## Metadata

_**Overview:** 3D Tiles Next dramatically expands the usefulness and flexibility of metadata in 3D Tiles, adding: a well-defined type system, new encoding options (e.g. JSON or binary), and a wide range of granularity options. Metadata may be associated with high-level objects like tilesets, tiles, or tile content groups, or may have fine-grained associations with individual vertices and texels on glTF 2.0 geometry._

The foundation of these new metadata extensions is the format-agnostic [3D Metadata Specification](../specification/Metadata). The specification defines key concepts including schemas, property types, storage formats, and semantic meanings of properties. Extensions to 3D Tiles (`3DTILES_metadata`) and glTF 2.0 (`EXT_mesh_features`) are available already, and other content formats can be extended to implement the common metadata definitions of the 3D Metadata Specification in the future.

|   | Extension |
|---|-----------|
| <img src="figures/metadata-granularity.png" alt="Metadata in 3D Tiles" width="600"> | [`3DTILES_metadata`](../extensions/3DTILES_metadata) (3D Tiles 1.0 extension) <br> Defines 3D Metadata for tilesets, tiles, and tile content groups. Complements other 3D Tiles Next extensions with additional metadata-related features: <br><br>• In `3DTILES_implicit_tiling` tile metadata may be stored compactly in binary subtree files, allowing efficient streaming of large global tilesets and their metadata. <br>• In `3DTILES_multiple_contents` each tile content may be associated with a group and with group metadata, enabling improved content organization, styling, and filtering. |
| <img src="figures/feature-metadata.png" alt="Metadata in glTF" width="600"> | [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) (glTF 2.0 extension) <br> Defines 3D Metadata in glTF 2.0 assets. Combined with `3DTILES_content_gltf`, metadata is associated with subcomponents ("features") within a tile's content at various levels of granularity: <br><br>• *Per vertex:* Vertices may be grouped into features each having associated properties, similar to Batch Tables in 3D Tiles 1.0. <br>• *Per texel*: Textures storing property values and feature IDs allow detailed metadata even for optimized, low-poly geometry. <br>• *Per GPU instance:* GPU instances (defined by glTF extension `EXT_mesh_gpu_instancing`) may be assigned individual properties, similar to `.i3dm` files in 3D Tiles 1.0.
 |

For further use cases of feature metadata, see [examples](https://github.com/CesiumGS/glTF/blob/proposal-EXT_mesh_features/extensions/2.0/Vendor/EXT_mesh_features/README.md#examples) in the `EXT_mesh_features` specification. Together, `3DTILES_metadata` and `EXT_mesh_features` allow flexible definitions of metadata at any level of granularity within a tileset. The illustration below provides an overview of these levels, in which the first four levels are provided by `3DTILES_metadata` and the lowest level ("Features") is provided by `EXT_mesh_features`.

![Available metadata granularity, including tilesets, tiles, tile content groups, and features.](./figures/metadata-granularity-extended.png)