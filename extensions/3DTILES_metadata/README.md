<!-- omit in toc -->
# 3DTILES_metadata Extension

<!-- omit in toc -->
## Contributors

* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Sam Suhag, Cesium
* Don McCurdy, Independent
* Patrick Cozzi, Cesium
* Bao Tran, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Dependencies

Written against the 3D Tiles 1.0 specification.

Optionally, this extension may be used with [`3DTILES_implicit_tiling`](../3DTILES_implicit_tiling), providing metadata for implicit tiling subtrees.

Optionally, this extension may be used with [`3DTILES_multiple_contents`](../3DTILES_multiple_contents), organizing tile contents into groups and providing metadata for each.

> **Disambiguation:** This extension does not interact with the [Batch Table](../../specification/TileFormats/BatchTable) feature used by the Batched 3D Model, Instanced 3D Model, and Point Cloud formats. Instead, glTF 2.0 assets may be referenced with [`3DTILES_content_gltf`](../3DTILES_content_gltf). Metadata within these assets is enabled with the glTF extension, [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) using the same schema format and conventions defined here.

> **Disambiguation:** This extension does not interact with the [`properties`](../../specification/schema/properties.schema.json) object in tileset JSON, which is an alternative way of including small amounts of metadata associated with the tileset as a whole.

<!-- omit in toc -->
## Optional vs. Required

