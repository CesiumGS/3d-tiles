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
    * The length of each array is equal to `batchLength` which is specified in each tile format.  This is the number of features in the tile.  For example, `batchLength` may be the number of models in a b3dm tile, the number of instances in a i3dm tile, or the number of points (or number of objects) in a pnts tile.
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

## Hierarchy

The standard batch table is suitable for homogeneous data sets composed of features with the same sets of properties. However some data sets have more complex metadata structures like feature types or feature hierarchies that are not easy to represent as simple property arrays. The batch table hierarchy provides more flexibility for these cases.

### Classes

A key concept of the batch table hierarchy is the separation of features into classes. A tile of a parking lot may have three distinct feature types - cars, lamp posts, and trees - each with their own set of properties.

With the standard batch table, this might look like:

```json
{
    "lampStrength" : [10, 5, 7, 0, 0, 0, 0, 0],
    "lampColor" : ["yellow", "white", "white", "", "", "", "", ""],
    "carType" : ["", "", "", "truck", "bus", "sedan", "", ""],
    "carColor" : ["", "", "", "red", "blue", "white", "", ""],
    "treeHeight" : [0, 0, 0, 0, 0, 0, 10, 15],
    "treeAge" : [0, 0, 0, 0, 0, 0, 5, 8]
}
```

