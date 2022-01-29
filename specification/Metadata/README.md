<!-- omit in toc -->
# 3D Metadata Specification

<!-- omit in toc -->
## Contributors

* Peter Gagliardi, Cesium
* Sean Lilley, Cesium
* Sam Suhag, Cesium
* Don McCurdy, Independent
* Bao Tran, Cesium
* Patrick Cozzi, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Concepts](#concepts)
- [Schemas](#schemas)
  - [Schema](#schema)
    - [ID](#id)
    - [Version](#version)
    - [Name](#name)
    - [Description](#description)
    - [Enums](#enums)
    - [Classes](#classes)
  - [Enum](#enum)
    - [ID](#id-1)
    - [Name](#name-1)
    - [Description](#description-1)
    - [Values](#values)
  - [Class](#class)
    - [ID](#id-2)
    - [Name](#name-2)
    - [Description](#description-2)
    - [Properties](#properties)
  - [Property](#property)
    - [Overview](#overview-1)
    - [ID](#id-3)
    - [Name](#name-3)
    - [Description](#description-3)
    - [Semantic](#semantic)
    - [Type](#type)
    - [Component Type](#component-type)
    - [Normalized Values](#normalized-values)
    - [Minimum and Maximum Values](#minimum-and-maximum-values)
    - [Required Properties and No Data Values](#required-properties-and-no-data-values)
- [Storage Formats](#storage-formats)
  - [Overview](#overview-2)
  - [Binary Table Format](#binary-table-format)
    - [Overview](#overview-3)
    - [Numbers](#numbers)
    - [Booleans](#booleans)
    - [Strings](#strings)
    - [Enums](#enums-1)
    - [Arrays](#arrays)
  - [JSON Format](#json-format)
    - [Overview](#overview-4)
    - [Numbers](#numbers-1)
    - [Booleans](#booleans-1)
    - [Strings](#strings-1)
    - [Enums](#enums-2)
    - [Arrays](#arrays-1)
- [Revision History](#revision-history)

## Overview

The 3D Metadata Specification defines a standard format for structured metadata in 3D content. Metadata — represented as entities and properties — may be closely associated with parts of 3D content, with data representations appropriate for large, distributed datasets. For the most detailed use cases, properties allow vertex- and texel-level associations; higher-level property associations are also supported.

Many domains benefit from structured metadata — typical examples include historical details of buildings in a city, names of components in a CAD model, descriptions of regions on textured surfaces, and classification codes for point clouds.

The specification defines core concepts to be used by multiple 3D formats, and is language and format agnostic. This document defines concepts with purpose and terminology, but does not impose a particular schema or serialization format for implementation. For use of the format outside of abstract conceptual definitions, see:

* [`3DTILES_metadata`](../../extensions/3DTILES_metadata) (3D Tiles 1.0) — Assigns metadata to tilesets, tiles, or tile contents
* [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) (glTF 2.0) —  Assigns metadata to subcomponents ("features") of geometry or textures

The specification does not enumerate or define the semantic meanings of metadata, and assumes that separate specifications will define semantics for their particular application or domain. One example is the [3D Metadata Semantic Reference](./Semantics/) which defines built-in semantics for 3D Tiles and glTF. Identifiers for externally-defined semantics can be stored within the 3D Metadata Specification.

## Concepts

This specification defines metadata schemas and methods for encoding metadata.

**Schemas** contain a set of **classes** and **enums**. A class represents a category of similar entities, and is defined as a set of **properties**. Each property describes values of a particular type. An enum defines a set of named values representing a single value type, and may be referenced by class properties. Schema definitions do not describe how entities or properties are stored, and may be represented in a file format in various ways. Schemas can be reused across multiple assets or even file formats.

**Entities** are instantiations of a class, populated with **property values** conforming to the class definition. Every property value of an entity must be defined by its class, and an entity must not have extraneous property values. Properties of a class may be required, in which case all entities instantiating the class are required to include them.

>  **Implementation note:** Entities may be defined at various levels of abstraction. Within a large dataset, individual vertices or texels may represent entities with granular metadata properties. Vertices and texels may be organized into higher-order groups (such as meshes, scene graphs, or tilesets) having their own associated properties.

**Metadata**, as used throughout this specification, refers to any association of 3D content with entities and properties, such that entities represent meaningful units within an overall structure. Other common definitions of metadata, particularly in relation to filesystems or networking as opposed to 3D content, remain outside the scope of the document.

Property values are stored with flexible representations to allow compact transmission and efficient lookups. This specification defines two possible [storage formats](#storage-formats).

## Schemas

### Schema

A schema defines the organization and types of metadata used in 3D content, represented as a set of classes and enums. Class definitions are referenced by entities whose metadata conforms to the class definition. This provides a consistent and machine-readable structure for all entities in a dataset.

Components of a schema are listed below, and implementations may define additional components.

#### ID

IDs (`id`) uniquely identify a schema, and must contain only alphanumeric characters and underscores. IDs should be camel case strings that are human-readable (wherever possible). When IDs subject to these restrictions are not sufficiently clear for human readers, applications should also provide a `name`.

When a schema has multiple versions, the `(id, version)` pair uniquely identifies a particular schema and revision.

#### Version

Schema version (`version`) is an application-specific identifier for a given schema revision. Version must be a string, and should be syntactically compatible with [SemVer](https://semver.org/).

When a schema has multiple versions, the `(id, version)` pair uniquely identifies a particular schema and revision.

> **Example:** Valid semantic versions include strings like `0.1.2`, `1.2.3`, and `1.2.3-alpha`.

#### Name

Names (`name`) provide a human-readable label for a schema, and are not required to be unique. Names must be valid Unicode strings, and should be written in natural language.

#### Description

Descriptions (`description`) provide a human-readable explanation of a schema, its purpose, or its contents. Typically at least a phrase, and possibly several sentences or paragraphs.

#### Enums

Unordered set of [enums](#enum).

#### Classes

Unordered set of [classes](#class).

***

### Enum

An enum consists of a set of named values, represented as `(string, integer)` pairs. Each enum collection is identified by a unique ID.

> **Example:** A "species" enum with three possible tree species, as well as an "Unknown" value.
>
> - **ID:** "species"
> - **Name:** "Species"
> - **Description:** "Common tree species identified in the study."
>
> | name      | value |
> |-----------|------:|
> | "Oak"     |     0 |
> | "Pine"    |     1 |
> | "Maple"   |     2 |
> | "Unknown" |    -1 |

#### ID

IDs (`id`) uniquely identify an enum within a schema, and must contain only alphanumeric characters and underscores. IDs should be camel case strings that are human-readable (wherever possible). When IDs subject to these restrictions are not sufficiently clear for human readers, applications should also provide a `name`.

#### Name

Names (`name`) provide a human-readable label for an enum, and are not required to be unique within a schema. Names must be valid Unicode strings, and should be written in natural language.

#### Description

Descriptions (`description`) provide a human-readable explanation of an enum, its purpose, or its contents. Typically at least a phrase, and possibly several sentences or paragraphs.

#### Values

An enum consists of a set of named values, represented as `(string, integer)` pairs. The following enum value types are supported: `INT8`, `UINT8`, `INT16`, `UINT16`, `INT32`, `UINT32`, `INT64`, and `UINT64`. See the [Type](#type) section for definitions of each. Smaller enum types limit the range of possible enum values, and allow more efficient binary encoding. For unsigned value types, enum values most be non-negative. Duplicate names or values within the same enum are not allowed.

***

### Class

Classes represent categories of similar entities, and are defined by a collection of one or more properties shared by the entities of a class. Each class has a unique ID within the schema, and each property has a unique ID within the class, to be used for references within the schema and externally.

#### ID

IDs (`id`) uniquely identify a class within a schema, and must contain only alphanumeric characters and underscores. IDs should be camel case strings that are human-readable (wherever possible). When IDs subject to these restrictions are not sufficiently clear for human readers, applications should also provide a `name`.

#### Name

Names (`name`) provide a human-readable label for a class, and are not required to be unique within a schema. Names must be valid Unicode strings, and should be written in natural language.

#### Description

Descriptions (`description`) provide a human-readable explanation of a class, its purpose, or its contents. Typically at least a phrase, and possibly several sentences or paragraphs.

#### Properties

Unordered set of [properties](#property).

***

### Property

#### Overview

Properties describe the type and structure of values that may be associated with entities of a class. Entities may omit values for a property, unless the property is required. Entities must not contain values other than those defined by the properties of their class.

> **Example:** The following example shows the basics of how classes describe the types of metadata. A `building` class describes the heights of various buildings in a dataset. Likewise, the `tree` class describes trees that have a height, species, and leaf color.
>
> **building**
>
> | property | componentType | required | noData |
> |:---------|:--------------|:---------|:-------|
> | height   | "FLOAT32"     | ✓        |        |
>
> **tree**
>
> | property  | componentType | required | noData    |
> |:----------|:--------------|:---------|:----------|
> | height    | "FLOAT32"     | ✓        |           |
> | species   | "STRING"      |          | "Unknown" |
> | leafColor | "STRING"      | ✓        |           |

#### ID

IDs (`id`) uniquely identify a property within a class, and must contain only alphanumeric characters and underscores. IDs should be camel case strings that are human-readable (wherever possible). When IDs subject to these restrictions are not sufficiently clear for human readers, applications should also provide a `name`.

#### Name

Names (`name`) provide a human-readable label for a property, and must be unique to a property within a class. Names must be valid Unicode strings, and should be written in natural language. Property names do not have inherent meaning; to provide such a meaning, a property must also define a [semantic](#semantic).

> **Example:** A typical ID / Name pair, in English, would be `localTemperature` and `"Local Temperature"`. In Japanese, the name might be represented as "きおん". Because IDs are restricted to alphanumeric characters and underscores, use of helpful property names is essential for clarity in many languages.

#### Description

Descriptions (`description`) provide a human-readable explanation of a property, its purpose, or its contents. Typically at least a phrase, and possibly several sentences or paragraphs. To provide a machine-readable semantic meaning, a property must also define a [semantic](#semantic).

#### Semantic

Property IDs, names, and descriptions do not have an inherent meaning. To provide a machine-readable meaning, properties may be assigned a semantic identifier string (`semantic`), indicating how the property's content should be interpreted. Semantic identifiers may be defined by the [3D Metadata Semantic Reference](./Semantics/) or by external semantic references, and may be application-specific. Identifiers should be uppercase, with underscores as word separators.

> **Example:** Semantic definitions might include temperature in degrees Celsius (e.g. `TEMPERATURE_DEGREES_CELSIUS`), time in milliseconds (e.g. `TIME_MILLISECONDS`), or mean squared error (e.g. `MEAN_SQUARED_ERROR`). These examples are only illustrative.

#### Type

A property's type (`type`) describes the structure of the value given for each entity. Most commonly a single value, a property may also represent a fixed- or variable-length array, or vector and matrix types:

| name   | type                                                    |
|--------|---------------------------------------------------------|
| SINGLE | Single-component value or scalar                        |
| ARRAY  | Fixed- or variable-length array of arbitrary components |
| VEC2   | Fixed-length vector with two (2) numeric components     |
| VEC3   | Fixed-length vector with three (3) numeric components   |
| VEC4   | Fixed-length vector with four (4) numeric components    |
| MAT2   | 2x2 matrix                                              |
| MAT3   | 3x3 matrix                                              |
| MAT4   | 4x4 matrix                                              |

The `ARRAY` type is used to define a fixed- or variable-length array of components. For fixed-length arrays, a component count denotes the number of components in each array, and must be ≥2. Variable-length arrays do not define a component count, and arrays may have any length, including zero.

The `VECN` and `MATN` types represent specific subsets of the fixed-length `ARRAY` type, where `VECN` is a vector with `N` numeric components and `MATN` is an `N x N` matrix with `N²` numeric components in column-major order. Where applicable, authoring implementations should choose these more specific types. Schema representations may choose to make component counts for `VECN` and `MATN` types implicit, rather than storing a `componentCount` descriptor for `VECN` and `MATN` types.

> **Example:** This example defines a `car` class with three array-like properties. The `passengers` property is a variable-length array, because `componentCount` is undefined.
>
> | property         | description                |  type   | componentType | componentCount |
> |:-----------------|:---------------------------|:-------:|:-------------:|---------------:|
> | forwardDirection | "Forward direction vector" | "VEC3"  |   "FLOAT64"   |              3 |
> | passengers       | "Passenger names"          | "ARRAY" |   "STRING"    |                |
> | modelMatrix      | "4x4 model matrix"         | "MAT4"  |   "FLOAT32"   |             16 |

#### Component Type

Properties may be comprised of one component (`SINGLE`) or many components (`ARRAY`, `VECN`, `MATN`), depending on the property `type`. Each component is an instance of the property's component type (`componentType`), with the following component types supported:

| name    | componentType                                                             |
|---------|---------------------------------------------------------------------------|
| INT8    | Signed integer in the range `[-128, 127]`                                 |
| UINT8   | Unsigned integer in the range `[0, 255]`                                  |
| INT16   | Signed integer in the range `[-32768, 32767]`                             |
| UINT16  | Unsigned integer in the range `[0, 65535]`                                |
| INT32   | Signed integer in the range `[-2147483648, 2147483647]`                   |
| UINT32  | Unsigned integer in the range `[0, 4294967295]`                           |
| INT64   | Signed integer in the range `[-9223372036854775808, 9223372036854775807]` |
| UINT64  | Unsigned integer in the range `[0, 18446744073709551615]`                 |
| FLOAT32 | A number that can be represented as a 32-bit IEEE floating point number   |
| FLOAT64 | A number that can be represented as a 64-bit IEEE floating point number   |
| BOOLEAN | True or false                                                             |
| STRING  | A sequence of characters                                                  |
| ENUM    | An enumerated type                                                        |

Floating-point properties (`FLOAT32` and `FLOAT64`) must not include values `NaN`, `+Infinity`, or `-Infinity`.

[Enum properties](#enums) are denoted by `ENUM`. An enum property must additionally provide the ID of the specific enum it uses, referred to as its enum type (`enumType`).

> **Implementation Note:** Developers of authoring tools should be aware that many JSON implementations support only numeric values that can be represented as IEEE-754 double precision floating point numbers. Floating point numbers should be representable as double precision IEEE-754 floats when encoded in JSON. When those numbers represent property values (such as `noData`, `min`, or `max`) having lower precision (e.g. single-precision float, 8-bit integer, or 16-bit integer), the values should be rounded to the same precision in JSON to avoid any potential mismatches. Numeric property values encoded in binary storage are unaffected by these limitations of JSON implementations.

#### Normalized Values

Normalized properties (`normalized`) provide a compact alternative to larger floating-point types. Normalized values are stored as integers, but when accessed are transformed to floating-point form according to the following rules:

* Unsigned integer values (`UINT8`, `UINT16`, `UINT32`, `UINT64`) must be rescaled to the range `[0.0, 1.0]` (inclusive)
* Signed integer values (`INT8`, `INT16`, `INT32`, `INT64`) must be rescaled to the range `[-1.0, 1.0]` (inclusive)

> **Implementation Note:** Depending on the implementation and the chosen integer type, there may be some loss of precision in values after denormalization. For example, if the implementation uses 32-bit floating point variables to represent the value of a normalized 32-bit integer, there are only 23 bits in the mantissa of the float, and lower bits will be truncated by denormalization. Client implementations should use higher precision floats when appropriate for correctly representing the result.

#### Minimum and Maximum Values

Properties representing numeric values, fixed-length numeric arrays, vectors, and matrices may specify a minimum (`minimum`) and maximum (`maximum`). Minimum and maximum values represent component-wise bounds of the valid range for a property.

> **Example:** A property storing GPS coordinates might define a range of `[-180, 180]` degrees for longitude values and `[-90, 90]` degrees for latitude values.

#### Required Properties and No Data Values

When associated property values must exist for all entities of a class, a property is considered required (`required`).

Properties may optionally specify a No Data value (`noData`, or "sentinel value") to be used when property values do not exist. This value must match the property definition, e.g. if `type` is `UINT8` the `noData` value must be an unsigned integer in the range `[0, 255]`. If the property is normalized, the `noData` value is given in its original integer form, not the normalized form.

Individual components in an array cannot be marked as optional; only the array property itself can be marked as optional.

For `ARRAY`, `VECN`, and `MATN` types, `noData` is an array-typed value indicating that the entire array represents a missing value. For example, `[-1, -1, -1]` might be used as a `noData` value for a `VEC3` property. When an array-typed property is required or includes a `noData` value, this has no effect on the interpretation of individual array elements. When variable-length arrays are required, an empty array is still valid.

For `ENUM` component types, a `noData` value should contain the name of the enum value as a string, rather than its integer value.

> **Example:** In the example below, a "tree" class is defined with `noData` indicating a specific enum value to be interpreted as missing data.
>
> | property  | componentType | required | noData    |
> |:----------|:--------------|:---------|:----------|
> | height    | "FLOAT32"     | ✓        |           |
> | species   | "ENUM"        |          | "Unknown" |
> | leafColor | "STRING"      | ✓        |           |

## Storage Formats

### Overview

Schemas provide templates for entities, but creating an entity requires specific property values and storage. This section covers two storage formats for entity metadata:

* **Binary Table Format** - property values are stored in parallel 1D arrays, encoded as binary data
* **JSON Format** - property values are stored in key/value dictionaries, encoded as JSON objects

Both formats formats are suitable for general purpose metadata storage. Binary formats may be preferrable for larger quantities of metadata.

Additional serialization methods may be defined outside of this specification. For example, property values could be stored in texture channels or retrieved from a REST API as XML data.

> **Implementation note:** Any specification that references 3D Metadata must state explicitly which storage formats are supported, or define its own serialization. For example, the [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) glTF extension implements the binary table format described below, and defines an additional image-based format for per-texel metadata.

### Binary Table Format

#### Overview

The binary table format is similar to a database table where entities are rows and properties are columns. Each column represents one of the properties of the class. Each row represents a single entity conforming to the class.

<img src="figures/table-format.png"  alt="Table Format" width="1000px">

The rows of a table are addressed by an integer index called an **entity ID**. Entity IDs are always numbered `0, 1, ..., N - 1` where `N` is the number of rows in the table.

Property values are stored in parallel arrays called **property arrays**, one per column. Each property array stores values for a single property. The `i-th` value of each property array is the value of that property for the entity with an entity ID of `i`.

Binary encoding is efficient for runtime use, and scalable to large quantities of metadata. Because property arrays contain elements of a single type, bitstreams may be tightly packed or may use compression methods appropriate for a particular data type.

Property values are binary-encoded according to their data type, in little-endian format. Values are tightly packed: there is no padding between values.

#### Numbers

A numeric value may be encoded as 8-, 16-, 32-, or 64-bit types. Multiple numeric values are packed tightly in the same buffer. The following data types are supported:

| Name    | Description                            |
|---------|----------------------------------------|
| INT8    | 8-bit two's complement signed integer  |
| UINT8   | 8-bit unsigned integer                 |
| INT16   | 16-bit two's complement signed integer |
| UINT16  | 16-bit unsigned integer                |
| INT32   | 32-bit two's complement signed integer |
| UINT32  | 32-bit unsigned integer                |
| INT64   | 64-bit two's complement signed integer |
| UINT64  | 64-bit unsigned integer                |
| FLOAT32 | 32-bit IEEE floating point number      |
| FLOAT64 | 64-bit IEEE floating point number      |

#### Booleans

A boolean value is encoded as a single bit, either 0 (`false`) or 1 (`true`). Multiple boolean values are packed tightly in the same buffer. These buffers of tightly-packed bits are sometimes referred to as bitstreams.

For a table with `N` rows, the buffer that stores these boolean values will consist of `ceil(N / 8)` bytes. When `N` is not divisible by 8, then the unused bits of the last byte of this buffer must be set to 0.

> **Implementation note:** Example accessing a boolean value for entity ID `i`.
>
> ```js
> byteIndex = floor(i / 8)
> bitIndex = i % 8
> bitValue = (buffer[byteIndex] >> bitIndex) & 1
> value = bitValue == 1
> ```

#### Strings

A string value is a UTF-8 encoded byte sequence. Multiple strings are packed tightly in the same buffer.

Because string lengths may vary, a **string offset** buffer (`stringOffset`) is used to identify strings in the buffer. If there are `N` strings in the property array, the string offset buffer has `N + 1` elements. The first `N` of these point to the first byte of each string, while the last points to the byte immediately after the last string. The number of bytes in the `i-th` string is given by `stringOffset[i + 1] - stringOffset[i]`. UTF-8 encodes each character as 1-4 bytes, so string offsets do not necessarily represent the number of characters in the string.

The data type used for offsets is defined by a **string offset type** (`stringOffsetType`), which may be `UINT8`, `UINT16`, `UINT32`, or `UINT64`.

> **Example:** Three UTF-8 strings, binary-encoded in a buffer.
>
> ![String property example](figures/unicode-strings.png)

#### Enums

Enums are encoded as integer values according to the enum value type (see [Enums](#enums)). Multiple enum values are packed tightly in the same buffer. Any integer data type supported for [Numbers](#numbers) may be used for enum values.

#### Arrays

Array values are encoded with varying array lengths and element sizes. Multiple arrays and array values are packed tightly in the same buffer.

Variable-length arrays use an additional **array offset** buffer (`arrayOffset`). The `i-th` value in the array offset buffer is an element index — not a byte offset — identifying the beginning of the `i-th` array. String values within an array may have inconsistent lengths, requiring both array offset and **string offset** buffers (see: [Strings](#strings)).

The data type used for offsets is defined by an **array offset type** (`arrayOffsetType`), which may be `UINT8`, `UINT16`, `UINT32`, or `UINT64`.

If there are `N` arrays in the property array, the array offset buffer has `N + 1` elements. The first `N` of these point to the first element of an array within the property array, or within a string offset buffer for string component types. The last value points to a (non-existent) element immediately following the last array element.

As a result, property value lookups for fixed- and variable-length arrays must compute an element's index differently. For each case below, the offset of an array element `i` within its binary storage is expressed in terms of entity ID `id` and element index `i`.

| Array length | Array type                        | Offset type | Offset                                  |
|--------------|-----------------------------------|-------------|-----------------------------------------|
| variable     | `number[]`, `boolean[]`, `enum[]` | array index | `arrayOffset[id] + i`                   |
| fixed        | `number[]`, `boolean[]`, `enum[]` | array index | `id * componentCount + i`               |
| variable     | `string[]`                        | byte offset | `stringOffset[arrayOffset[id] + i]`     |
| fixed        | `string[]`                        | byte offset | `stringOffset[id * componentCount + i]` |

`VECN` and `MATN` types are treated as fixed-length numeric arrays.

Each expression in the table above defines an index into the underlying property array. For a property array of `FLOAT32` components, index `3` would correspond to <u>_byte_</u> offset `3 * sizeof(FLOAT32) = 12` within that array. For an array of `BOOLEAN` components, offset `3` would correspond to <u>_bit_</u> offset `3`.

> **Example:** Five variable-length arrays of UINT8 components, binary-encoded in a buffer. The associated property definition would be `type = "ARRAY"`, and `componentType = "UINT8"`, `componentCount = undefined` (variable-length).
>
> <img src="figures/array-of-ints.png"  alt="Variable-length array" width="640px">

> **Example:** Two variable-length arrays of strings, binary-encoded in a buffer. The associated property definition would be `type = "ARRAY"`, `componentType = "STRING"`, `componentCount = undefined` (variable-length). Observe that the last element of the array offset buffer points to the last element of the string offset buffer. This is because the last valid string offset is the next-to-last element of the string offset buffer.
>
> ![Variable-length array of string](figures/array-of-strings.png)

### JSON Format

#### Overview

JSON encoding is useful for storing a small number of entities in human readable form.

Each entity is represented as a JSON object with its `class` identified by a string ID. Property values are defined in a key/value `properties` dictionary, having property IDs as its keys. Property values are encoded as corresponding JSON types: numeric types are represented as `number`, booleans as `boolean`, strings as `string`, enums as `string`, and arrays, vectors and matrices as `array`.

> **Example:** The following example demonstrates usage for both fixed and variable size arrays:
>
> _An enum, "basicEnum", composed of three `(name: value)` pairs:_
>
> | name       | value |
> |------------|-------|
> | `"Enum A"` | `0`   |
> | `"Enum B"` | `1`   |
> | `"Enum C"` | `2`   |
>
> _A class, "basicClass", composed of eight properties. `stringArrayProperty` (`ARRAY`) component count is undefined and therefore variable. `optionalProperty` (`VEC3`) component count is implicitly `3`, and may be omitted from the property definition._
>
> | id                  | type       | componentType | componentCount | enumType      | required |
> |---------------------|------------|---------------|----------------|---------------|----------|
> | floatProperty       | `"SINGLE"` (default) | `"FLOAT64"`   |                |               | ✓        |
> | integerProperty     | `"SINGLE"` | `"INT32"`     |                |               | ✓        |
> | booleanProperty     | `"SINGLE"` | `"BOOLEAN"`   |                |               | ✓        |
> | stringProperty      | `"SINGLE"` | `"STRING"`    |                |               | ✓        |
> | enumProperty        | `"SINGLE"` | `"ENUM"`      |                | `"basicEnum"` | ✓        |
> | floatArrayProperty  | `"ARRAY"`  | `"FLOAT32"`   | `3`            |               | ✓        |
> | stringArrayProperty | `"ARRAY"`  | `"STRING"`    |                |               | ✓        |
> | optionalProperty    | `"VEC3"`   | `"UINT8"`     |                |               |          |
>
> _A single entity encoded in JSON. Note that the optional property is omitted in this example._
> ```jsonc
> {
>   "entity": {
>     "class": "basicClass",
>     "properties": {
>       "floatProperty": 1.5,
>       "integerProperty": -90,
>       "booleanProperty": true,
>       "stringProperty": "x123",
>       "enumProperty": "Enum B",
>       "floatArrayProperty": [1.0, 0.5, -0.5],
>       "stringArrayProperty": ["abc", "12345", "おはようございます"]
>     }
>   }
> }
> ```

#### Numbers

All numeric types (`INT8`, `UINT8`, `INT16`, `UINT16`, `INT32`, `UINT32`, `INT64`, `UINT64`, `FLOAT32`, and `FLOAT64`) are encoded as JSON numbers. Floating point values must be representable as IEEE floating point numbers.

> **Implementation Note:** For numeric types the size in bits is made explicit. Even though JSON only has a single `number` type for all integers and floating point numbers, the application that consumes the JSON may make a distinction. For example, C and C++ have several different integer types such as `uint8_t`, `uint32_t`. The application is responsible for interpreting the metadata using the type specified in the property definition.

#### Booleans

Booleans are encoded as a JSON boolean, either `true` or `false`.

#### Strings

Strings are encoded as JSON strings.

#### Enums

Enums are encoded as JSON strings using the name of the enum value rather than the integer value. Therefore the enum value type, if specified, is ignored for the JSON encoding.

#### Arrays

Arrays are encoded as JSON arrays, where each component is encoded according to the component type. When a component count is specified, the length of the JSON array must match the component count. Otherwise, for variable-length arrays, the JSON array may be any length, including zero-length.

`VECN` and `MATN` types are treated as fixed-length numeric arrays.

## Revision History

* **Version 0.0.0** November 6, 2020
  * Initial draft
* **Version 1.0.0** February 25, 2021
  * The specification has been revised to focus on the core concepts of schemas (including classes, enums, and properties) and formats for encoding metadata. It is now language independent. The JSON schema has been removed.
  * Added schemas which contain classes and enums
  * Added enum support
  * Added ability to assign a semantic identifiers to properties
  * Removed blob support
  * Removed special handling for fixed-length strings
* **Version 2.0.0** September, 2021
  * Removed raster encoding. Storing metadata in texture channels remains a valid implementation of this specification, but is not within the scope of this document.
  * Removed table layout from the JSON Format; each entity is encoded as a single JSON object.
  * Removed `optional` and added `required`. Properties are now assumed to be optional unless `required` is true.
  * Added `noData` for specifying a sentinel value that indicates missing data
  * Removed `default`
  * `NaN` and `Infinity` are now explicitly disallowed as property values
  * Added vector and matrix types: `VEC2`, `VEC3`, `VEC4`, `MAT2`, `MAT3`, `MAT4`
  * Refactored `type` and `componentType` to avoid overlap. Properties that store a single value now have a `type` of `SINGLE` and a `componentType` of the desired type (e.g. `type: "SINGLE", componentType: "UINT8"`)
  * Class IDs, enum IDs, property IDs, and group IDs must now contain only alphanumeric and underscore characters
  * Split `offsetType` into `arrayOffsetType` and `stringOffsetType`
  * Add `name` and `description` to schema, class, and enum definitions
  * Add `id` to schema definitions
