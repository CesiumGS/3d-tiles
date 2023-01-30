# 3DTILES_draco_point_compression Extension

## Contributors

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)

## Contents

* [Overview](#overview)
* [Point Cloud tile format updates](#point-cloud-tile-format-updates)
   * [Feature Table](#feature-table)
   * [Batch Table](#batch-table)
   * [Notes](#notes)
* [Resources](#resources)
* [Property reference](#property-reference)

## Overview

This extension adds [Draco geometry compression](https://github.com/google/draco) to the [Point Cloud](../../specification/TileFormats/PointCloud) tile format to support streaming compressed point data.

Draco compresses common properties such as position, color, and normal, as well as generic metadata such as intensity or classification.

This extension is based on [Draco bitstream version 2.2](https://google.github.io/draco/spec/), which is normative and included in scope.

## Point Cloud tile format updates

### Feature Table

The Feature Table of a [Point Cloud](../../specification/TileFormats/PointCloud) tile may be extended to include a `3DTILES_draco_point_compression` object. This object defines
the compressed properties and the location of the compressed data in the Feature Table binary.

Below is an example of a Feature Table with the Draco extension set:

```json
{
    "POINTS_LENGTH": 20,
    "POSITION": {
        "byteOffset": 0
    },
    "RGB": {
        "byteOffset": 0
    },
    "BATCH_ID": {
        "byteOffset": 0,
        "componentType": "UNSIGNED_BYTE"
    },
    "extensions": {
        "3DTILES_draco_point_compression": {
            "properties": {
                "POSITION": 0,
                "RGB": 1,
                "BATCH_ID": 2
            },
            "byteOffset": 0,
            "byteLength": 100
        }
    }
}
```

#### properties

`properties` defines the Feature Table properties stored in the compressed data. In the example above, positions, RGB colors, and batch IDs are compressed.

Each property defined in the extension must correspond to a semantic already defined in the Feature Table JSON.
When a semantic is compressed its `byteOffset` property is ignored and may be set to zero. Its `componentType`, if present,
defines the component type of the uncompressed data.

Each property is associated with a unique ID. This ID is used to identify the property within the compressed data.
No two properties in the Feature Table and Batch Table may use the same ID.

Allowed properties are `"POSITION"`, `"RGBA"`, `"RGB"`, `"NORMAL"`, and `"BATCH_ID"`.

#### byteOffset

The `byteOffset` property specifies a zero-based offset relative to the start of the Feature Table binary at which the compressed data starts.

#### byteLength

The `byteLength` property specifies the length, in bytes, of the compressed data.

#### Schema updates

See [Property reference](#reference-3dtiles_draco_point_compression-feature-table-extension) for the `3DTILES_draco_point_compression` Feature Table schema reference. The full JSON schema can be found in [3DTILES_draco_point_compression.featureTable.schema.json](schema/3DTILES_draco_point_compression.featureTable.schema.json).

### Batch Table

Per-point metadata can also be compressed. The Batch Table may be extended to include a `3DTILES_draco_point_compression` object that defines additional compressed properties.

Below is an example of a Batch Table with the Draco extension set:

```json
{
    "Intensity": {
        "byteOffset": 0,
        "type": "SCALAR",
        "componentType": "UNSIGNED_BYTE"
    },
    "Classification": {
        "byteOffset": 0,
        "type": "SCALAR",
        "componentType": "UNSIGNED_BYTE"
    },
    "extensions": {
        "3DTILES_draco_point_compression": {
            "properties": {
                "Intensity": 3,
                "Classification": 4
            }
        }
    }
}
```

#### properties

`properties` defines additional Batch Table properties stored in the compressed data. In the example above, intensity and classification are compressed.

Each property defined in the extension must correspond to a property name already defined in the Batch Table JSON.
When a property is compressed its `byteOffset` property is ignored and may be set to zero. Its `componentType` and `type` properties
define the component type and type, respectively, of the uncompressed data.

Each property is associated with a unique ID. This ID is used to identify the property within the compressed data.
No two properties in the Feature Table and Batch Table may use the same ID.

`byteOffset` and `byteLength` are not defined in the Batch Table extension; all compressed data is stored in the Feature Table binary.

#### Schema updates

See [Property reference](#reference-3dtiles_draco_point_compression-batch-table-extension) for the `3DTILES_draco_point_compression` Batch Table schema reference. The full JSON schema can be found in [3DTILES_draco_point_compression.batchTable.schema.json](schema/3DTILES_draco_point_compression.batchTable.schema.json).

### Notes

If some properties are compressed and others are not, the Draco encoder must apply the `POINT_CLOUD_SEQUENTIAL_ENCODING` encoding method.
This ensures that Draco preserves the original ordering of point data.

> **Implementation Note:** Draco may reorder point data to achieve better compression and smaller file sizes.
For best results, all properties in the Feature Table and Batch Table should be Draco compressed, in which
case `POINT_CLOUD_SEQUENTIAL_ENCODING` should not be applied.

## Resources
_This section is non-normative._

* [Draco Open Source Library](https://github.com/google/draco)
* [Cesium Draco Decoder Implementation](https://github.com/CesiumGS/cesium/blob/main/packages/engine/Source/WorkersES6/decodeDraco.js)

## Property reference

* [`3DTILES_draco_point_compression Feature Table extension`](#reference-3dtiles_draco_point_compression-feature-table-extension)
* [`3DTILES_draco_point_compression Batch Table extension`](#reference-3dtiles_draco_point_compression-batch-table-extension)

---------------------------------------
<a name="reference-3dtiles_draco_point_compression-feature-table-extension"></a>
## 3DTILES_draco_point_compression Feature Table extension

Specifies the compressed Feature Table properties and the location of the compressed data in the Feature Table binary.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**properties**|`object`|Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.| :white_check_mark: Yes|
|**byteOffset**|`number`|A zero-based offset relative to the start of the Feature Table binary at which the compressed data starts.| :white_check_mark: Yes|
|**byteLength**|`number`|The length, in bytes, of the compressed data.| :white_check_mark: Yes|

### properties :white_check_mark:

Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within
the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.

* **Type**: `object`
* **Required**: Yes
* **Type of each property**: `number`

### byteOffset :white_check_mark:

A zero-based offset relative to the start of the Feature Table binary at which the compressed data starts.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`

### byteLength :white_check_mark:

The length, in bytes, of the compressed data.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`

---------------------------------------
<a name="reference-3dtiles_draco_point_compression-batch-table-extension"></a>
## 3DTILES_draco_point_compression Batch Table extension

Specifies the compressed Batch Table properties.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**properties**|`object`|Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.| :white_check_mark: Yes|

### properties :white_check_mark:

Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.

* **Type**: `object`
* **Required**: Yes
* **Type of each property**: `number`
