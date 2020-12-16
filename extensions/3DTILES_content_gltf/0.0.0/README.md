# 3DTILES_content_gltf

**Version 0.0.0**, November 6, 2020

## Contributors

* Sean Lilley, Cesium

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

Using glTF directly simplifies runtime implementations and content pipelines that already support glTF but don't support 3D Tiles native formats. glTF models may be extended with instancing, feature metadata, and compression extensions to achieve near feature parity with the existing 3D Tiles formats.

Explicit file extensions are optional. Valid implementations may ignore it and identify a content's format by the magic field in its header (for `GLB`) or by parsing the JSON (for `glTF`). This extension allows tiles to reference glTF content but does not mandate that all tiles reference glTF content.

## Optional vs. Required

This extension is required, meaning it should be placed in the tileset JSON top-level `extensionsRequired` and `extensionsUsed` lists.

## Schema Updates

`3DTILES_content_gltf` is a property of the top-level `extensions` object and contains two optional properties:

* `extensionsUsed`: an array of glTF extensions used by glTF content in the tileset.
* `extensionsRequired`: an array of glTF extensions required by glTF content in the tileset.

The full JSON schema can be found in [tileset.3DTILES_content_gltf.schema.json](schema/tileset.3DTILES_content_gltf.schema.json).

## Examples

A simple example can be found [here](examples/tileset).