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

Using glTF as a tile format simplifies content pipelines from creation to runtime. This allows greater compatibility with existing tools (e.g. 3D modeling software, validators, optimizers) that create or process glTF assets. Runtime engines that currently support glTF can more easily support 3D Tiles. In many cases, existing tile formats can be converted into the corresponding glTF content, as described in the [Migration Guide](MIGRATION_GUIDE.md).

## Extension JSON

With this extension, the tile content may be a glTF asset. Runtime engines must be able to determine compatibility before loading the content. If the glTF asset uses or requires certain glTF extensions, then these extensions must also be listed in the `3DTILES_content_gltf` object. This is a property of the top-level tileset `extensions` object with the following properties:

* `extensionsUsed`: an array of glTF extensions used by any glTF content in the tileset.
* `extensionsRequired`: an array of glTF extensions required by any glTF content in the tileset.

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
