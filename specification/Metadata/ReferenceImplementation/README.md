<!-- omit in toc -->
# 3D Metadata Reference Implementation

This document defines a reference implementation of the concepts defined in the [3D Metadata Specification](../). The 3D Metadata Specification itself defines a standard format for structured metadata in 3D content in a way that is language- and format agnostic. The reference implementation described here is an implementation of these concepts: 

- The [Schema](Schema) is a JSON-based representation of [3D Metadata Schemas](../README.md#schemas) that describe the structure and types of metadata
- The [PropertyTable](PropertyTable) one form of a [Binary Table Format](../README.md#binary-table-format). It is a JSON-based description of how large amounts of metadata can be stored compactly in a binary form.

These serialization formats are used as a common basis for different implementations of the 3D Metadata Specification:

* [3D Tiles Metadata](../../README.md#metadata) - Assigns metadata to tilesets, tiles, and contents in 3D Tiles 1.1
* [`3DTILES_metadata`](../../../extensions/3DTILES_metadata/) - An extension for 3D Tiles 1.0 that assigns metadata to tilesets, tiles, and contents
* [`EXT_structural_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_structural_metadata) (glTF 2.0) —  Assigns metadata to vertices, texels, and features in a glTF asset