A common workaround is to store properties as JSON objects. However, this becomes bulky as the number of properties grows:

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
      "carColor" : "red"
    },
    {
      "carType" : "bus",
      "carColor" : "blue"
    },
    {
      "carType" : "sedan",
      "carColor" : "white"
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

Instead a `HIERARCHY` object may be added to the batch table that allows for grouping features by class:

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
          "carColor" : ["red", "blue", "white"]
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

`classes` is an array of objects, where each object contains the following information:
* `name` - the name of the class
* `length` - the number of instances of the class
* `instances` - metadata for the instances. This section is similar to a standard batch table; properties may be stored as an array of values or a reference to data in the binary body.

`instancesLength` is the number of instances. In this example `instancesLength` equals `batchLength`, however this is not always the case (as will be seen below).

`classIds` is an array of integers of length `instancesLength`. Each `classId` specifies the instances's class as an index in the `classes` array.

In the example above 0 indicates a "Lamp" instance, 1 indicates a "Car" instance, and 2 indicates a "Tree" instance.

A feature's `batchId` is used to access its class in the `classIds` array. Therefore features with a `batchId` of 0, 1, 2 are "Lamp" instances, features with a `batchId` of 3, 4, 5 are "Car" instances, and features with `batchId` of 6, 7 are "Tree" instances.

Note that the batch table hierarchy does not directly provide an instances's index into its class's `instances` array. Instead the index can be inferred by the number of instances with the same `classId` that have appeared before it. An implementation may want to compute these indices at load time so that property access is as fast as possible.

To put this more concretely using the current example:

The feature with `batchId = 0` is the first "Lamp" instance, and its properties are:

```
lampStrength : 10
lampColor : "yellow"
```

The feature with `batchId = 2` is the third "Lamp" instance, and its properties are:

```
lampStrength : 7
lampColor : "white"
```

The properties for `batchId = 7` is the second "Tree" instance, and its properties are

```
treeHeight : 15
treeAge : 8
```

Finally, `classIds` may be a reference to data in the binary body. If omitted, `componentType` defaults to `UNSIGNED_SHORT`. `type` is implicitly `SCALAR`.

```json
"classIds" : {
    "byteOffset" : 0,
    "componentType" : "UNSIGNED_SHORT"
};
```

### Instance Hierarchy

Another limitation of the standard batch table is the difficulty in expressing metadata hierarchies.

For example consider a tile that represents a city block. The block itself contains metadata, the individual buildings contain metadata, and the building components (doors, walls, roofs) contain metadata.

A tree diagram of the hierarchy might look like:

- block
  - building
    - door
    - wall
    - roof
  - building
    - door
    - wall
    - roof


The tile's features are limited to the geometric components of the tile - the doors, walls, and roofs. In order to select a door and retrieve properties from its building, the door metadata must also include building metadata. Essentially the three-level hierarchy must be flattened into each feature, resulting in a lot of duplicate entries.

An standard batch table with two doors per building and three buildings per block might look like:

```json
{
    "door_color" : ["white", "red", "yellow", "gray", "brown", "black"],
    "door_name" : ["door_0", "door_1", "door_2", "door_3", "door_4", "door_5"],
    "building_id" : [0, 0, 1, 1, 2, 2],
    "building_name" : ["building_0", "building_0", "building_1", "building_1", "building_2", "building_2"],
    "building_address" : ["100 Main St", "100 Main St", "102 Main St", "102 Main St", "104 Main St", "104 Main St"],
    "block_lat_long" : [[0.12, 0.543], [0.12, 0.543], [0.12, 0.543], [0.12, 0.543], [0.12, 0.543], [0.12, 0.543]],
    "block_district" : ["central", "central", "central", "central", "central", "central"],
    "block_name" : ["block", "block", "block", "block", "block", "block"]
}
```

The class structure introduced above can be extended with `parentIds` to build a class hierarachy.

```json
{
  "HIERARCHY" : {
    "classes" : [
      {
        "name" : "Door",
        "length" : 6,
        "instances" : {
          "door_color" : ["white", "red", "yellow", "gray", "brown", "black"],
          "door_name" : ["door_0", "door_1", "door_2", "door_3", "door_4", "door_5"]
        }
      },
      {
        "name" : "Building",
        "length" : 2,
        "instances" : {
          "building_name" : ["building_0", "building_1", "building_2"],
          "building_id" : [0, 1, 2],
          "building_address" : ["100 Main St", "102 Main St", "104 Main St"]
        }
      },
      {
        "name" : "Block",
        "length" : 1,
        "instances" : {
          "block_lat_long" : [[0.12, 0.543]],
          "block_district" : ["central"],
          "block_name" : ["block"]
        }
      }
    ],
    "instancesLength" : 10,
    "classIds" : [0, 0, 0, 0, 0, 0, 1, 1, 1, 2],
    "parentIds" : [6, 6, 7, 7, 8, 8, 9, 9, 9, 9]
  }
}
```

`parentIds` is an array of integers of length `instancesLength`. Each `parentId` specifies the instances's parent as an index into the `classIds` array. When a `parentId` points to itself, then it has no parent. Cylical hierarchies are not allowed. When `parentIds` is omitted, the instances do not have parents.

Like `classIds`, `parentIds` may also be a reference to data in the binary body. If omitted, `componentType` defaults to `UNSIGNED_SHORT`. `type` is implicitly `SCALAR`.

```json
"parentIds" : {
    "byteOffset" : 0,
    "componentType" : "UNSIGNED_SHORT"
};
```

Note that in this example `instancesLength != batchLength`. `batchLength` is equal to the number of features in the tile, which is 6 (there are six doors in the tile); `instancesLength` is equal to the number of instances in the batch table hierarchy, which is 10 (six doors, three buildings, one block).

A feature's `batchId` is used to access its parent in the `parentIds` array. This means features must be listed before other instances. This ensures that when a feature is selected its `batchId` may be used as an index into the `classIds` and `parentIds` arrays.

Now with the class hierarchy built a feature may get properties belonging to itself and its parent instances.

A feature with `batchId = 5` has the following properties:

```
door_color : "black"
door_name : "door_5"
building_name : "building_2"
building_id : 2,
building_address : "104 Main St"
block_lat_long : [0.12, 0.543]
block_district : "central"
block_name : "block"
```

Breaking it down into smaller steps:

The feature with `batchId = 5` is the sixth "Door" instance, and its properties are:
```
door_color : "black"
door_name : "door_5"
```

The feature's `parentId` is 8, which is the third "Building" instance. Therefore it gets the following properties from its parent:
```
building_name : "building_2"
building_id : 2,
building_address : "104 Main St",
```

The building's `parentId` is 9, which is the sole "Block" instance with the following properties:
```
block_lat_long : [[0.12, 0.543]]
block_district : ["central"]
block_name : "block"
```

Since the block's `parentId` is also 9, it does not have a parent and the traversal is complete.

### Multiple parents

Finally an instance may have multiple parents. This is useful for supporting more complex semantic hierarchies. One simple example is marking instances with classifiers/labels that are independent of the feature hierarchy.

Extending the example above, let's say certain instances now have owners.

```json
{
  "HIERARCHY" : {
    "classes" : [
      {
        "name" : "Door",
        "length" : 6,
        "instances" : {
          "door_color" : ["white", "red", "yellow", "gray", "brown", "black"],
          "door_name" : ["door_0", "door_1", "door_2", "door_3", "door_4", "door_5"]
        }
      },
      {
        "name" : "Building",
        "length" : 2,
        "instances" : {
          "building_name" : ["building_0", "building_1", "building_2"],
          "building_id" : [0, 1, 2],
          "building_address" : ["100 Main St", "102 Main St", "104 Main St"]
        }
      },
      {
        "name" : "Block",
        "length" : 1,
        "instances" : {
          "block_lat_long" : [[0.12, 0.543]],
          "block_district" : ["central"],
          "block_name" : ["block"]
        }
      },
      {
        "name" : "Owner",
        "length" : 3,
        "instances" : {
          "owner_name" : ["owner_city", "owner_resident", "owner_commercial"],
          "owner_id" : [1120, 1250, 6445]
        }
      }
    ],
    "instancesLength" : 13,
    "classIds" : [0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 3, 3, 3],
    "parentCounts" : [1, 3, 2, 1, 1, 1, 2, 2, 2, 0, 0, 0, 0],
    "parentIds" : [6, 6, 11, 12, 7, 11, 7, 8, 8, 9, 12, 9, 11, 9, 10]
  }
}
```

`parentCounts` is an array of integers of length `instancesLength`. Each value specifies the number of parents that instance has.

When `parentCounts` is included in the hierarchy, `parentIds` lists parent ids sequentially. The length of the array equals the sum of the elements in `parentCounts`.

For example:

```
batchId: 0
Instance id : 0
Instance name: "door_0"
Parent count: 1
Parent ids: [6]
Parent names: ["building_0"]
```

```
batchId: 1
Instance id : 1
Instance name: "door_1"
Parent count: 3
Parent ids: [6, 11, 12]
Parent names: ["building_0", "owner_resident", "owner_commercial"]
```

```
Instance id: 6
Instance name: "building_0"
Parent count: 2
Parent ids: [9, 12]
Parent names: ["block", "owner_commercial"]
```

```
Instance id: 9
Instance name: "block"
Parent count: 0
Parent ids: []
Parent names : []
```

A feature with `batchId = 1` has the following properties:

```
door_color : "red"
door_name : "door_1"
building_name : "building_0"
building_id : 0
building_address : "100 Main St"
block_lat_long : [0.12, 0.543]
block_district : "central"
block_name : "block"
owner_name : ["owner_resident", "owner_commercial"]
owner_id : [1250, 6445]
```

The feature has two ancestors of class "Owner", so the properties `owner_name` and `owner_id` map to two values each. It is up to the implementation to decide how to handle overloaded properties.

Additionally different classes may have the same property names. If an instance derives from classes with the same property names, the implementation may decide which properties to retrieve.

### Styling

The styling language supports additional functions for querying feature classes:

* `isExactClass`
* `isClass`
* `getExactClassName`

More detailed descriptions are provided in the [Styling Spec](../../Styling/README.md#batch-table-hierarchy).

### Notes

Since the batch table hierarchy is an extension to the standard batch table, it is still possible to store per-feature properties alongside the `HIERARCHY` object:

```
{
  "Height" : [...],
  "Longitude" : [...],
  "Latitude" : [...],
  "HIERARCHY" : {
    "classes" : [...],
    "instancesLength" : 10,
    "classIds" : [...]
  }
}
```

The batch table hierarchy is self-contained within the tile. It is not possible to form metadata hierarchy across different tiles in the tileset.

## Implementation Notes

In JavaScript, a `TypedArray` cannot be created on data unless it is byte-aligned to the data type.
For example, a `Float32Array` must be stored in memory such that its data begins on a byte multiple of four since each `float` contains four bytes.

The string generated from the JSON header should be padded with space characters in order to ensure that the binary body is byte-aligned.
The binary body should also be padded if necessary when there is data following the Batch Table.

## Acknowledgments

* Jannes Bolling, [@jbo023](https://github.com/jbo023)
