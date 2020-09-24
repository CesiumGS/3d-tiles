# 3DTILES_feature_metadata

## Contributors

* Sean Lilley, Cesium
* Samuel Vargas, Cesium
* Sam Suhag, Cesium
* Patrick Cozzi, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 spec.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Schema Updates](#schema-updates)
  - [Examples](#examples)

## Overview

The top-level `3DTILES_feature_metadata` extension lists feature types that are referenced by tiles in the tileset. A client may use this information to populate a UI, filter metadata requests, or generate styles on-the-fly.

The actual list of feature types is up to the tileset author's discretion. The list may include a select few feature types, all feature types present in this tileset (or in external tilesets), or none at all.

Feature metadata may be embedded directly in glTF using the [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/feature-metadata/extensions/2.0/Vendor/EXT_feature_metadata) glTF extension, or alongside the glTF (or non-glTF tile content) as a separate JSON file.

When feature types are not present in the content's feature metadata, any references to feature types refer to the top-level feature types in `3DTILES_feature_metadata`.

## Optional vs. Required

This extension is optional, meaning it should be placed in the tileset JSON top-level `extensionsUsed` list, but not in the `extensionsRequired` list.

## Schema Updates

`3DTILES_feature_metadata` is a property of the top-level `extensions` object and contains one property:

* `featureTypes`: an array of feature types referenced by tiles in the tileset.

Feature metadata may be stored alongside tile content rather than embedded in tile content. A tile's `content` object may be extended with a `3DTILES_feature_metadata` object that points to an external file. The schema for the external file is defined in [external.featureMetadata.schema.json](schema/external.featureMetadata.schema.json) and mirrors glTF [`EXT_feature_metadata`](https://github.com/CesiumGS/glTF/tree/feature-metadata/extensions/2.0/Vendor/EXT_feature_metadata) with binary buffer storage for property arrays.

The full JSON schemas can be found [here](schema).

## Examples

See [metadata-sidecar](./examples/metadata-sidecar) and [metadata-embedded](./examples/metadata-embedded).