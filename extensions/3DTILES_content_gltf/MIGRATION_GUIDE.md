# Conversion of Existing Tile Formats

This document covers the differences between existing tile formats and the new glTF approach to tile content, and describes how existing tile formats can be converted into equivalent glTF content.

### Batched 3D Model (b3dm)

[Batched 3D Model](../../specification/TileFormats/Batched3DModel) is a wrapper around a binary glTF that includes additional information in its Feature Table and Batch Table. Batched 3D Model content can be converted into glTF content with the following changes: 

* The [`RTC_CENTER`](https://github.com/CesiumGS/3d-tiles/tree/main/specification/TileFormats/Batched3DModel#coordinate-system) can be added to the translation component of the root node of the glTF asset.
* Batch Tables and Batch IDs can be represented using [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features).

### Instanced 3D Model (i3dm)

[Instanced 3D Model](../../specification/TileFormats/Instanced3DModel) instances a glTF asset (embedded or external) and provides per-instance transforms and batch IDs.

* The `RTC_CENTER` can be added to the translation component of the root node of the glTF asset.
* glTF 2.0 supports reuse of the same mesh at multiple translations, rotations, and scales. To optimize reused meshes for more efficient GPU instancing, [`EXT_mesh_gpu_instancing`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Vendor/EXT_mesh_gpu_instancing) may be used.
* Batch Table and Batch IDs can be represented using [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/blob/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features). Per-instance and multi-instance metadata is supported.
* `EAST_NORTH_UP` is not directly supported, but can be represented using per-instance rotations.

### Point Cloud (pnts)

[Point Cloud](../../specification/TileFormats/PointCloud) can be represented as a glTF using the primitive mode `0` (`POINTS`).

* The `RTC_CENTER` can be added to the translation component of the root node of the glTF asset.
* Feature table properties like `POSITION`, `COLOR`, and `NORMAL` may be stored as glTF attributes.
* [`EXT_meshopt_compression`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Vendor/EXT_meshopt_compression) and [`KHR_mesh_quantization`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_mesh_quantization) may be used for point cloud compression. [`3DTILES_draco_point_compression`](../3DTILES_draco_point_compression) is not directly supported in glTF because [`KHR_draco_mesh_compression`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_draco_mesh_compression) only supports triangle meshes.
* Batch Table and Batch IDs can be represented using [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features). The extension supports both per-point properties and multi-point features in the same glTF.
* `CONSTANT_RGBA` is not directly supported in glTF, but can be represented by using per-point colors or runtime styling using [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/blob/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features).

### Composite (cmpt)

All inner contents of a [Composite](../../specification/TileFormats/Composite) may be combined into the same glTF as separate nodes, meshes, or primitives, at the tileset author's discretion. [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) can store property data for each inner content. Alternatively, [`3DTILES_multiple_contents`](../3DTILES_multiple_contents) can be used to store multiple glTF contents in a single tile.