This extension is optional, meaning it should be placed in the tileset JSON `extensionsUsed` list, but not in the `extensionsRequired` list.

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Metadata](#metadata)
  - [Overview](#overview-1)
  - [Schema](#schema)
  - [Class](#class)
  - [Class Property](#class-property)
  - [Enum](#enum)
  - [Enum Value](#enum-value)
  - [Statistics](#statistics)
- [Assigning Metadata](#assigning-metadata)
  - [Overview](#overview-2)
  - [Tileset Properties](#tileset-properties)
  - [Tile Properties](#tile-properties)
  - [Implicit Tile Properties](#implicit-tile-properties)
  - [Content Group Properties](#content-group-properties)
  - [Content Feature Properties](#content-feature-properties)
- [Schema](#schema-1)
- [Revision History](#revision-history)

## Overview

This extension defines a means of including structured metadata ("properties") in 3D Tiles, extending the format with semantically-rich data that may be used for inspection, analysis, styling, or other purposes. Properties are structured according to declared templates ("schema"), and associated with specific objects within a tileset ("entities") at various levels of granularity. Metadata is supported on the following 3D Tiles entity types:

* **Tileset** - Tileset as a whole may be associated with global metadata, such as the year of publication.
* **Tile** - Tiles may be individually associated with more specific metadata, such as the timestamp when a tile was last updated, or maximum height of the tile's content.
* **Tile Content Groups** - Tile contents may be organized into collections (see: [Groups](#content-group-properties)) with shared metadata.

> **Implementation note:** Certain subcomponents of tile content ("features") may also have associated metadata. See [Content Feature Properties](#content-feature-properties).

Concepts and terminology used throughout this document refer to the [3D Metadata Specification](../../specification/Metadata/README.md), which should be considered a normative reference for definitions and requirements. This document provides inline definitions of terms where appropriate.

The figure below shows the relationship between entities (tilesets, tiles, contents, and groups) in 3D Tiles:

<img src="figures/metadata-granularity.png"  alt="Metadata Granularity" width="600">

## Use Cases

_This section is non-normative_

Metadata in 3D Tiles enables additional use cases and functionality for the format:

- **Inspection:** Applications displaying a tileset within a user interface (UI) may allow users to click or hover over specific tiles or tile contents, showing informative metadata about a selected entity in the UI.
- **Collections:** Tile content groups may be used to define collections (similar to map layers), such that each collection may be shown, hidden, or visually styled with effects synchronized across many tiles.
- **Structured Data:** Metadata supports both embedded and externally-referenced schemas, such that tileset authors may define new data models for common domains (e.g. for AEC or scientific datasets) or fully customized, application-specific data (e.g. for a particular video game).
- **Optimization:** Per-tile metadata may include properties with performance-related semantics, enabling engines to optimize traversal and streaming algorithms significantly.

## Metadata

### Overview

[*Properties*](#class-property) describe attributes or characteristics of an *Entity* (tileset, tile, or content group). [*Classes*](#class), provided by [*Schemas*](#schema), are templates defining the data types and meanings of properties. Each entity is a single instance of that class with specific values. Additionally, [*Statistics*](#statistics) may provide aggregate information about the distribution of property values within a particular class, and [*Semantics*](#semantics) may define usage and meaning of particular properties.

### Schema

*Defined in [schema.schema.json](./schema/schema.schema.json).*

A schema defines a set of classes and enums used in a tileset. Classes serve as templates for entities - they provide a list of properties and the type information for those properties. Enums define the allowable values for enum properties. `3DTILES_metadata` implements the [3D Metadata Specification](../../specification/Metadata), which describes the metadata format and property definitions in full detail.

Schemas may be embedded in tilesets with the `schema` property, or referenced externally by the `schemaUri` property. Multiple tilesets and glTF contents may refer to the same schema to avoid duplication.

> **Example:** Schema with a `building` class having three properties, 'height', 'owners', and 'buildingType'. The 'buildingType' property refers to the `buildingType` enum as its data type, also defined in the schema. Later examples show how entities declare their class and supply values for their properties.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "classes": {
>           "building": {
>             "properties": {
>               "height": {"componentType": "FLOAT32"},
>               "owners": {"type": "ARRAY", "componentType": "STRING", "description": "Names of owners."},
>               "buildingType": {"componentType": "ENUM", "enumType": "buildingType"}
>             }
>           }
>         },
>         "enums": {
>           "buildingType": {
>             "values": [
>               {"value": 0, "name": "Residential"},
>               {"value": 1, "name": "Commercial"},
>               {"value": 2, "name": "Other"}
>             ]
>           }
>         }
>       }
>     }
>   }
> }
> ```

> **Example:** External schema referenced by a URI.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schemaUri": "https://example.com/metadata/buildings/1.0/schema.json"
>     }
>   }
> }
> ```

### Class

*Defined in [class.schema.json](./schema/class.schema.json).*

Template for entities. Classes provide a list of property definitions. Every entity must be associated with a class, and the entity's properties must conform to the class's property definitions. Entities whose properties conform to a class are considered instances of that class.

Classes are defined as entries in the `schema.classes` dictionary, indexed by an alphanumeric class ID.

### Class Property

*Defined in [class.property.schema.json](./schema/class.property.schema.json).*

Properties are defined abstractly in a class, and are instantiated in an entity with specific values conforming to that definition. Properties support a rich variety of data types, defined by `property.componentType`.

Allowed values for `componentType`:

- `"BOOLEAN"`
- `"STRING"`
- `"ENUM"`
- `"INT8"`, `"INT16"`, `"INT32"`, `"INT64"`
- `"UINT8"`, `"UINT16"`, `"UINT32"`, `"UINT64"`
- `"FLOAT32"`, `"FLOAT64"`

A property may compose multiple components into higher-level types (vector, matrix, and array), defined by `property.type`.

Allowed values for `type`:

- `"SINGLE"` (default)
- `"ARRAY"`
- `"VEC2"`, `"VEC3"`, `"VEC4"`
- `"MAT2"`, `"MAT3"`, `"MAT4"`

`"SINGLE"` and `"ARRAY"` types may contain any component type; `"VECN"` and `"MATN"` must contain only numeric component types.

Class properties are defined as entries in the `class.properties` dictionary, indexed by an alphanumeric property ID.

By default, properties do not have any inherent meaning. A property may be assigned a **semantic**, an identifier that describes a property's meaning, for higher-level type information, runtime behavior, or other interpretation. The list of built-in semantics can be found in the [3D Metadata Semantic Reference](../../specification/Metadata/Semantics). Tileset authors may define their own application- or domain-specific semantics separately, and should follow the naming conventions in the Semantic Reference.

> **Example:** Schema defining a "building" class. The class's properties use two built-in semantics, `NAME` and `ID`, and one custom semantic, `_HEIGHT`.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "classes": {
>           "building": {
>             "properties": {
>               "name": {"componentType": "STRING", "semantic": "NAME"},
>               "id": {"componentType": "STRING", "semantic": "ID"},
>               "height": {"componentType": "FLOAT32", "semantic": "_HEIGHT"}
>             }
>           }
>         }
>       }
>     }
>   }
> }
> ```

### Enum

*Defined in [enum.schema.json](./schema/enum.schema.json).*

Set of categorical types, defined as `(name, value)` pairs. Enum properties use an enum as their component type.

Enums are defined as entries in the `schema.enums` dictionary, indexed by an alphanumeric enum ID.

> **Example:** A "Quality" enum defining quality level of data within a tile. An "Unspecified" enum value is optional, but when provided as the `noData` value for a property (see: [3D Metadata → No Data Values](../../specification/Metadata#required-properties-and-no-data-values)) may be helpful to identify missing data.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "enums": {
>           "qualityEnum": {
>             "name": "Quality",
>             "description": "An example enum defining expected quality of data within a tile.",
>             "values": [
>               {"name": "Unspecified", "value": 0},
>               {"name": "Low", "value": 1},
>               {"name": "Moderate", "value": 2},
>               {"name": "High", "value": 3}
>             ]
>           }
>         }
>       }
>     }
>   }
> }
> ```

### Enum Value

*Defined in [enum.value.schema.json](./schema/enum.value.schema.json).*

Pairs of `(name, value)` entries representing possible values of an enum property.

Enum values are defined as entries in the `enum.values` array. Duplicate names or duplicate integer values are not allowed.

### Statistics

*Defined in [statistics.class.property.schema.json](./schema/statistics.class.property.schema.json).*

Statistics provide aggregate information about the distribution of property values, summarized over all instances of a class within a tileset. For example, statistics may include the minimum/maximum values of a numeric property, or the number of occurrences for specific enum values.

These summary statistics allow applications to analyze or display metadata, e.g. with the [declarative styling language](../../specification/Styling), without first having to process the complete dataset to identify bounds for color ramps and histograms. Statistics are provided on a per-class basis, so that applications can provide styling or context based on the tileset as a whole, while only needing to download and process a subset of its tiles.

* `count` is the number of entities of a class occurring within the tileset
* `properties` contains summary statistics about properties of a class occurring within the tileset

Properties may include the following built-in statistics:

| Name                | Description                                   | Type                                                                                       |
|---------------------|-----------------------------------------------|--------------------------------------------------------------------------------------------|
| `minimum`               | The minimum property value                    | Single-value numeric types, fixed-length arrays of numeric types, vector, and matrix types |
| `maximum`               | The maximum property value                    | ...                                                                                        |
| `mean`              | The arithmetic mean of the property values    | ...                                                                                        |
| `median`            | The median of the property values             | ...                                                                                        |
| `standardDeviation` | The standard deviation of the property values | ...                                                                                        |
| `variance`          | The variance of the property values           | ...                                                                                        |
| `sum`               | The sum of the property values                | ...                                                                                        |
| `frequencies`       | Frequencies of value occurrences              | Object in which keys are property values (for enums, the enum name), and values are the number of occurrences of that property value |

Tileset authors may define their own additional statistics, like `_mode` in the example below. Application-specific statistics should use an underscore prefix (`_*`) and lowerCamelCase for consistency and to avoid conflicting with future built-in statistics.

> **Example:** Definition of a "building" class, with three properties. Summary statistics provide a minimum, maximum, and (application-specific) "_mode" for the numerical "height" property. The enum "buildingType" property is summarized by the number of distinct enum value occurrences.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "classes": {
>           "building": {
>             "properties": {
>               "height": {"componentType": "FLOAT32"},
>               "owners": {"type": "ARRAY", "componentType": "STRING"},
>               "buildingType": {"componentType": "ENUM", "enumType": "buildingType"}
>             }
>           }
>         },
>         "enums": {
>           "buildingType": {
>             "valueType": "UINT16",
>             "values": [
>               {"name": "Residential", "value": 0},
>               {"name": "Commercial", "value": 1},
>               {"name": "Hospital", "value": 2},
>               {"name": "Other", "value": 3}
>             ]
>           }
>         }
>       },
>       "statistics": {
>         "classes": {
>           "building": {
>             "count": 100000,
>             "properties": {
>               "height": {
>                 "minimum": 3.9,
>                 "maximum": 341.7,
>                 "_mode": 5.0
>               },
>               "buildingType": {
>                 "frequencies": {
>                   "Residential": 50000,
>                   "Commercial": 40950,
>                   "Hospital": 50
>                 }
>               }
>             }
>           }
>         }
>       }
>     }
>   }
> }
> ```

## Assigning Metadata

### Overview

While [classes](#class) within a schema define the data types and meanings of properties, properties do not take on particular values until a metadata is assigned (i.e. the class is "instatiated") as a particular metadata entity within the 3D Tiles hierarchy. Each metadata entity contains the name of the class that it is an instance of, as well as a dictionary of property values that correspond to the properties of that class. This common structure is defined in [metadataEntity.schema.json](./schema/metadataEntity.schema.json). 

Each property value assigned must be defined by a class property with the same alphanumeric property ID, with values matching the data type of the class property. An entity may provide values for only a subset of the properties of its class, but class properties marked `required: true` must not be omitted.

Most property values are encoded as JSON within the entity. One notable exception is metadata assigned to [implicit tiles](#implicit-tile-properties), stored in a more compact binary form.

### Tileset Properties

*Defined in [tileset.schema.json](./schema/tileset.schema.json) and [metadataEntity.schema.json](./schema/metadataEntity.schema.json)*.

Properties assigned to tilesets provide metadata about the tileset as a whole. Common examples might include year of collection, author details, or other general context for the tileset contents.

The `tileset` object within a tileset's `3DTILES_metadata` extension must specify its class (`class`). Within a `properties` dictionary, values for properties are given, encoded as JSON types according to the [JSON Format](../../specification/Metadata/README.md#json-format) specification.

> **Example:** The example below defines properties of a tileset, with the tileset being an instance of a "city" class. Required properties "dateFounded" and "population" are given; optional property "country" is omitted.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "classes": {
>           "city": {
>             "properties": {
>               "name": {"componentType": "STRING", "semantic": "NAME", "required": true},
>               "dateFounded": {"componentType": "STRING", "required": true},
>               "population": {"componentType": "UINT32", "required": true},
>               "country": {"componentType": "STRING"}
>             }
>           }
>         }
>       },
>       "tileset": {
>         "class": "city",
>         "properties": {
>           "name": "Philadelphia",
>           "dateFounded": "October 27, 1682",
>           "population": 1579000
>         }
>       }
>     }
>   }
> }
> ```

### Tile Properties

*Defined in [tile.3DTILES_metadata.schema.json](./schema/tile.3DTILES_metadata.schema.json) and [metadataEntity.schema.json](./schema/metadataEntity.schema.json)*.

Property values may be assigned to individual tiles, including (for example) spatial hints to optimize traversal algorithms. The example below uses the built-in semantic `TILE_MAXIMUM_HEIGHT` from the [3D Metadata Semantic Reference](../../specification/Metadata/Semantics).

A `3DTILES_metadata` extension on a tile object must specify its class (`class`). Within a `properties` dictionary, values for properties are given, encoded as JSON types according to the [JSON Format](../../specification/Metadata/README.md#json-format) specification.

> **Example:**
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "classes": {
>           "tile": {
>             "properties": {
>               "maximumHeight": {
>                 "semantic": "TILE_MAXIMUM_HEIGHT",
>                 "componentType": "FLOAT32"
>               },
>               "countries": {
>                 "description": "Countries a tile intersects.",
>                 "type": "ARRAY",
>                 "componentType": "STRING"
>               }
>             }
>           }
>         }
>       }
>     }
>   },
>   "root": {
>     "extensions": {
>       "3DTILES_metadata": {
>         "class": "tile",
>         "properties": {
>           "maximumHeight": 4418,
>           "countries": ["United States", "Canada", "Mexico"]
>         }
>       }
>     },
>     "content": { ... },
>     ...
>   }
> }
> ```

### Implicit Tile Properties

*Defined in [subtree.3DTILES_metadata.schema.json](./schema/3DTILES_implicit_tiling/subtree.3DTILES_metadata.schema.json) and [subtree.property.schema.json](./schema/3DTILES_implicit_tiling/subtree.property.schema.json).*

When tiles are listed explicitly within a tileset, each tile's metadata is also embedded explicitly within the tile definition. When the tile hierarchy is _implicit_, as enabled by [`3DTILES_implicit_tiling`](../3DTILES_implicit_tiling), tiles are not listed exhaustively and metadata cannot be directly embedded in tile definitions. To support metadata for tiles within implicit tiling schemes, the `3DTILES_metadata` extension provides an additional metadata storage mechanism compatible with `3DTILES_implicit_tiling`.

Unlike other methods of assigning metadata, properties of implicit tiles are not encoded as JSON objects. Instead, property values for all available tile contents are encoded in a compact [*Binary Table Format*](../../specification/Metadata/README.md#binary-table-format) defined by the 3D Metadata Specification. The binary representation is particularly efficient for larger datasets with many tiles.

 Tile metadata exists only for available tiles and is tightly packed by an increasing tile index according to the [Availability Ordering](../3DTILES_implicit_tiling/README.md#availability). Each available tile must have a value — representation of missing values within a tile is possible only with the `noData` indicator defined by the *Binary Table Format*.

> **Implementation note:** To determine the index into a property value array for a particular tile, count the number of available tiles occurring before that index, according to the tile Availability Ordering. If `i` available tiles occur before a particular tile, that tile's property values are stored at index `i` of each property value array. These indices may be precomputed for all available tiles, as a single pass over the subtree availability buffer.

Binary property value arrays are located in buffer views of the implicit tiling subtree. Storage of those subtree buffer views and buffers is defined in the [`3DTILES_implicit_tiling`](../3DTILES_implicit_tiling) extension. Details of binary value encoding, including how to determine property value offsets for mixed-length string and array values, are defined by the *Binary Table Format*.

> **Example:** The following example defines a `subtree` object from the `3DTILES_implicit_tiling` extension, extended with `3DTILES_metadata` to include "horizonOcclusionPoint" and "countries" properties for each available tile, stored in buffer views `3` and `4` respectively. The `arrayOffsetBufferView` and `stringOffsetBufferView` arrays are used to determine indices into the "countries" array, which contains tightly packed mixed-length arrays of mixed-length strings. See the *Binary Table Format* for full details.
>
> ```jsonc
> {
>   // 3DTILES_implicit_tiling defines which tiles, contents,
>   // and subtrees are available within a tileset, according
>   // to a declared subdivision scheme. Tiles are not explicitly
>   // listed.
>   "tileAvailability": {"bufferView": 0},
>   "contentAvailability": {"bufferView": 1},
>   "childSubtreeAvailability": {"bufferView": 2},
>
>   // 3DTILES_metadata defines references to property values
>   // stored in pointers to binary storage, called buffer views.
>   "extensions": {
>     "3DTILES_metadata": {
>       "class": "tile",
>       "properties": {
>         "horizonOcclusionPoint": {
>           "bufferView": 3
>         },
>         "countries": {
>           "bufferView": 4,
>           "arrayOffsetBufferView": 5,
>           "stringOffsetBufferView": 6
>         }
>       }
>     }
>   },
>
>   // Buffer views are contained in buffers. Every buffer view
>   // contains an array of values, each value corresponding to
>   // a single tile, with the order and omissions determined
>   // by the subdivision scheme and availability data given by
>   // 3DTILES_implicit_tiling.
>   "buffers": [
>     {"byteLength": 99692}
>   ],
>   "bufferViews": [
>     {"buffer": 0, "byteLength": 688, "byteOffset": 0},
>     {"buffer": 0, "byteLength": 688, "byteOffset": 688},
>     {"buffer": 0, "byteLength": 2048, "byteOffset": 1376},
>     {"buffer": 0, "byteLength": 49152, "byteOffset": 3424},
>     {"buffer": 0, "byteLength": 24576, "byteOffset": 50528},
>     {"buffer": 0, "byteLength": 8196, "byteOffset": 75104},
>     {"buffer": 0, "byteLength": 16388, "byteOffset": 83304}
>   ]
> }
> ```

### Content Group Properties

*Defined in [group.schema.json](./schema/group.schema.json), [metadataEntity.schema.json](./schema/metadataEntity.schema.json), and [tileset.3DTILES_metadata.schema.json](./schema/content.3DTILES_metadata.schema.json)*.

Tiles may contain more than one content entity (see: [`3DTILES_multiple_contents`](../3DTILES_multiple_contents)), or multiple tiles may reference content sharing the same metadata. In these cases, metadata assigned to the tile would be inadequate or inefficient for describing tile contents. This extension allows content to be organized into collections, or "groups", and metadata may be associated with each group. Groups are useful for supporting metadata on only a subset of a tile's content, or for working with collections of contents as layers, e.g. to manage visibility or visual styling.

Tile contents are assigned to groups, representing collections of content, by attaching a `3DTILES_metadata` extension to the content object and specifying its `group` property. Each content entity may be assigned only to a single group, but a single group may have any number of tile contents assigned to it.

The tileset's root `3DTILES_metadata` extension must define a list of available groups, if any, under its `groups` property. Each group definition must specify its class (`class`). Within a `properties` dictionary, values for properties are given, encoded as JSON types according to the [JSON Format](../../specification/Metadata/README.md#json-format) specification.

> **Example:** The example below defines a custom "layer" class, where each of its two groups ("buildings" and "trees") are instances of the "layer" class associated with different "name", "color", and "priority" property values. The root tile defines two contents using `3DTILES_multiple_contents`, one content item belonging to each group.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "classes": {
>           "layer": {
>             "properties": {
>               "name": {"componentType": "STRING", "semantic": "NAME", "required": true},
>               "color": {"type": "VEC3", "componentType": "UINT8"},
>               "priority": {"componentType": "UINT32"}
>             }
>           }
>         }
>       },
>       "groups": {
>         "buildings": {
>           "class": "layer",
>           "properties": {
>             "name": "Buildings Layer",
>             "color": [128, 128, 128],
>             "priority": 0
>           }
>         },
>         "trees": {
>           "class": "layer",
>           "properties": {
>             "name": "Trees Layer",
>             "color": [10, 240, 30],
>             "priority": 1
>           }
>         }
>       }
>     }
>   },
>   "root": {
>     "extensions": {
>       "3DTILES_multiple_contents": {
>         "content": [
>           {
>             "uri": "buildings.glb",
>             "extensions": {"3DTILES_metadata": {"group": "buildings"}}
>           },
>           {
>             "uri": "trees.glb",
>             "extensions": {"3DTILES_metadata": {"group": "trees"}}
>           }
>         ]
>       }
>     },
>     ...
>   }
> }
> ```

### Content Feature Properties

_This section is non-normative_

Certain kinds of tile content may contain meaningful subcomponents ("features"), which may themselves be associated with metadata through more granular properties. Schemas may be embedded in these content types, but unused classes in a `3DTILES_metadata` schema are allowed, and may hint to an application that tile content might include entities instantiating those classes.

Assigning properties to tile content is not within the scope of this extension, but may be defined by other specifications. One such example is the glTF extension, [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features), which supports definitions of conceptual features within geometry and textures, and associated metadata. glTF 2.0 assets with feature metadata may be included as tile contents with the [`3DTILES_content_gltf`](../3DTILES_content_gltf) extension.

While `3DTILES_metadata` and `EXT_mesh_features` are defined independently, both conform to the [3D Metadata Specification](../../specification/Metadata/README.md) and share the same representation of metadata as schema and properties.

## Schema

* [tileset.3DTILES_metadata.schema.json](./schema/tileset.3DTILES_metadata.schema.json)
* [tile.3DTILES_metadata.schema.json](./schema/tile.3DTILES_metadata.schema.json)
* [content.3DTILES_metadata.schema.json](./schema/content.3DTILES_metadata.schema.json)

## Revision History

* **Version 0.0.0** November 6, 2020
  * Initial draft
* **Version 1.0.0** February 25, 2021
  * Changes to properties
    * Removed `FLOAT16` type
    * Removed `BLOB` type and `blobByteLength` property
    * Removed `stringByteLength` property
    * Added optional `semantic` property
    * Added enum support. Added `ENUM` to `type` and `componentType` and added `enumType` property.
    * `min` and `max` are now numbers instead of single-element arrays for non-`ARRAY` properties
  * Changes to `3DTILES_metadata` extension object
    * Added `schema` which contains `classes` and `enumas`
    * Added `schemaUri` which refers to an external schema JSON file
    * Added `groups` which contain metadata about groups of content. Contents are assigned to groups with the `3DTILES_metadata` content extension.
    * Added `statistics` which provide aggregate information about select properties within a tileset.
  * Added tile metadata. A tile may specify its class and property values with the `3DTILES_metadata` tile extension object.
  * Added support for tile metadata in the `3DTILES_implicit_tiling` extension. Tile metadata may be provided for each subtree in binary.
* **Version 2.0.0** October 2021
  * Removed `optional` and added `required`. Properties are now assumed to be optional unless `required` is true.
  * Added `noData` for specifying a sentinel value that indicates missing data
  * Removed `default`
  * `NaN` and `Infinity` are now explicitly disallowed as property values
  * Relaxed buffer view alignment to component size, rather than strict 8-byte boundaries
  * Added vector and matrix types: `VEC2`, `VEC3`, `VEC4`, `MAT2`, `MAT3`, `MAT4`
  * Refactored `type` and `componentType` to avoid overlap. Properties that store a single value now have a `type` of `SINGLE` and a `componentType` of the desired type (e.g. `type: "SINGLE", componentType: "UINT8"`)
  * Class IDs, enum IDs, property IDs, and group IDs must now contain only alphanumeric and underscore characters
  * Split `offsetType` into `arrayOffsetType` and `stringOffsetType`
  * Removed incomplete styling section
  * Recommend "_*" prefix for application-specific summary statistics
  * Renamed `min` and `max` summary statistics to `minimum` and `maximum`
  * Removed `name` and `description` from entity schemas. Entities should use properties with equivalent semantics instead.
  * Added `id` to schema object