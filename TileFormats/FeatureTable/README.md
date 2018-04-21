# Feature Table

## Contributors

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)
* Rob Taglang, [@lasalvavida](https://github.com/lasalvavida)
* Dan Bagnell, [@bagnell](https://github.com/bagnell)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Layout](#layout)
   * [JSON header](#json-header)
   * [Binary body](#binary-body)
* [Implementation notes](#implementation-notes)

## Overview

A _feature table_ describes position and appearance properties for each feature in a tile.  The [batch table](../BatchTable/README.md), on the other hand, contains per-feature application-specific metadata not necessarily used for rendering.

A feature table is used by the following tile formats:
* [Batched 3D model](../Batched3DModel/README.md) (b3dm) - each model is a feature.
* [Instanced 3D model](../Instanced3DModel/README.md) (i3dm) - each model instance is a feature.
* [Point cloud](../PointCloud/README.md) (pnts) - each point is a feature.
* [Vector](../VectorData/README.md) (vctr) - each point/polyline/polygon is a feature.

Per-feature properties are defined using tile format-specific semantics defined in each tile format's specification.  For example, for _instanced 3D model_, `SCALE_NON_UNIFORM` defines the non-uniform scale applied to each 3D model instance.

## Layout

A feature table is composed of two parts: a JSON header and an optional binary body. The JSON property names are tile format-specific semantics, and their values can either be defined directly in the JSON, or refer to sections in the binary body.  It is more efficient to store long numeric arrays in the binary body.

![feature table layout](figures/feature-table-layout.png)_Feature table layout._

When a tile format includes a feature table, the feature table immediately follows the tile's header.  The header will also contain `featureTableJSONByteLength` and `featureTableBinaryByteLength` `uint32` fields, which can be used to extract each respective part of the feature table.

Code for reading the feature table can be found in [Cesium3DTileFeatureTable.js](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Scene/Cesium3DTileFeatureTable.js) in the Cesium implementation of 3D Tiles.

### JSON header

Feature table values can be represented in the JSON header in three different ways:

1. A single value or object, e.g., `"INSTANCES_LENGTH" : 4`.
   * This is used for global semantics like `"INSTANCES_LENGTH"`, which defines the number of model instances in an instanced 3D model tile.
2. An array of values, e.g., `"POSITION" : [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]`.
   * This is used for per-feature semantics like `"POSITION"` in instanced 3D model.  Above, each `POSITION` refers to a `float32[3]` data type so there are three features: `Feature 0's position`=`(1.0, 0.0, 0.0)`, `Feature 1's position`=`(0.0, 1.0, 0.0)`, `Feature 2's position`=`(0.0, 0.0, 1.0)`.
3. A reference to data in the binary body, denoted by an object with a `byteOffset` property, e.g., `"SCALE" : { "byteOffset" : 24}`.
   * `byteOffset` is a zero-based offset relative to the start of the binary body.
   * The semantic defines the allowed data type, e.g., when `"POSITION"` in instanced model refers to the binary body, the component type is `FLOAT` and the number of components is `3`.
   * Some semantics allow for overriding the implicit `componentType`. These cases are specified in each tile format, e.g., `"BATCH_ID" : { "byteOffset" : 24, "componentType" : "UNSIGNED_BYTE"}`.
The only valid properties in the JSON header are the defined semantics by the tile format.  Application-specific data should be stored in the batch table.

JSON schema feature table definitions can be found in [featureTable.schema.json](../../schema/featureTable.schema.json).

### Binary body

When the JSON header includes a reference to the binary, the provided `byteOffset` is used to index into the data. 

![feature table binary index](figures/feature-table-binary-index.png)_Indexing into the feature table binary body._

Values can be retrieved using the number of features, `featuresLength`; the desired feature id, `featureId`; and the data type (component type and number of components) for the feature semantic.

For example, using the `POSITION` semantic, which has a `float32[3]` data type:

```javascript
var byteOffset = featureTableJSON.POSITION.byteOffset;

var positionArray = new Float32Array(featureTableBinary.buffer, byteOffset, featuresLength * 3); // There are three components for each POSITION feature.
var position = positionArray.subarray(featureId * 3, featureId * 3 + 3); // Using subarray creates a view into the array, and not a new array.
```

## Implementation notes

In JavaScript, a `TypedArray` cannot be created on data unless it is byte-aligned to the data type.
For example, a `Float32Array` must be stored in memory such that its data begins on a byte multiple of four since each `float` contains four bytes.

The string generated from the JSON header should be padded with space characters in order to ensure that the binary body is byte-aligned.
The binary body should also be padded if necessary when there is data following the feature table.
