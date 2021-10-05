<!-- omit in toc -->
# 3DTILES_content_gltf

<!-- omit in toc -->
## Contributors

* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Patrick Cozzi, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Dependencies

Written against the 3D Tiles 1.0 specification.

<!-- omit in toc -->
## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Extension JSON](#extension-json)
- [Examples](#examples)
- [JSON Schema Reference](#json-schema-reference)
- [Appendix: Comparison with Existing Tile Formats](#appendix-comparison-with-existing-tile-formats)

## Overview

This extension allows a tileset to use [glTF](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0) assets directly as tile content. Both `glTF` JSON and `GLB` binary formats are supported.

Using glTF as a tile format simplifies content pipelines from creation to runtime. This allows greater compatibility with existing tools (e.g. 3D modeling software, validators, optimizers) that create or process glTF assets. Runtime engines that currently support glTF can more easily support 3D Tiles.

## Extension JSON

With this extension, the tile content may be a glTF asset. Runtime engines must be able to determine compatibility before loading the content. If the glTF asset uses or requires certain glTF extensions, then these extensions must be listed on the `3DTILES_content_gltf` object. This is a property of the top-level tileset `extensions` object with the following properties:

* `extensionsUsed`: an array of glTF extensions used by glTF content in the tileset.
* `extensionsRequired`: an array of glTF extensions required by glTF content in the tileset.

The following is an example of using the `3DTILES_content_gltf` extension to directly refer to a glTF asset, which in turn requires the `EXT_mesh_gpu_instancing` extension:

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": ["3DTILES_content_gltf"],
  "extensionsRequired": ["3DTILES_content_gltf"],
  "extensions": {
    "3DTILES_content_gltf": {
      "extensionsUsed": ["EXT_mesh_gpu_instancing"],
      "extensionsRequired": ["EXT_mesh_gpu_instancing"]
    }
  },
  "geometricError": 240,
  "root": {
    "boundingVolume": {
      "region": [
        -1.3197209591796106,
        0.6988424218,
        -1.3196390408203893,
        0.6989055782,
        0,
        88
      ]
    },
    "geometricError": 0,
    "refine": "ADD",
    "content": {
      "uri": "trees.gltf"
    }
  }
}
```

## Examples

A simple example can be found [here](examples/tileset).

## Appendix: Comparison with Existing Tile Formats

This section covers the differences between existing tile formats and the new glTF approach to tile content.

<!-- omit in toc -->
### Batched 3D Model (b3dm)

[Batched 3D Model](../../specification/TileFormats/Batched3DModel) is a wrapper around a binary glTF that includes additional information in its Feature Table and Batch Table. Batched 3D Model content can be converted into glTF content with the following changes: 

* The `RTC_CENTER` can be added to the translation component of the root node of the glTF asset.
* Batch Tables and Batch IDs can be represented using [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_feature_metadata).

<!-- omit in toc -->
### Instanced 3D Model (i3dm)

[Instanced 3D Model](../../specification/TileFormats/Instanced3DModel) instances a glTF asset (embedded or external) and provides per-instance transforms and batch IDs.

* The `RTC_CENTER` can be added to the translation component of the root node of the glTF asset.
* glTF 2.0 supports reuse of the same mesh at multiple translations, rotations, and scales. To optimize reused meshes for more efficient GPU instancing, [`EXT_mesh_gpu_instancing`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Vendor/EXT_mesh_gpu_instancing) may be used.
* Batch Table and Batch IDs can be represented using [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/blob/3d-tiles-next/extensions/2.0/Vendor/EXT_feature_metadata). Per-instance and multi-instance metadata is supported.
* `EAST_NORTH_UP` is not directly supported, but can be represented using per-instance rotations.

<!-- omit in toc -->
### Point Cloud (pnts)

[Point Cloud](../../specification/TileFormats/PointCloud) can be represented as a glTF using the primitive mode `0` (`POINTS`).

* The `RTC_CENTER` can be added to the translation component of the root node of the glTF asset.
* Feature table properties like `POSITION`, `COLOR`, and `NORMAL` may be stored as glTF attributes.
* [`EXT_meshopt_compression`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Vendor/EXT_meshopt_compression) and [`KHR_mesh_quantization`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_mesh_quantization) may be used for point cloud compression. [`3DTILES_draco_point_compression`](../3DTILES_draco_point_compression) is not directly supported in glTF because [`KHR_draco_mesh_compression`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_draco_mesh_compression) only supports triangle meshes.
* Batch Table and Batch IDs can be represented using [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_feature_metadata). The extension supports both per-point properties and multi-point features in the same glTF.
* `CONSTANT_RGBA` is not directly supported in glTF, but can be represented by using per-point colors or runtime styling using [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/blob/3d-tiles-next/extensions/2.0/Vendor/EXT_feature_metadata).

<!-- omit in toc -->
### Composite (cmpt)

All inner contents of a [Composite](../../specification/TileFormats/Composite) may be combined into the same glTF as separate nodes, meshes, or primitives, at the tileset author's discretion. [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_feature_metadata) can store property data for each inner content. Alternatively, [`3DTILES_multiple_contents`](../3DTILES_multiple_contents) can be used to store multiple glTF contents in a single tile.