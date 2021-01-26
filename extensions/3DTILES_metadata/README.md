# 3DTILES_metadata

This extension provides a formal mechanism for attaching application-specific metadata to various components of 3D Tiles.

## Changelog

* [**Version 0.0.0**](0.0.0/README.md) November 6, 2020
    * Initial draft
* [**Version 1.0.0**](1.0.0/README.md) [TODO: Date]
    * Updated to Cesium 3D Metadata Specification Version 1.0.0. Changes include:
      * Removed `FLOAT16` type
      * Removed `BLOB` type and `blobByteLength` property
      * Removed `stringByteLength` property
      * Added `semantic` property
      * Added `ENUM` type
    * Added `groups` to the top-level `3DTILES_metadata` extension object. Groups represent collections of contents. Contents are assigned to groups with the `3DTILES_metadata` content extension.
    * Added tile metadata. A tile may specify its class and property values with the `3DTILES_metadata` tile extension object.
    * Added `statistics` to the top-level `3DTILES_metadata` extension object. Statistics provide aggregate information about select properties within a tileset.