## Revision History

### November 2020

* Added 3D Metadata Specification (draft version `0.0.0`)
* Added `3DTILES_metadata` extension (draft version `0.0.0`)
* Added `3DTILES_content_gltf` extension (draft version `0.0.0`)
* Added `EXT_feature_metadata` glTF extension (draft version `0.0.0`)

### February 2021

* Added 3D Metadata Semantic Reference (draft version `1.0.0`)
* Added `3DTILES_implicit_tiling` extension (draft version `0.0.0`)
* Added `3DTILES_multiple_contents` extension (draft version `0.0.0`)
* Updated 3D Metadata Specification
  * Updated to draft version `1.0.0`
  * The specification has been revised to focus on the core concepts of schemas (including classes, enums, and properties) and formats for encoding metadata. It is now language independent. The JSON schema has been removed.
  * Added schemas which contain classes and enums
* Updated schema definition
  * Removed `FLOAT16` type
  * Removed `BLOB` type and `blobByteLength` property
  * Removed `stringByteLength` property
  * Added `semantic` property
  * Added `ENUM` to the list of supported types and component types and added `enumType` to refer to the chosen enum
  * `min` and `max` are now numbers instead of single-element arrays for non-`ARRAY` properties
* Updated property table definition
  * Removed `offsetBufferViews`, replaced with `arrayOffsetBufferView` and `stringOffsetBufferView`
  * Removed `name` and `description`
  * Removed `elementCount` and redefined `count` to mean the element count
* Updated `3DTILES_metadata` extension
  * Updated to draft version `1.0.0`
  * Updated schema definition. See notes above.
* Updated `EXT_feature_metadata` extension
  * Updated to draft version `1.0.0`
  * Updated schema definition. See notes above.
  * Updated property table definition. See notes above.
  * Removed `classes` dictionary. Classes and enums are now contained in the `schema` object.
  * Added `schema` and `schemaUri`. The schema object contains class and enum definitions. `schemaUri` refers to an external schema JSON file. `schema` and `schemaUri` are mutually exclusive.
  * Added optional `statistics` object which provides aggregate information about select properties within the model
  * Added `EXT_feature_metadata` extension to the [`EXT_mesh_gpu_instancing`](../EXT_mesh_gpu_instancing) extension for assigning metadata to instances
  * Removed `vertexStride` and `instanceStride`
  * Added `divisor` for incrementing feature IDs at fixed intervals, e.g. per-triangle or per-quad

### October 2021

* Added `3DTILES_bounding_volume_s2` extension (draft version `0.0.0`)
* Updated 3D Metadata Specification
  * Updated to draft version `2.0.0`
  * Removed raster encoding. Storing metadata in texture channels remains a valid implementation of this specification, but is not within the scope of this document.
  * Removed table layout from the JSON encoding; each entity is encoded as a single JSON object.
* Updated 3D Metadata Semantic Reference
  * Updated to draft version `2.0.0`
  * Reorganize document to distinguish general and 3D Tiles-specific semantics
  * Added clarification for units of distance and angles
  * Added `DESCRIPTION` semantic
  * Changed `TILE_HORIZON_OCCLUSION_POINT` and `CONTENT_HORIZON_OCCLUSION_POINT` type from `ARRAY` to `VEC3`
* Updated schema definition
  * Removed `optional` and added `required`. Properties are now assumed to be optional unless `required` is true.
  * Added `noData` for specifying a sentinel value that indicates missing data
  * Removed `default`
  * `NaN` and `Infinity` are now explicitly disallowed as property values
  * Added vector and matrix types: `VEC2`, `VEC3`, `VEC4`, `MAT2`, `MAT3`, `MAT4`
  * Refactored `type` and `componentType` to avoid overlap. Properties that store a single value now have a `type` of `SINGLE` and a `componentType` of the desired type (e.g. `type: "SINGLE", componentType: "UINT8"`)
  * Class IDs, enum IDs, and property IDs must now contain only alphanumeric and underscore characters
  * Add `name` and `description` to schema, class, and enum definitions
  * Add `id` to schema definitions
