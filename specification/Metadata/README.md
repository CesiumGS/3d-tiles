# Cesium 3D Metadata Specification

The Cesium 3D Metadata Specification defines a standard metadata format for 3D data.

For usage see:

* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata) - 3D Tiles extension that assigns metadata to various components of 3D Tiles
* [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/master/extensions/2.0/Vendor/EXT_feature_metadata/1.0.0) - glTF extension that assigns metadata to features in a model on a per-vertex, per-texel, or per-instance basis

See the [Cesium Metadata Semantic Reference](Semantics) for built-in semantics for 3D Tiles and glTF.

## Changelog

* [**Version 0.0.0**](0.0.0) November 6, 2020
    * Initial draft
* [**Version 1.0.0**](1.0.0) [TODO: date]
    * The specification has been revised to focus on the core concepts of schemas (including classes, enums, and properties) and formats for encoding metadata. It is now language independent. The JSON schema has been removed.
    * Added schemas which contain classes and enums
    * Added enum support
    * Added ability to assign a semantic identifiers to properties
    * Removed blob support
    * Removed special handling for fixed-length strings
