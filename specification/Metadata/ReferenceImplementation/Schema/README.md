# Schema Implementation

The [3D Metadata Specification](../../README.md) defines [schemas](../../README.md#schemas) as a description of the structure of metadata, consisting of classes with different properties, and enum types. The following is the description of a JSON-based representation of such a schema and its elements. It is used as the basis for defining the metadata structure in the following implementations:

* [3D Tiles Metadata](TODO) - Assigns metadata to tilesets, tiles, groups, and contents in a 3D Tiles tileset. The schema is associated with the tileset. Instances of these classes - referred to as metadata entities - can be associated with elements of the tileset on each granularity level. 
* [`EXT_structural_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_structural_metadata) — Assigns metadata to vertices, texels, and features in a glTF asset. The schema is stored in the top-level extension object. Mesh primitives can be associated with instances of the metadata classes. 

The full JSON schema definition for this implementation can be found in [the Schema directory of the specification](../../../schema/Schema/).

### Schema

*Defined in [schema.schema.json](../../../schema/Schema/schema.schema.json).*

A schema defines a set of classes and enums. Classes serve as templates for entities. They provide a list of properties and the type information for those properties. Enums define the allowable values for enum properties. 

> **Example:** Schema with a `tree` class, and a `speciesEnum` enum that defines different species of trees. Later examples show how these structures in more detail. 
>
> ```jsonc
> {
>   "schema": {
>     "classes": {
>       "tree": { ... },
>     "enums": {
>       "speciesEnum": { ... } 
>     }
>   }
> }
> ```

### Class

*Defined in [class.schema.json](../../../schema/Schema/class.schema.json).*

A class is a template for metadata entities. Classes provide a list of property definitions. Every entity must be associated with a class, and the entity's properties must conform to the class's property definitions. Entities whose properties conform to a class are considered instances of that class.

Classes are defined as entries in the `schema.classes` dictionary, indexed by class ID. Class IDs must be [identifiers](../../README.md#identifiers) as defined in the 3D Metadata Specification.

> **Example:** A "Tree" class, which might describe a table of tree measurements taken in a park. Property definitions are abbreviated here, and introduced in the next section.
>
> ```jsonc
> {
>   "schema": {
>     "classes": {
>       "tree": {
>         "name": "Tree",
>         "description": "Woody, perennial plant.",
>         "properties": {
>           "species": { ... },
>           "age": { ... },
>           "height": { ... },
>           "diameter": { ... }
>         }
>       }
>     }
>   }
> }
> ```

### Class Property

*Defined in [class.property.schema.json](../../../schema/Schema/class.property.schema.json).*

Class properties are defined abstractly in a class. The class is instantiated with specific values conforming to these properties. Class properties support a rich variety of data types. Details about the supported types can be found in the [3D Metadata Specification](../../README.md#property).

Class properties are defined as entries in the `class.properties` dictionary, indexed by property ID. Property IDs must be [identifiers](../../README.md#identifiers) as defined in the 3D Metadata Specification.

> **Example:** A "Tree" class, which might describe a table of tree measurements taken in a park. Properties include species, age, height, and diameter of each tree.
>
> ```jsonc
> {
>   "schema": {
>     "classes": {
>       "tree": {
>         "name": "Tree",
>         "description": "Woody, perennial plant.",
>         "properties": {
>           "species": {
>             "description": "Type of tree.",
>             "type": "ENUM",
>             "enumType": "speciesEnum",
>             "required": true
>           },
>           "age": {
>             "description": "The age of the tree, in years",
>             "type": "SCALAR",
>             "componentType": "UINT8",
>             "required": true
>           },
>           "height": {
>             "description": "Height of tree measured from ground level, in meters.",
>             "type": "SCALAR",
>             "componentType": "FLOAT32"
>           },
>           "diameter": {
>             "description": "Diameter at trunk base, in meters.",
>             "type": "SCALAR",
>             "componentType": "FLOAT32"
>           }
>         }
>       }
>     }
>   }
> }
> ```

### Enum

*Defined in [enum.schema.json](../../../schema/Schema/enum.schema.json).*

A set of categorical types, defined as `(name, value)` pairs. Enum properties use an enum as their type.

Enums are defined as entries in the `schema.enums` dictionary, indexed by an enum ID. Enum IDs must be [identifiers](../../README.md#identifiers) as defined in the 3D Metadata Specification.

> **Example:** A "Species" enum defining types of trees. An "Unspecified" enum value is optional, but when provided as the `noData` value for a property (see: [3D Metadata → No Data Values](../../README.md#required-properties-no-data-values-and-default-values)) may be helpful to identify missing data.
>
> ```jsonc
> {
>   "schema": {
>     "enums": {
>       "speciesEnum": {
>         "name": "Species",
>         "description": "An example enum for tree species.",
>         "values": [
>           {"name": "Unspecified", "value": 0},
>           {"name": "Oak", "value": 1},
>           {"name": "Pine", "value": 2},
>           {"name": "Maple", "value": 3}
>         ]
>       }
>     }
>   }
> }
> ```

### Enum Value

*Defined in [enum.value.schema.json](../../../schema/Schema/enum.value.schema.json).*

Pairs of `(name, value)` entries representing possible values of an enum property.

Enum values are defined as entries in the `enum.values` array. Duplicate names or duplicate integer values are not allowed.

