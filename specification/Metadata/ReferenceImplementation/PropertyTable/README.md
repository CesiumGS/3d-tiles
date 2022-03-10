# Property Table Implementation

The [3D Metadata Specification](../../README.md) defines schemas as a description of the structure of metadata, and different storage formats for the metadata. One form of storing metadata is that of a [Binary Table Format](../../README.md#binary-table-format), where the data is stored in a binary representation of a table. Each column of such a table represents one of the properties of a class. Each row represents a single entity conforming to the class. The following is the description of such a binary table format, referred to as **property table**. It is used as the basis for defining the metadata storage in the following implementations:

* [3D Tiles Metadata Implicit Tilesets](TODO) - Assigns metadata to tilesets, tiles, groups, and contents in a 3D Tiles tileset.
* [`EXT_structural_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_structural_metadata) — Assigns metadata to vertices, texels, and features in a glTF asset.

The full JSON schema definition for this implementation can be found in [the PropertyTable directory of the specification](../../../schema/PropertyTable/).

### Property Tables

*Defined in [propertyTable.schema.json](../../../schema/PropertyTable/propertyTable.schema.json).*

A property table must specify the following elements:

- Its class (`class`), which refers to a class ID in a [Schema](../Schema/) schema.
- A dictionary of properties (`properties`), where each key is a property ID correspond to a class property.
- A count (`count`) for the number of elements in the property table.

The property table may provide value arrays for only a subset of the properties of its class, but class properties that are marked `required: true` in the schema must not be omitted.

> **Example:** A `tree_survey_2021-09-29` property table, implementing the `tree` class defined in the [Schema](../Schema/) examples. The table contains observations for 10 trees. Details about the class properties will be given in later examples.
>
> ```jsonc
> "schema": { ... },
> "propertyTables": [{
>   "name": "tree_survey_2021-09-29",
>   "class": "tree",
>   "count": 10,
>   "properties": {
>     "species": { ... },
>     "age": { ... },
>     "height": { ... },
>     // "diameter" is not required and has been omitted from this table.
>   }
> }]
> ```

### Property Table Properties

*Defined in [propertyTable.property.schema.json](../../../schema/PropertyTable/propertyTable.property.schema.json).*

Each property definition in a property table represents one column of the table. This column data is stored in binary form, using the encoding defined in the [Binary Table Format](../../README.md#binary-table-format) section of the 3D Metadata Specification. The actual data is stored in a binary buffer, and the property refers to a section of this buffer. Such a subsection of a buffer is called a _buffer view_, and defined in the implementation that uses property tables:

* In the [3D Tiles Metadata](TODO) implementation, a buffer view is defined as part of [subtrees in implicit tilesets](../../../ImplicitTiling/README.md#buffers-and-buffer-views).
- In the [`EXT_structural_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_structural_metadata), a buffer view is a standard glTF buffer view. 

The exact structure of each property table property depends on the [property type](../../README.md#property):

- Every property definition must define the `values` that store the raw data of the actual values
- Properties that have the `STRING` component type must define the `stringOffsets`, as defined in [Strings](../../README.md#strings)
- Properties that are variable-length arrays must define the `arrayOffsets`, as defined in [Arrays](../../README.md#arrays)

 For variable-length arrays of strings, both the `stringOffsets` and the `arrayOffsets` are required. In addition to these buffer view references, the property may define futher details about the storage format: `arrayOffsetType` describes the storage type for array offsets and `stringOffsetType` describes the storage type for string offsets. Allowed types are `UINT8`, `UINT16`, `UINT32`, and `UINT64`. The default is `UINT32`.

> **Example:** The property table from the previous example, with details about the binary storage of the property values
>
> ```jsonc
> {
>   "propertyTables": [{
>     "name": "tree_survey_2021-09-29",
>     "class": "tree",
>     "count": 10,
>     "properties": {
>       "species": {
>         "values": 2,
>         "stringOffsets": 3
>       },
>       "age": {
>         "values": 1
>       },
>       "height": {
>         "values": 0
>       },
>       // "diameter" is not required and has been omitted from this table.
>     }
>   }]
> }
> ```

Each buffer view `byteOffset` must be aligned to a multiple of its component size. 

> **Implementation note:** Authoring tools may choose to align all buffer views to 8-byte boundaries for consistency, but client implementations should only depend on 8-byte alignment for buffer views containing 64-bit component types.

A property may override the [`minimum` and `maximum` values](../Metadata#minimum-and-maximum-values) and the [`offset` and `scale`](../Metadata#offset-and-scale) from the property definition in the class, to account for the actual range of values that is stored in the property table.

