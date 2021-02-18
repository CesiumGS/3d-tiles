# 3DTILES_content_gltf

**Version 0.0.0**, November 6, 2020

## Contributors

* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Patrick Cozzi, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 specification.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Schema Updates](#schema-updates)
  - [Examples](#examples)

## Overview

This extension allows a tileset to use [glTF](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0) and [GLB](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#glb-file-format-specification) models directly as tile content.

Using glTF directly simplifies content creation, as no additional binary header needs to be added to each file. Using other glTF extensions, glTF models can be extended with instancing, metadata and compression to achieve near feature parity with the existing 3D Tiles formats.

Explicit file extensions are optional. Valid implementations may ignore it and identify a content's format by the magic field in its header (for `GLB`) or by parsing the JSON (for `glTF`). This extension allows tiles to reference glTF content but does not mandate that all tiles reference glTF content.

## Optional vs. Required

This extension is required, meaning it should be placed in the tileset JSON top-level `extensionsRequired` and `extensionsUsed` lists.

## Extension JSON

`3DTILES_content_gltf` is a property of the top-level `extensions` object and contains two optional properties:

* `extensionsUsed`: an array of glTF extensions used by glTF content in the tileset.
* `extensionsRequired`: an array of glTF extensions required by glTF content in the tileset.

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
    "geometricError": 70,
    "refine": "ADD",
    "content": {
      "uri": "model.gltf",
      "boundingVolume": {
        "region": [
          -1.3197004795898053,
          0.6988582109,
          -1.3196595204101946,
          0.6988897891,
          0,
          88
        ]
      }
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


