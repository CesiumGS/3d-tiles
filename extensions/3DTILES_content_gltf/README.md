# 3DTILES_content_gltf Extension

## Contributors

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 spec.

## Contents

  - [Overview](#overview)
  - [Format Comparison](#format-comparison)
    - [Batched 3D Model (b3dm)](#batched-3d-model-b3dm)
    - [Instanced 3D Model (i3dm)](#instanced-3d-model-i3dm)
    - [Point Cloud (pnts)](#point-cloud-pnts)
    - [Composite (cmpt)](#composite-cmpt)
  - [Optional vs. Required](#optional-vs-required)
  - [Schema Updates](#schema-updates)
  - [Examples](#examples)

## Overview

This extension allows a tileset to use [glTF 2.0](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0) and [GLB](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#glb-file-format-specification) models directly as tile content.

Using glTF directly simplifies runtime implementations and content pipelines that already support glTF but don't support 3D Tiles native formats. glTF models may be extended with instancing, feature metadata, and compression extensions to achieve near feature parity with the existing 3D Tiles formats:

* [Batched 3D Model](../../specification/TileFormats/Batched3DModel/README.md)
* [Instanced 3D Model](../../specification/TileFormats/Instanced3DModel/README.md)
* [Point Cloud](../../specification/TileFormats/PointCloud/README.md)
* [Composite](../../specification/TileFormats/Composite/README.md)

Explicit file extensions are optional. Valid implementations may ignore it and identify a content's format by the magic field in its header (for `GLB`) or by parsing the JSON (for `glTF`). This extension allows tiles to reference glTF content but does not mandate that all tiles reference glTF content.

## Format Comparison

The sections below describe the differences between native 3D Tiles formats and glTF. These sections are non-normative.

### Batched 3D Model (b3dm)

Since [`b3dm`](../../specification/TileFormats/Batched3DModel/README.md) is a thin wrapper around binary glTF there aren't too many differences when using glTF directly.

* `RTC_CENTER` may be represented as a glTF node translation.
* Batch Table and Batch IDs may be stored with [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/pull/1).

### Instanced 3D Model (i3dm)

[`i3dm`](../../specification/TileFormats/Instanced3DModel) instances a glTF model (embedded or external) and provides per-instance transforms and feature IDs.

* [`EXT_mesh_gpu_instancing`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Vendor/EXT_mesh_gpu_instancing) may be used to instance glTF nodes.
* `RTC_CENTER` may be represented as a glTF node translation.
* Batch Table and Batch IDs may be stored with [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/pull/1). Per-instance properties are supported.
* No glTF support for compressed per-instance translations and rotations, uniform scale, multi-instance properties, and `EAST_NORTH_UP`.
* Longer term a 3D Tiles vector tile format may instance models as point features.

### Point Cloud (pnts)

glTF natively supports point clouds with the primitive mode `0` (`POINT`). Concepts in the [`pnts`](../../specification/TileFormats/PointCloud) format map well to glTF.

* Feature table properties like like `POSITION`, `COLOR`, and `NORMAL` may be stored as glTF attributes.
* [`EXT_meshopt_compression`](https://github.com/KhronosGroup/glTF/pull/1830) and [`KHR_mesh_quantization`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_mesh_quantization) may be used for point cloud compression. `POSITION_QUANTIZED`, `NORMAL_OCT16P`, `RGB565`, and [`3DTILES_draco_point_compression`](https://github.com/CesiumGS/3d-tiles/tree/master/extensions/3DTILES_draco_point_compression) are not directly supported in glTF.
* `RTC_CENTER` may be represented as a glTF node translation.
* Batch Table and Batch IDs may be stored with [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/pull/1). The extension supports both per-point properties and multi-point properties in the same glTF.
* No glTF support for `CONSTANT_RGBA`.

### Composite (cmpt)

All inner contents may be bundled into the same glTF as separate nodes, meshes, or primitives, up to the tileset author's discretion. [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/pull/1) supports multiple feature collections.

## Optional vs. Required

This extension is required, meaning it should be placed in the tileset JSON top-level `extensionsRequired` and `extensionsUsed` lists.

## Schema Updates

`3DTILES_content_gltf` is a property of the top-level `extensions` object and contains two optional properties:

* `gltfExtensionsUsed`: An array of glTF extensions used by glTF content in the tileset.
* `gltfExtensionsRequired`: An array of glTF extensions required by glTF content in the tileset.

The full JSON schema can be found in [tileset.3DTILES_content_gltf.schema.json](schema/tileset.3DTILES_content_gltf.schema.json).

## Examples

A simple example can be found [here](examples/tileset).