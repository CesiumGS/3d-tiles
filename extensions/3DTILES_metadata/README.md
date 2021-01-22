# 3DTILES_metadata

This extension provides a formal mechanism for attaching application-specific metadata to various components of 3D Tiles including tiles, content, and the tileset.

Metadata classes are declared and assigned based on the [Cesium 3D Metadata Specification](../../specification/Metadata/README.md).

## Changelog

* [**Version 0.0.0**](0.0.0/README.md) November 6, 2020
    * Initial draft
* [**Version 1.0.0**](1.0.0/README.md) Current
    * Updated to Cesium 3D Metadata Specification Version 1.0.0. Changes include:
      * Removed `FLOAT16` type
      * Removed `BLOB` type and `blobByteLength`
      * Removed `stringByteLength`
      * [TODO] Added enum support
      * [TODO] Added semantic
    * Added `groups` to the top-level `3DTILES_metadata` extension object. Groups contain metadata about a group of contents. Individual contents may be assigned to groups with the `3DTILES_metadata` content extension object.
    * Added tile metadata. A tile may specify its class and property values with the `3DTILES_metadata` tile extension object. When the `3DTILES_implicit_tiling` extension is used property values are stored in subtree buffer views.