* Updated property table definition
  * Split `offsetType` into `arrayOffsetType` and `stringOffsetType`
  * Relaxed buffer view alignment to component size, rather than strict 8-byte boundaries
* Updated `3DTILES_metadata` extension
  * Updated to draft version `2.0.0`
  * Updated schema definition. See notes above.
  * Group IDs must now contain only alphanumeric and underscore characters
  * Removed incomplete styling section
  * Recommend `_*` prefix for application-specific summary statistics
  * Removed `name` and `description` from entity schemas. Entities should use properties with equivalent semantics instead.
* Updated `3DTILES_implicit_tiling` extension
  * Updated to draft version `1.0.0`
  * Updated property table definition. See notes above.
* Renamed `EXT_feature_metadata` to `EXT_mesh_features`, including the following updates:
  * Updated to draft version `2.0.0`
  * Updated schema definition. See notes above.
  * Updated property table definition. See notes above.
  * Renamed `constant` to `offset`, and `divisor` to `repeat`
  * Removed `statistics` property, to be considered as a future extension
  * Renamed `featureTable` to `propertyTable` and `featureTexture` to `propertyTexture`
  * Removed `featureIdAttributes` and `featureIdTextures`, replaced with `featureIds`
  * Primitives and nodes may now have feature IDs without associated property tables
  * Removed string ID references to property tables and textures, replaced with integer IDs
  * Feature ID values outside the range `[0, count - 1]` now indicate "no associated feature"
  * Byte offsets for buffer views in a GLB-stored BIN chunk are no longer different from the core glTF specification
  * Renamed `_FEATURE_ID_#` to `FEATURE_ID_#`
  * Clarified that nodes with GPU instancing cannot reference property textures
  * For GPU instance metadata, the `EXT_mesh_features` extension is now scoped to the `node` extensions instead of nesting inside the `EXT_mesh_gpu_instancing` extension.
  * Refactored the property texture schema so it is now a glTF `textureInfo` object. All property values must be packed into a single texture.
  * Property textures are now assumed to be in linear space, and must use nearest or linear filtering

### February 2022

* Updated 3D Metadata Specification
  * Updated to draft version `3.0.0`
  * TODO
* Updated 3D Metadata Semantic Reference
  * Updated to draft version `3.0.0`
  * `CONTENT_*` semantics should now be assigned to content metadata properties instead of tile metadata properties
  * Added `ATTRIBUTION_IDS` and `ATTRIBUTION_STRINGS` semantics for providing data attribution at multiple levels of granularity
* Updated schema definition
  * `type` is required and must be one of the following: `SCALAR`, `VEC2`, `VEC3`, `VEC4`, `MAT2`, `MAT3`, `MAT4`, `STRING`, `BOOLEAN`, `ENUM`
  * `componentType` is required for scalar, vector, and matrix types and must be one of the following: `INT8`, `UINT8`, `INT16`, `UINT16`, `INT32`, `UINT32`, `INT64`, `UINT64`, `FLOAT32`, `FLOAT64`
  * Arrays are now distinct from the type system
    * Removed `ARRAY` type and `componentCount` property. Added `count` and `hasFixedCount` properties to indicate whether a property is a single element, fixed-length array, or variable-length array.
    * To indicate that a property is a single element, `count` must be 1 and `hasFixedCount` must be true
    * To indicate that a property is a fixed-length array, `count` must be greater than 1 and `hasFixedCount` must be true
    * To indicate that a property is a variable-length array, `hasFixedCount` must be false and `count` may be omitted
    * Arrays of vectors and matrices are now supported
  * Added `offset` and `scale` which are used to transform property values into a different range. Useful for quantized property values.
  * Added back `default`
  * Schema `id` property is now required
* Updated property table definition
  * Renamed `bufferView` to `values`
  * Renamed `stringOffsetBufferView` to `stringOffsets`
  * Renamed `arrayOffsetBufferView` to `arrayOffsets`
  * Added `offset` and `scale` which are used to transform property values into a different range. When present, these override the class property's `offset` and `scale`.
  * Added `min` and `max` which store the minimum and maximum property values.
