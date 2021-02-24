<!-- omit in toc -->
# 3DTILES_content_gltf

**Version 0.0.0**, November 6, 2020

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
## Contents

- [Overview](#overview)
- [Optional vs. Required](#optional-vs-required)
- [Extension JSON](#extension-json)
- [Examples](#examples)
- [JSON Schema Reference](#json-schema-reference)
- [Appendix A: Comparison with Existing Tile Formats](#appendix-a-comparison-with-existing-tile-formats)

## Overview

This extension allows a tileset to use [glTF](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0) models directly as tile content. Both `glTF` JSON and `GLB` binary formats are supported.

Using glTF as a tile format simplifies content pipelines from creation to runtime. This allows greater compatibility with existing tools (e.g. 3D modeling software, validators, optimizers) that create or process glTF models. Runtime engines that currently support glTF can more easily support 3D Tiles.

## Optional vs. Required

This extension is required, meaning it should be placed in the tileset JSON top-level `extensionsRequired` and `extensionsUsed` lists.

## Extension JSON

`3DTILES_content_gltf` is a property of the top-level `extensions` object and contains two optional properties:

* `extensionsUsed`: an array of glTF extensions used by glTF content in the tileset.
* `extensionsRequired`: an array of glTF extensions required by glTF content in the tileset.

Declaring glTF extensions in the tileset JSON allows the runtime engine to determine compatibility before loading content.

The full JSON schema can be found in [tileset.3DTILES_content_gltf.schema.json](schema/tileset.3DTILES_content_gltf.schema.json).

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

## JSON Schema Reference

<!-- omit in toc -->
* [`3DTILES_content_gltf extension`](#reference-3dtiles_content_gltf-extension) (root object)


---------------------------------------
<a name="reference-3dtiles_content_gltf-extension"></a>
<!-- omit in toc -->
### 3DTILES_content_gltf extension

3D Tiles extension that allows a tileset to use glTF 2.0 and GLB models directly as tile content.

**`3DTILES_content_gltf extension` Properties**

|   |Type|Description|Required|
|---|---|---|---|
|**extensionsUsed**|`string` `[1-*]`|An array of glTF extensions used by glTF content in the tileset.|No|
|**extensionsRequired**|`string` `[1-*]`|An array of glTF extensions required by glTF content in the tileset.|No|
|**extensions**|`any`||No|
|**extras**|`any`||No|

Additional properties are allowed.

<!-- omit in toc -->
#### 3DTILES_content_gltf extension.extensionsUsed

An array of glTF extensions used by glTF content in the tileset.

* **Type**: `string` `[1-*]`
* **Required**: No

<!-- omit in toc -->
#### 3DTILES_content_gltf extension.extensionsRequired

An array of glTF extensions required by glTF content in the tileset.

* **Type**: `string` `[1-*]`
* **Required**: No

<!-- omit in toc -->
#### 3DTILES_content_gltf extension.extensions

* **Type**: `any`
* **Required**: No

<!-- omit in toc -->
#### 3DTILES_content_gltf extension.extras

* **Type**: `any`
* **Required**: No


## Appendix A: Comparison with Existing Tile Formats

In Cesium 3D Tiles 1.0, tile formats such as Batched 3D Model and Instanced 3D Model are glTF files with additional header information and metadata. This section covers the differences between these formats and the new glTF approach to tile content.

<!-- omit in toc -->
### Batched 3D Model (b3dm)

[`b3dm`](../../../specification/TileFormats/Batched3DModel) is a wrapper around a binary glTF. It includes additional information in its header, Feature Table and Batch Table. `b3dm` content can be represented in glTF directly with the following changes: 

* `RTC_CENTER` can instead be stored in a glTF node translation.
* Batch Tables and Batch IDs can be represented using [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/master/extensions/2.0/Vendor/EXT_feature_metadata/1.0.0).

<!-- omit in toc -->
### Instanced 3D Model (i3dm)

[`i3dm`](../../../specification/TileFormats/Instanced3DModel) instances a glTF model (embedded or external) and provides per-instance transforms and feature IDs.

* [`EXT_mesh_gpu_instancing`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Vendor/EXT_mesh_gpu_instancing) may be used to instance glTF nodes. This supports per-instance translations, rotations, and scales. 
* `RTC_CENTER` can instead be stored in a glTF node translation.
* Batch Table and Batch IDs can be represented using [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/pull/1). Per-instance and multi-instance metadata are supported.
* `EAST_NORTH_UP` is not directly supported, but can be represented using per-instance rotations.

<!-- omit in toc -->
### Point Cloud (pnts)

glTF natively supports point clouds with the primitive mode `0` (`POINT`). Concepts in the [`pnts`](../../../specification/TileFormats/PointCloud) format map well to glTF.

* Feature table properties like like `POSITION`, `COLOR`, and `NORMAL` may be stored as glTF attributes.
* [`EXT_meshopt_compression`](https://github.com/KhronosGroup/glTF/pull/1830) and [`KHR_mesh_quantization`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_mesh_quantization) may be used for point cloud compression. [`3DTILES_draco_point_compression`](https://github.com/CesiumGS/3d-tiles/tree/master/extensions/3DTILES_draco_point_compression) is not directly supported in glTF because [`KHR_draco_mesh_compression`](https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_draco_mesh_compression) supports only triangle meshes.
* `RTC_CENTER` can instead be stored in a glTF node translation.
* Batch Table and Batch IDs can be represented using [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/pull/1). The extension supports both per-point metadata and multi-point metadata in the same glTF.
* `CONSTANT_RGBA` is not directly supported in glTF, but can be represented by using per-point colors or runtime styling using `EXT_feature_metadata`.

<!-- omit in toc -->
### Composite (cmpt)

All inner contents may be combined into the same glTF as separate nodes, meshes, or primitives, at the tileset author's discretion. [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/master/extensions/2.0/Vendor/EXT_feature_metadata/1.0.0) supports multiple feature tables. Alternatively, [`3DTILES_multiple_contents`](../../3DTILES_multiple_contents/) can be used to store multiple glTF models in a single tile.