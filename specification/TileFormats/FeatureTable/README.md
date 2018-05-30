# Feature Table

## Contributors

_This section is non-normative_

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)
* Rob Taglang, [@lasalvavida](https://github.com/lasalvavida)
* Dan Bagnell, [@bagnell](https://github.com/bagnell)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Layout](#layout)
   * [Padding](#padding)
   * [JSON header](#json-header)
      * [Property reference](#property-reference)
   * [Binary body](#binary-body)
* [Implementation example](#implementation-example)

## Overview

A _Feature Table_ describes position and appearance properties for each feature in a tile.  The [Batch Table](../BatchTable/README.md), on the other hand, contains per-feature application-specific metadata not necessarily used for rendering.

A Feature Table is used by tile formats like [Batched 3D Model](../Batched3DModel/README.md) (b3dm) where each model is a feature, and [Point Cloud](../PointCloud/README.md) (pnts) where each point is a feature.

Per-feature properties are defined using tile format-specific semantics defined in each tile format's specification.  For example, for _Instanced 3D Model_, `SCALE_NON_UNIFORM` defines the non-uniform scale applied to each 3D model instance.

## Layout

A Feature Table is composed of two parts: a JSON header and an optional binary body in little endian. The JSON property names are tile format-specific semantics, and their values can either be defined directly in the JSON, or refer to sections in the binary body.  It is more efficient to store long numeric arrays in the binary body. The following figure shows the Feature Table layout:

![feature table layout](figures/feature-table-layout.png)

When a tile format includes a Feature Table, the Feature Table immediately follows the tile's header.  The header will also contain `featureTableJSONByteLength` and `featureTableBinaryByteLength` `uint32` fields, which can be used to extract each respective part of the Feature Table.

### Padding

The Feature Table binary body must start and end on an 8-byte alignment within the containing tile binary.

The JSON header must be padded with trailing Space characters (`0x20`) to satisfy alignment requirements of the Feature Table binary (if present).

### JSON header

Feature Table values can be represented in the JSON header in three different ways:

1. A single value or object, e.g., `"INSTANCES_LENGTH" : 4`.
   * This is used for global semantics like `"INSTANCES_LENGTH"`, which defines the number of model instances in an Instanced 3D Model tile.
2. An array of values, e.g., `"POSITION" : [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]`.
   * This is used for per-feature semantics like `"POSITION"` in Instanced 3D Model.  Above, each `POSITION` refers to a `float32[3]` data type so there are three features: `Feature 0's position`=`(1.0, 0.0, 0.0)`, `Feature 1's position`=`(0.0, 1.0, 0.0)`, `Feature 2's position`=`(0.0, 0.0, 1.0)`.
3. A reference to data in the binary body, denoted by an object with a `byteOffset` property, e.g., `"SCALE" : { "byteOffset" : 24}`.
   * `byteOffset` specifies a zero-based offset relative to the start of the binary body. The value of `byteOffset` must be a multiple of the size of the property's `componentType`, e.g., the `"POSITION"` property, which has the component `FLOAT`, must start at an offset of a multiple of `4`.
   * The semantic defines the allowed data type, e.g., when `"POSITION"` in Instanced 3D Model refers to the binary body, the component type is `FLOAT` and the number of components is `3`.
   * Some semantics allow for overriding the implicit `componentType`. These cases are specified in each tile format, e.g., `"BATCH_ID" : { "byteOffset" : 24, "componentType" : "UNSIGNED_BYTE"}`.
The only valid properties in the JSON header are the defined semantics by the tile format and optional `extras` and `extensions` properties.  Application-specific data should be stored in the Batch Table.

#### Property Reference

<a name="reference-feature-table"></a>
##### Feature Table

A set of semantics containing per-tile and per-feature values defining the position and appearance properties for features in a tile.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**extensions**|`object`|Dictionary object with extension-specific objects.|No|
|**extras**|`any`|Application-specific data.|No|

Additional properties are not allowed.

* **JSON schema**: [featureTable.schema.json](../../schema/featureTable.schema.json)

###### FeatureTable.extensions

Dictionary object with extension-specific objects.

* **Type**: `object`
* **Required**: No
* **Type of each property**: Extension

###### FeatureTable.extras

Application-specific data.

* **Type**: `any`
* **Required**: No



### Binary body

When the JSON header includes a reference to the binary, the provided `byteOffset` is used to index into the data. The following figure shows indexing into the Feature Table binary body:

![feature table binary index](figures/feature-table-binary-index.png)

Values can be retrieved using the number of features, `featuresLength`; the desired feature id, `featureId`; and the data type (component type and number of components) for the feature semantic.

## Implementation example

_This section is non-normative_

The following example accesses the position property using the `POSITION` semantic, which has a `float32[3]` data type:

```javascript
var byteOffset = featureTableJSON.POSITION.byteOffset;

var positionArray = new Float32Array(featureTableBinary.buffer, byteOffset, featuresLength * 3); // There are three components for each POSITION feature.
var position = positionArray.subarray(featureId * 3, featureId * 3 + 3); // Using subarray creates a view into the array, and not a new array.
```

Code for reading the Feature Table can be found in [`Cesium3DTileFeatureTable.js`](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Scene/Cesium3DTileFeatureTable.js) in the Cesium implementation of 3D Tiles.