* Updated `3DTILES_metadata` extension
  * Updated to draft version `3.0.0`
  * Updated schema definition. See notes above.
  * Added content metadata. A content may specify its class and property values with the `3DTILES_metadata` content extension object.
  * Removed the implicit tiling `3DTILES_metadata` extension. Tile metadata is now provided by the `tileMetadata` subtree property.
* Updated `3DTILES_implicit_tiling` extension
  * Updated to draft version `2.0.0`
  * Updated property table definition. See notes above.
  * Changed `maximumLevel` to `availableLevels` for consistency with `subtreeLevels`. Note that `maximumLevel` is an index whereas `availableLevels` is a length: `availableLevels` is equivalent to `maximumLevel + 1`.
  * Content availability for multiple contents is now provided by the `contentAvailability` property instead of a separate `3DTILES_multiple_contents` extension. `contentAvailability` is now an array of availability objects.
  * Tile metadata is now provided by the `tileMetadata` property instead of a separate `3DTILES_metadata` extension. `tileMetadata` is a property table containing metadata about available tiles.
  * Content metadata is now provided by the `contentMetadata` property. Each array element is a property table containing metadata about available content.
  * Subtree metadata is now provided by the `subtreeMetadata` object. Subtree metadata is encoded in JSON, similar to tileset metadata.
  * Renamed availability `bufferView` to `bitstream`
  * Added JSON subtree format as an alternative to the binary subtree format
* Updated `3DTILES_multiple_contents` extension
  * Updated to draft version `1.0.0`
  * Removed the implicit tiling `3DTILES_multiple_contents` extension. Content availability for multiple contents is now provided by the `contentAvailability` subtree property.
* Split the `EXT_mesh_features` extension into three separate extensions:
  * `EXT_mesh_features` that only defines the concept of feature IDs
  * `EXT_structural_metadata` that allows associating the features with metadata
  * `EXT_instance_features` that supports GPU instance feature IDs.
* Updated `EXT_mesh_features` extension
  * Updated to draft version `3.0.0`
  * Removed the "Implicit Feature IDs" concept. There have not been enough practical use-cases that could justify including them.
  * Renamed `FEATURE_ID_#` back to `_FEATURE_ID_#`: The underscore is required for custom attributes, according to the glTF specification, and without it, the assets do not pass validation.
  * The `featureIds` and the `propertyTables` had been stored as parallel arrays, and the connection between them had been established _implicitly_, by them appearing at the same index in their respective array. Now, the `featureIds` are a dictionary, where each value can _explicitly_ contain `propertyTable`, which is the index of the property table that it refers to. Each key in the dictionary is the set ID.
  * Instead of having dedicated classes for "Attribute Feature IDs" and "Texture Feature IDs", there is one common "Feature ID" class that either stores the `attribute` or the `texture`, respectively.
  * Added `featureId.nullFeatureId`, which can be used as a value indicating that a certain element is not associated with a feature ID.
  * Added `featureId.featureCount`, which is the number of distinct, non-`null` feature ID values.
  * Changed the `channel` for feature ID textures to be a `channels` array, so that multiple channels can be combined into one feature ID, allowing for more than 256 feature ID values in feature ID textures.
* Added `EXT_structural_metadata` extension (draft version `0.0.0`)
  * Updated property table definition. See notes above.
  * Update schema definition. See notes above.
  * Updated property texture definition
    * Properties are no longer required to be packed into the same texture. The number of class properties is no longer constrained by the number of texture channels.
    * Each item in the `properties` dictionary is now a `textureInfo` object
    * Added `offset` and `scale` which are used to transform property values into a different range. When present, these override the class property's `offset` and `scale`.
    * Added `min` and `max` which store the minimum and maximum property values in the texture.
  * Added `propertyAttributes`, and additional metadata encoding for vertex data, in particular point clouds
* Added `EXT_instance_features` extension (draft version `0.0.0`)
  * TODO