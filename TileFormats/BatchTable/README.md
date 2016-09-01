# Batch Table

## Contributors

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)
* Rob Taglang, [@lasalvavida](https://github.com/lasalvavida)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Overview

A _Batch Table_ contains per-feature application-specific metadata in a tile. These properties may be queried at runtime for declarative styling and application-specific use cases such as populating a UI or issuing a REST API request.  Some example Batch Table properties are building heights, cartographic coordinates, and database primary keys.

A Batch Table is used by the following tile formats:
* [Batched 3D Model](../Batched3DModel/README.md) (b3dm)
* [Instanced 3D Model](../Instanced3DModel/README.md) (i3dm)
* [Point Cloud](../PointCloud/README.md) (pnts)
* [Vector](../VectorData/README.md) (vctr)

## Layout

A Batch Table is composed of two parts: a JSON header and an optional binary body. The JSON describes the properties, whose values can either be defined directly in the JSON as an array, or refer to sections in the binary body.  It is more efficient to store long numeric arrays in the binary body.

**Figure 1**: Batch Table layout

![batch table layout](figures/batch-table-layout.png)

When a tile format includes a Batch Table, the Batch Table immediately follows the tile's Feature Table if it exists.  Otherwise, the Batch Table immediately follows the tile's header.
The header will also contain `batchTableJSONByteLength` and `batchTableBinaryByteLength` `uint32` fields, which can be used to extract each respective part of the Batch Table.

Code for reading the Batch Table can be found in [Cesium3DTileBatchTable.js](https://github.com/AnalyticalGraphicsInc/cesium/blob/3d-tiles/Source/Scene/Cesium3DTileBatchTable.js) in the Cesium implementation of 3D Tiles.

## JSON Header

Batch Table values can be represented in the JSON header in two different ways.

1. An array of values. (e.g. `"name" : ['name1', 'name2', 'name3']` or `"height" : [10.0, 20.0, 15.0]`)
    * Array elements can be any valid JSON data type, including objects and arrays.  Elements may be `null`.
    * The length of each array is equal to `batchLength` which is specified in each tile format.  This is the number of features in the tile.  For example, `batchLength` may be the number of models in a b3dm tile, the number of instances in a i3dm tile, or the number of points (or number of sections) in a pnts tile.
2. A reference to data in the binary body, denoted by an object with `byteOffset`, `componentType`, and `type` properties property. (e.g. `"height" : { "byteOffset" : 24, "componentType" : "FLOAT", "type" : "SCALAR"}`).
    * `byteOffset` is a zero-based offset relative to the start of the binary body.
    * `componentType` is the datatype of components in the attribute. Allowed values are `"BYTE"`, `"UNSIGNED_BYTE"`, `"SHORT"`, `"UNSIGNED_SHORT"`, `"INT"`, `"UNSIGNED_INT"`, `"FLOAT"`, and `"DOUBLE"`.
    * `type` specifies if the property is a scalar, vector, or matrix. Allowed values are `"SCALAR"`, `"VEC2"`, `"VEC3"`, `"VEC4"`, `"MAT2"`, `"MAT3"`, and `"MAT4"`. Matrices are stored in the binary body in column-major order.

The Batch Table JSON is a `UTF-8` string containing JSON. It can be extracted from the arraybuffer using the `TextDecoder` JavaScript API and transformed to a JavaScript object with `JSON.parse`.

A `batchId` is used to access elements in each array and extract the corresponding properties. For example, the following Batch Table has properties for a batch of two features:
```json
{
    "id" : ["unique id", "another unique id"],
    "displayName" : ["Building name", "Another building name"],
    "yearBuilt" : [1999, 2015],
    "address" : [{"street" : "Main Street", "houseNumber" : "1"}, {"street" : "Main Street", "houseNumber" : "2"}]
}
```

The properties for the feature with `batchId = 0` are
```javascript
id[0] = 'unique id';
displayName[0] = 'Building name';
yearBuilt[0] = 1999;
address[0] = {street : 'Main Street', houseNumber : '1'};
```

The properties for `batchId = 1` are
```javascript
id[1] = 'another unique id';
displayName[1] = 'Another building name';
yearBuilt[1] = 2015;
address[1] = {street : 'Main Street', houseNumber : '2'};
```

JSON Schema Batch Table definitions can be found in [batchTable.schema.json](../../schema/batchTable.schema.json).

## Binary Body

When the JSON header includes a reference to the binary section, the provided `byteOffset` is used to index into the data. 

**Figure 2**: Indexing into the Batch Table binary body

![batch table binary index](figures/batch-table-binary-index.png)

Values can be retrieved using the number of features, `batchLength`, the desired batch id, `batchId`, and the `componentType` and `type` defined in the JSON header.

The following tables can be used to compute the byte size of a property.

| `componentType` | Size in bytes |
| --- | --- |
| `"BYTE"` | 1 |
| `"UNSIGNED_BYTE"` | 1 |
| `"SHORT"` | 2 |
| `"UNSIGNED_SHORT"` | 2 |
| `"INT"` | 4 |
| `"UNSIGNED_INT"` | 4 |
| `"FLOAT"` | 4 |
| `"DOUBLE"` | 8 |

| `type` | Number of components |
| --- | --- |
| `"SCALAR"` | 1 |
| `"VEC2"` | 2 |
| `"VEC3"` | 3 |
| `"VEC4"` | 4 |
| `"MAT2"` | 4 |
| `"MAT3"` | 9 |
| `"MAT4"` | 16 |

For example, given the following Batch Table JSON with `batchLength` of 10

```json
{
    "height" : {
        "byteOffset" : 0,
        "componentType" : "FLOAT",
        "type" : "SCALAR"
    },
    "cartographic" : {
        "byteOffset" : 40,
        "componentType" : "DOUBLE",
        "type" : "VEC3"
    }
}
```

To get the `"height"` values:

```javascript
var height = batchTableJSON.height;
var byteOffset = height.byteOffset;
var componentType = height.componentType;
var type = height.type;

var heightArrayByteLength = batchLength * sizeInBytes(componentType) * numberOfComponents(type); // 10 * 4 * 1
var heightArray = new Float32Array(batchTableBinary.buffer, byteOffset, heightArrayByteLength);
var heightOfFeature = heightArray[batchId];
```

To get the `"cartographic"` values:

```javascript
var cartographic = batchTableJSON.cartographic;
var byteOffset = cartographic.byteOffset;
var componentType = cartographic.componentType;
var type = cartographic.type;
var componentSizeInBytes = sizeInBytes(componentType)
var numberOfComponents = numberOfComponents(type);

var cartographicArrayByteLength = batchLength * componentSizeInBytes * numberOfComponents // 10 * 8 * 3
var cartographicArray = new Float64Array(batchTableBinary.buffer, byteOffset, cartographicArrayByteLength);
var cartographicOfFeature = positionArray.subarray(batchId * numberOfComponents, batchId * numberOfComponents + numberOfComponents); // Using subarray creates a view into the array, and not a new array.
```

## Implementation Notes

In JavaScript, a `TypedArray` cannot be created on data unless it is byte-aligned to the data type.
For example, a `Float32Array` must be stored in memory such that its data begins on a byte multiple of four since each `float` contains four bytes.

The string generated from the JSON header should be padded with space characters in order to ensure that the binary body is byte-aligned.
The binary body should also be padded if necessary when there is data following the Batch Table.

## Acknowledgments

* Jannes Bolling, [@jbo023](https://github.com/jbo023)
