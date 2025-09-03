# 3DTILES_content_gltf

## Contributors

* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Marco Hutter, Cesium
* Don McCurdy, Independent
* Patrick Cozzi, Cesium

## Status

Complete

## Dependencies

Written against the 3D Tiles 1.0 and 3D Tiles 1.1 specifications.

## Optional vs. Required

For a 3D Tiles 1.0 tileset that uses glTF content, this this extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

For a 3D Tiles 1.1 tileset, this extension is optional. A 3D Tiles 1.1 tileset can use glTF content without declaring this extension in its `extensionsUsed` list. _Only_ when the extension JSON object (as defined below) is used, then the extension must be placed in the `extensionsUsed` list of the tileset JSON. It may never be placed in the `extensionsRequired` list of a 3D Tiles 1.1 tileset.

## Overview

This extension allows a 3D Tiles 1.0 tileset to use [glTF 2.0](https://github.com/KhronosGroup/glTF/tree/main/specification/2.0) assets directly as tile content. Both `glTF` JSON and `GLB` binary formats are supported.

Using glTF as a tile format simplifies content pipelines from creation to runtime. This allows greater compatibility with existing tools (e.g. 3D modeling software, validators, optimizers) that create or process glTF assets. Runtime engines that currently support glTF can more easily support 3D Tiles. In many cases, existing tile formats can be converted into the corresponding glTF content, as described in the [Migration Guide](../specification/TileFormats/../../../specification/TileFormats/glTF/MIGRATION.adoc).

For both 3D Tiles 1.0 and 1.1, this extension allows specifying the extensions that are used and required by the glTF content that the tileset refers to. This allows runtime engines to determine compatibility immediately after loading the tileset JSON, but before loading the content.

## Extension JSON

*Defined in [tileset.3DTILES_content_gltf.schema.json](./schema/tileset.3DTILES_content_gltf.schema.json).*

The `3DTILES_content_gltf` object is a property of the top-level tileset `extensions` object. When it is defined, then it must list all extensions that are used or required by any glTF content that the tileset refers to, using the following properties:

* `extensionsUsed`: an array of glTF extensions used by any glTF content in the tileset.
* `extensionsRequired`: an array of glTF extensions required by any glTF content in the tileset.


## Examples

> **Example:** A 3D Tiles 1.0 tileset that uses glTF content in the root tile. It must declare the `3DTILES_content_gltf` extension in its `extensionsUsed` and `extensionsRequired` list, to indicate the use of glTF in a 3D Tiles 1.0 tileset. In this example, the glTF content does not use or require any glTF extensions, meaning that the `3DTILES_content_gltf` extension JSON object is not defined here. 
> 
> ```json
> {
>   "asset": {
>     "version": "1.0"
>   },
>   "extensionsUsed": ["3DTILES_content_gltf"],
>   "extensionsRequired": ["3DTILES_content_gltf"],
>   "geometricError": 240,
>   "root": {
>     "boundingVolume": {
>       "region": [
>         -1.3197209591796106,
>         0.6988424218,
>         -1.3196390408203893,
>         0.6989055782,
>         0,
>         88
>       ]
>     },
>     "geometricError": 0,
>     "refine": "ADD",
>     "content": {
>       "uri": "content.gltf"
>     }
>   }
> }
> ```


> **Example:** A 3D Tiles 1.1 tileset that uses the `3DTILES_content_gltf` extension. In this example, the glTF content uses (and requires) the  `EXT_mesh_gpu_instancing` extension. The `3DTILES_content_gltf` extension JSON is used to define the glTF extensions that are used and required by the glTF content.
> 
> ```json
> {
>   "asset": {
>     "version": "1.1"
>   },
>   "extensionsUsed": ["3DTILES_content_gltf"],
>   "extensions": {
>     "3DTILES_content_gltf": {
>       "extensionsUsed": ["EXT_mesh_gpu_instancing"],
>       "extensionsRequired": ["EXT_mesh_gpu_instancing"]
>     }
>   },
>   "geometricError": 240,
>   "root": {
>     "boundingVolume": {
>       "region": [
>         -1.3197209591796106,
>         0.6988424218,
>         -1.3196390408203893,
>         0.6989055782,
>         0,
>         88
>       ]
>     },
>     "geometricError": 0,
>     "refine": "ADD",
>     "content": {
>       "uri": "treeInstances.gltf"
>     }
>   }
> }
> ```
