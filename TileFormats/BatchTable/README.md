# Batch Table

## Contributors

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)
* Rob Taglang, [@lasalvavida](https://github.com/lasalvavida)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Layout](#layout)
   * [JSON header](#json-header)
   * [Binary body](#binary-body)
* [Batch Table Hierarchy](#batch-table-hierarchy)
   * [Motivation](#motivation)
   * [Hierarchy](#hierarchy)
   * [Examples](#examples)
      * [Feature classes](#feature-classes)
      * [Feature hierarchy](#feature-hierarchy)
   * [Styling](#styling)
   * [Notes](#notes)
* [Implementation notes](#implementation-notes)
* [Acknowledgments](#acknowledgments)

## Overview

A _Batch Table_ contains per-feature application-specific metadata in a tile. These properties may be queried at runtime for declarative styling and application-specific use cases such as populating a UI or issuing a REST API request.  Some example Batch Table properties are building heights, geographic coordinates, and database primary keys.

A Batch Table is used by the following tile formats:
* [Batched 3D Model](../Batched3DModel/README.md) (b3dm)
* [Instanced 3D Model](../Instanced3DModel/README.md) (i3dm)
* [Point Cloud](../PointCloud/README.md) (pnts)
* [Vector](../VectorData/README.md) (vctr)

## Layout

A Batch Table is composed of two parts: a JSON header and an optional binary body. The JSON describes the properties, whose values either can be defined directly in the JSON as an array, or can refer to sections in the binary body.  It is more efficient to store long numeric arrays in the binary body. The following figure shows the Batch Table layout:

![batch table layout](figures/batch-table-layout.png)

When a tile format includes a Batch Table, the Batch Table immediately follows the tile's Feature Table if it exists.  Otherwise, the Batch Table immediately follows the tile's header.
The header will also contain `batchTableJSONByteLength` and `batchTableBinaryByteLength` `uint32` fields, which can be used to extract each respective part of the Batch Table.

Code for reading the Batch Table can be found in [Cesium3DTileBatchTable.js](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Scene/Cesium3DTileBatchTable.js) in the Cesium implementation of 3D Tiles.

### JSON header

Batch Table values can be represented in the JSON header in two different ways:

1. An array of values, e.g., `"name" : ['name1', 'name2', 'name3']` or `"height" : [10.0, 20.0, 15.0]`.
    * Array elements can be any valid JSON data type, including objects and arrays.  Elements may be `null`.
    * The length of each array is equal to `batchLength`, which is specified in each tile format.  This is the number of features in the tile.  For example, `batchLength` may be the number of models in a b3dm tile, the number of instances in a i3dm tile, or the number of points (or number of objects) in a pnts tile.
2. A reference to data in the binary body, denoted by an object with `byteOffset`, `componentType`, and `type` properties,  e.g., `"height" : { "byteOffset" : 24, "componentType" : "FLOAT", "type" : "SCALAR"}`.
    * `byteOffset` is a zero-based offset relative to the start of the binary body.
    * `componentType` is the datatype of components in the attribute. Allowed values are `"BYTE"`, `"UNSIGNED_BYTE"`, `"SHORT"`, `"UNSIGNED_SHORT"`, `"INT"`, `"UNSIGNED_INT"`, `"FLOAT"`, and `"DOUBLE"`.
    * `type` specifies if the property is a scalar or vector. Allowed values are `"SCALAR"`, `"VEC2"`, `"VEC3"`, and `"VEC4"`.

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

JSON schema Batch Table definitions can be found in [batchTable.schema.json](../../schema/batchTable.schema.json).

### Binary body

When the JSON header includes a reference to the binary section, the provided `byteOffset` is used to index into the data, as shown in the following figure:

![batch table binary index](figures/batch-table-binary-index.png)

Values can be retrieved using the number of features, `batchLength`; the desired batch id, `batchId`; and the `componentType` and `type` defined in the JSON header.

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

For example, given the following Batch Table JSON with `batchLength` of 10:

```json
{
    "height" : {
        "byteOffset" : 0,
        "componentType" : "FLOAT",
        "type" : "SCALAR"
    },
    "geographic" : {
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

To get the `"geographic"` values:

```javascript
var geographic = batchTableJSON.geographic;
var byteOffset = geographic.byteOffset;
var componentType = geographic.componentType;
var type = geographic.type;
var componentSizeInBytes = sizeInBytes(componentType)
var numberOfComponents = numberOfComponents(type);

var geographicArrayByteLength = batchLength * componentSizeInBytes * numberOfComponents // 10 * 8 * 3
var geographicArray = new Float64Array(batchTableBinary.buffer, byteOffset, geographicArrayByteLength);
var geographicOfFeature = positionArray.subarray(batchId * numberOfComponents, batchId * numberOfComponents + numberOfComponents); // Using subarray creates a view into the array, and not a new array.
```

## Batch Table Hierarchy

The standard batch table is suitable for datasets composed of features with the same sets of properties. However, some datasets have more complex metadata structures such as feature types or feature hierarchies that are not easy to represent as parallel arrays of properties. The Batch Table Hierarchy provides more flexibility for these cases.

### Motivation

Consider a tile whose features fit into multiple categories that do not share the same properties. A parking lot tile may have three types of features: cars, lamp posts, and trees. With the standard batch table, this might look like the following:

```json
{
    "lampStrength" : [10, 5, 7, 0, 0, 0, 0, 0],
    "lampColor" : ["yellow", "white", "white", "", "", "", "", ""],
    "carType" : ["", "", "", "truck", "bus", "sedan", "", ""],
    "carColor" : ["", "", "", "green", "blue", "red", "", ""],
    "treeHeight" : [0, 0, 0, 0, 0, 0, 10, 15],
    "treeAge" : [0, 0, 0, 0, 0, 0, 5, 8]
}
```

In this example, several `""` and `0` array values are stored so each array has the same number of elements.  A potential workaround is to store properties as JSON objects; however, this becomes bulky as the number of properties grows:

```json
{
  "info" : [
    {
      "lampStrength" : 10,
      "lampColor" : "yellow"
    },
    {
      "lampStrength" : 5,
      "lampColor" : "white"
    },
    {
      "lampStrength" : 7,
      "lampColor" : "white"
    },
    {
      "carType" : "truck",
      "carColor" : "green"
    },
    {
      "carType" : "bus",
      "carColor" : "blue"
    },
    {
      "carType" : "sedan",
      "carColor" : "red"
    },
    {
      "treeHeight" : 10,
      "treeAge" : 5
    },
    {
      "treeHeight" : 15,
      "treeAge" : 8
    }
  ]
}
```

Another limitation of the standard batch table is the difficulty in expressing metadata hierarchies. 
For example, consider a tile that represents a city block. The block itself contains metadata, the individual buildings contain metadata, and the building walls contain metadata. A tree diagram of the hierarchy might look like this:

- block
  - building
    - wall
    - wall
  - building
    - wall
    - wall
  - building
    - wall
    - wall


In order to select a wall and retrieve properties from its building, the wall metadata must also include building metadata. Essentially the three-level hierarchy must be flattened into each feature, resulting in a lot of duplicate entries.

A standard batch table with two walls per building and three buildings per block might look like this:

```json
{
    "wall_color" : ["blue", "pink", "green", "lime", "black", "brown"],
    "wall_windows" : [2, 4, 4, 2, 0, 3],
    "building_name" : ["building_0", "building_0", "building_1", "building_1", "building_2", "building_2"],
    "building_id" : [0, 0, 1, 1, 2, 2],
    "building_address" : ["10 Main St", "10 Main St", "12 Main St", "12 Main St", "14 Main St", "14 Main St"],
    "block_lat_long" : [[0.12, 0.543], [0.12, 0.543], [0.12, 0.543], [0.12, 0.543], [0.12, 0.543], [0.12, 0.543]],
    "block_district" : ["central", "central", "central", "central", "central", "central"],
}
```

Both these cases illustrate the benefit of supporting feature types and a feature hierarchy within the Batch Table.

### Hierarchy

The standard batch table may be extended to include a `HIERARCHY` object that defines a set of classes and a tree structure for class instances.

Sample Batch Table:

```json
{
  "HIERARCHY" : {
    "classes" : [
      {
        "name" : "Wall",
        "length" : 6,
        "instances" : {
          "color" : ["white", "red", "yellow", "gray", "brown", "black"],
        }
      },
      {
        "name" : "Building",
        "length" : 3,
        "instances" : {
          "name" : ["unit29", "unit20", "unit93"],
          "address" : ["100 Main St", "102 Main St", "104 Main St"]
        }
      },
      {
        "name" : "Owner",
        "length" : 3,
        "instances" : {
          "type" : ["city", "resident", "commercial"],
          "id" : [1120, 1250, 6445]
        }
      }
    ],
    "instancesLength" : 12,
    "classIds" : [0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2],
    "parentCounts" : [1, 3, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    "parentIds" : [6, 6, 10, 11, 7, 11, 7, 8, 8, 10, 10, 9]
  }
}
```

`classes` is an array of objects, where each object contains the following properties:
* `name` - A string representing the name of the class
* `length` - The number of instances of the class
* `instances` - An object containing instance properties. Properties may be stored as an array of values or a reference to data in the binary body.

`instancesLength` is the total number of instances. It is equal to the sum of the `length` properties of the classes.

Note that this is different than a tile's `batchLength`, which is the total number of features. While all features are instances, not all instances are features; the hierarchy may contain instances that don't have a physical basis in the tile's geometry but still contribute to the metadata hierarchy.

`classIds` is an array of integers of length `instancesLength`. Each value specifies the instances's class as an index in the `classes` array.

**Implementation Note**: The Batch Table Hierarchy does not directly provide an instances's index into its class's `instances` array. Instead the index can be inferred by the number of instances with the same `classId` that have appeared before it. An implementation may want to compute these indices at load time so that property access is as fast as possible.

`parentCounts` is an array of integers of length `instancesLength`. Each value specifies the number of parents that instance has. If omitted, `parentCounts` is implicitly an array of length `instancesLength`, where all values are 1.

`parentIds` is an array of integers whose length equals the sum of the values in `parentCounts`. Parent ids are placed sequentially by instance - instance 0's parent ids are followed by instance 1's parent ids. Each value specifies the instance's parent as an index into the `classIds` array.

Cyclical hierarchies are not allowed. When an instance's `parentId` points to itself, then it has no parent. When `parentIds` is omitted, the instances do not have parents.

A feature's `batchId` is used to access its `classId` and `parentCount`. Therefore, the values in the `classIds` and `parentCounts` arrays are initially ordered by `batchId` and followed by non-feature instances.

The `parentCounts` and `parentIds` arrays form an instance hierarchy. A feature's properties include those defined by its own class and any properties from ancestor instances.

In some cases multiple ancestors may share the same property name. This can occur if two ancestors are the same class or are different classes with the same property names. For example, if every class defined the property "id", then it would be an overloaded property. In such cases it is up to the implementation to decide which value to return.

Finally, `classIds`, `parentCounts`, and `parentIds` may instead be references to data in the binary body. If omitted, `componentType` defaults to `UNSIGNED_SHORT`. `type` is implicitly `SCALAR`.

```json
"classIds" : {
    "byteOffset" : 0,
    "componentType" : "UNSIGNED_SHORT"
};
```

### Examples

#### Feature classes

Going back to the example of a parking lot with car, lamp post, and tree features, a Batch Table might look like this:

```json
{
  "HIERARCHY" : {
    "classes" : [
      {
        "name" : "Lamp",
        "length" : 3,
        "instances" : {
          "lampStrength" : [10, 5, 7],
          "lampColor" : ["yellow", "white", "white"]
        }
      },
      {
        "name" : "Car",
        "length" : 3,
        "instances" : {
          "carType" : ["truck", "bus", "sedan"],
          "carColor" : ["green", "blue", "red"]
        }
      },
      {
        "name" : "Tree",
        "length" : 2,
        "instances" : {
          "treeHeight" : [10, 15],
          "treeAge" : [5, 8]
        }
      }
    ],
    "instancesLength" : 8,
    "classIds" : [0, 0, 0, 1, 1, 1, 2, 2]
  }
}
```

Since this example does not contain any sort of hierarchy, the `parentCounts` and `parentIds` are not included, and `instancesLength` just equals the tile's `batchLength`.

A `classId` of 0 indicates a "Lamp" instance, 1 indicates a "Car" instance, and 2 indicates a "Tree" instance.

A feature's `batchId` is used to access its class in the `classIds` array. Features with a `batchId` of 0, 1, 2 are "Lamp" instances, features with a `batchId` of 3, 4, 5 are "Car" instances, and features with `batchId` of 6 and 7 are "Tree" instances.

The feature with `batchId = 5` is the third "Car" instance, and its properties are

```
carType : "sedan"
carColor : "red"
```

Batch Table Hierarchy, parking lot:

![batch table hierarchy parking lot](figures/batch-table-hierarchy-parking-lot.png)

#### Feature hierarchy

The city block example would now look like this:

```json
{
  "HIERARCHY" : {
    "classes" : [
      {
        "name" : "Wall",
        "length" : 6,
        "instances" : {
          "wall_color" : ["blue", "pink", "green", "lime", "black", "brown"],
          "wall_windows" : [2, 4, 4, 2, 0, 3]
        }
      },
      {
        "name" : "Building",
        "length" : 3,
        "instances" : {
          "building_name" : ["building_0", "building_1", "building_2"],
          "building_id" : [0, 1, 2],
          "building_address" : ["10 Main St", "12 Main St", "14 Main St"]
        }
      },
      {
        "name" : "Block",
        "length" : 1,
        "instances" : {
          "block_lat_long" : [[0.12, 0.543]],
          "block_district" : ["central"]
        }
      }
    ],
    "instancesLength" : 10,
    "classIds" : [0, 0, 0, 0, 0, 0, 1, 1, 1, 2],
    "parentIds" : [6, 6, 7, 7, 8, 8, 9, 9, 9, 9]
  }
}
```

The tile's `batchLength` is 6 and `instancesLength` is 10. The building and block instances are not features of the tile but contain properties that are inherited by the six wall features.

`parentCounts` is not included since every instance has at most one parent.

A feature with `batchId = 3` has the following properties:

```
wall_color : "lime"
wall_windows : 2
building_name : "building_1"
building_id : 1,
building_address : "12 Main St"
block_lat_long : [0.12, 0.543]
block_district : "central"
```

Breaking it down into smaller steps:

The feature with `batchId = 3` is the fourth "Wall" instance, and its properties are the following:
```
wall_color : "lime"
wall_windows : 2
```

The feature's `parentId` is 7, which is the second "Building" instance. Therefore it gets the following properties from its parent:
```
building_name : "building_1"
building_id : 1,
building_address : "12 Main St"
```

The building's `parentId` is 9, which is the sole "Block" instance with the following properties:
```
block_lat_long : [[0.12, 0.543]]
block_district : ["central"]
```

Since the block's `parentId` is also 9, it does not have a parent and the traversal is complete.

Batch Table Hierarchy, block:

![batch table hierarchy block](figures/batch-table-hierarchy-block.png)

### Styling

The styling language supports additional functions for querying feature classes:

* `isExactClass`
* `isClass`
* `getExactClassName`

More detailed descriptions are provided in the [Styling Spec](../../Styling/README.md#batch-table-hierarchy).

### Notes

* Since the Batch Table Hierarchy is an extension to the standard batch table, it is still possible to store per-feature properties alongside the `HIERARCHY` object:

```
{
  "Height" : [...],
  "Longitude" : [...],
  "Latitude" : [...],
  "HIERARCHY" : {...}
}
```

* The Batch Table Hierarchy is self-contained within the tile. It is not possible to form metadata hierarchy across different tiles in the tileset.

## Implementation notes

In JavaScript, a `TypedArray` cannot be created on data unless it is byte-aligned to the data type.
For example, a `Float32Array` must be stored in memory such that its data begins on a byte multiple of four since each `float` contains four bytes.

The string generated from the JSON header should be padded with space characters in order to ensure that the binary body is byte-aligned.
The binary body should also be padded if necessary when there is data following the Batch Table.

## Acknowledgments

* Jannes Bolling, [@jbo023](https://github.com/jbo023)
