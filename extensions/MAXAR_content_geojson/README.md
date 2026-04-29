# MAXAR_content_geojson 

## Contributors

* Björn Blissing, Maxar, [@bjornblissing](https://github.com/bjornblissing)
* Erik Dahlström, Maxar, [@erikdahlstrom](https://github.com/erikdahlstrom)

## Status

**Version 1.0.0**, June 30, 2025

## Dependencies

Written against the 3D Tiles 1.1 spec.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Schema](#schema)
  - [Property Metadata](#property-metadata)
  - [Examples](#examples)
  - [Properties Schema Structure](#properties-schema-structure)
  - [Validation Rules](#validation-rules)
  - [Example Properties Schema](#example-properties-schema)
  - [Implementation Notes](#implementation-notes)
  - [Limitations](#limitations)
  - [File Structure](#file-structure)

## Overview

This extension allows a tileset to use [GeoJSON](https://tools.ietf.org/html/rfc7946) directly as tile content.

It also allows for specifying an external schema to help interpret the feature properties stored in the GeoJSON layer.
This schema can be marked with a high-level semantic identifier that defines the meaning of the properties. Recommended best practice is to select a value from a controlled vocabulary or formal classification scheme.

Each field in the schema can also be marked with a semantic identifier that describes how this property should be interpreted.

## Optional vs. Required

This extension is required; it must appear in the tileset JSON top-level `extensionsRequired` and `extensionsUsed` lists.

## Schema

This extension modifies the 3D Tiles schema by enabling GeoJSON content and adding a new property to the `metadataEntity` type:

- **Tileset Schema**: [`schema/tileset.MAXAR_content_geojson.schema.json`](schema/tileset.MAXAR_content_geojson.schema.json)
- **Metadata Entity Schema**: [`schema/metadataEntity.MAXAR_content_geojson.schema.json`](schema/metadataEntity.MAXAR_content_geojson.schema.json)
- **Properties Schema**: [`schema/geojsonproperties.schema.json`](schema/geojsonproperties.schema.json)

The extension adds the following property to `metadataEntity`:

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `propertiesSchemaUri` | `string` | URI reference to an external properties metadata schema file | No |

The `propertiesSchemaUri` property allows referencing an external schema that describes the structure and validation rules for properties found in GeoJSON features within the tile content.

## Property Metadata

The extension can be used to add a `propertiesSchemaUri` property to the `metadataEntity` type. This allows referencing an external properties metadata schema that specifies the content of the GeoJSON layer. It can be used either directly in the tileset metadata object or per group (since `groups` is an array of `metadataEntity` objects).

The properties schema applies to the content in the entire tree following the same inheritance rules as all other 3D Tiles metadata. When specified at the tileset level in the metadata object, the schema applies to all GeoJSON content in the tileset. When specified per group, the schema applies only to tiles that reference that specific group. Group-level schemas override tileset-level schemas for tiles within that group's scope.

The use of the property metadata schema has the following restrictions:
 - Only one geometry type (`Point`, `LineString`, `Polygon`, `MultiPoint`, `MultiLineString`, `MultiPolygon`) is allowed per GeoJSON layer.
 - The referenced GeoJSON layer cannot contain `GeometryCollection` objects.

## Examples

**Usage without optional properties schema:**

```json
{
  "asset": {
    "version": "1.1"
  },
  "extensions": {
    "MAXAR_content_geojson": {}
  },
  "extensionsRequired": [
    "MAXAR_content_geojson"
  ],
  "extensionsUsed": [
    "MAXAR_content_geojson"
  ],
  "geometricError": 0,
  "root": {
    "boundingVolume": {
      "region": [
        -1.7095238193613294,
        0.54322210241748092,
        -1.7084717202817712,
        0.54416527589988806,
        243.45309697370976,
        360.09079237561673
      ]
    },
    "geometricError": 0,
    "refine": "REPLACE",
    "content": {
      "uri": "vegetation_tile.geojson"
    }
  }
}
```

**Usage *with* optional properties metadata schema:**

```json
{
  "asset": {
    "version": "1.1"
  },
  "extensions": {
    "MAXAR_content_geojson": {}
  },
  "extensionsRequired": [
    "MAXAR_content_geojson"
  ],
  "extensionsUsed": [
    "MAXAR_content_geojson"
  ],
  "metadata": {
    "class": "tileset",
    "properties": {
      "content_type": "VECTOR",
      "geometry_model": "OBJECTS",
      "name": "Vegetation Layer",
      "schema": "wff/15",
      "wff_version": "1.5"
    },
    "extensions": {
      "MAXAR_content_geojson": {
        "propertiesSchemaUri": "vegetation_schema.json"
      }
    }
  },
  "geometricError": 0,
  "root": {
    "boundingVolume": {
      "region": [
        -1.7095238193613294,
        0.54322210241748092,
        -1.7084717202817712,
        0.54416527589988806,
        243.45309697370976,
        360.09079237561673
      ]
    },
    "geometricError": 0,
    "refine": "REPLACE",
    "content": {
      "uri": "vegetation_tile.geojson"
    }
  }
}
```


## Properties Schema Structure

The external properties metadata schema defines the structure and validation rules for GeoJSON Feature properties. The schema consists of three main sections:

### Root Level Properties

- **`name`** (optional): Human-readable name for the properties schema
- **`semantic`** (required): High-level identifier defining the meaning of the properties (recommended to use controlled vocabulary)
- **`geometry`** (required): Describes the expected GeoJSON geometry type and dimensions
- **`properties`** (required): Array of property definitions corresponding to GeoJSON Feature properties

### Geometry Object

The geometry object specifies constraints on the GeoJSON geometry:

- **`type`** (required): Must be one of: `"Point"`, `"LineString"`, `"Polygon"`, `"MultiPoint"`, `"MultiLineString"`, `"MultiPolygon"`
- **`dimensions`** (required): Integer value of `2` (2D) or `3` (3D)

### Property Definitions

Each property in the `properties` array describes a field that may appear in GeoJSON Feature objects:

#### Required Fields
- **`id`** (string): Unique identifier corresponding to the property name in GeoJSON Feature's 'properties' object
- **`type`** (string): Expected datatype - one of `"Integer"`, `"Float"`, `"String"`, `"Boolean"`, `"Variant"`
  - `"Variant"` type can hold any data type including `null` values

#### Optional Fields
- **`description`** (string): Human-readable description of the property
- **`unit`** (string): Unit of measurement for the property value
- **`min`** (number): Minimum allowed value (only for Integer/Float types)
- **`max`** (number): Maximum allowed value (only for Integer/Float types)
- **`required`** (boolean): Whether the property must be present in every GeoJSON Feature (default: false)
- **`default`** (number/string/boolean): Default value when property is missing from GeoJSON Feature
- **`semantic`** (string): Identifier describing how the property should be interpreted (must be unique within the schema)

## Validation Rules

The schema enforces several validation constraints:

### Type-Specific Constraints
- **Numeric constraints** (`min`/`max`): Only allowed for `Integer` and `Float` types
- **Range validation**: When both `min` and `max` are specified, `max` must be ≥ `min`

### Required vs Default Value Rules
- **Required properties**: If a property is required (`required: true`), the property must always be present and not `null`. Default values are redundant and should not be set when `required` is `true`
- **Optional properties**: If a property is not required (`required: false` or omitted), the behavior depends on whether a default value is specified:
  - **Without default value**: Missing properties will be read as `null` values
  - **With default value**: The specified default value will be used instead of `null` when the property is missing
- **Variant type properties**: Do not support default values and will default to `null` when missing
- **String properties**: Can use empty string `""` as a default value, which is distinct from `null`

### Default Value Type Matching
- **Integer/Float**: Default values must be numbers
- **String**: Default values must be strings
- **Boolean**: Default values must be boolean (`true` or `false`)

### Uniqueness Constraints
- **Property IDs**: Must be unique within the properties array
- **Semantic values**: Must be unique within the properties array when specified

## Example Properties Schema

```json
{
  "name": "Vegetation Properties Schema",
  "semantic": "vegetation",
  "geometry": {
    "type": "Polygon",
    "dimensions": 2
  },
  "properties": [{
      "id": "areaId",
      "type": "Integer",
      "required": true,
      "description": "Unique identifier for the vegetation area"
    }, {
      "id": "vegetationType",
      "type": "String",
      "default": "UNDEFINED",
      "description": "Classification of vegetation type"
    }, {
      "id": "propertyValue",
      "type": "Float",
      "unit": "USD",
      "min": 0,
      "default": 0.0,
      "description": "Estimated monetary value of the vegetation area"
    }
  ]
}
```

This example demonstrates:
- A required Integer property (`areaId`) with no default value
- An optional String property (`vegetationType`) with a default value
- An optional Float property (`propertyValue`) with numeric constraints, unit specification, and default value

## Implementation Notes

### Coordinate Systems
- GeoJSON coordinates must follow the [RFC 7946](https://tools.ietf.org/html/rfc7946) specification (WGS84 longitude/latitude)
- Height values (for 3D coordinates) are in meters above the WGS84 ellipsoid
- Ensure coordinate order is [longitude, latitude, height] as per the GeoJSON specification

### Schema Validation
- Properties schemas are validated against the [`geojsonproperties.schema.json`](schema/geojsonproperties.schema.json) schema
- Use JSON Schema validators to verify schema compliance during development
- Invalid schemas will cause tile loading failures in compliant clients

## Limitations

This extension has the following limitations:

- **Geometry Restriction**: Only one geometry type per GeoJSON layer (no mixed Point/Polygon in same file)
- **No GeometryCollection**: `GeometryCollection` geometries are not supported
- **FeatureCollection Recommended**: While "bare" GeoJSON files (single Feature or Geometry objects) are valid according to a strict interpretation of the GeoJSON standard, they are discouraged since most GeoJSON consumers expect features to be inside a `FeatureCollection`
- **Schema Inheritance**: Properties schemas follow 3D Tiles metadata inheritance rules (group-level overrides tileset-level)
- **Required Extensions**: This extension must be declared in both `extensionsUsed` and `extensionsRequired`
- **3D Tiles Version**: Requires 3D Tiles 1.1 or later for metadata support

### Schema Files
- **`tileset.MAXAR_content_geojson.schema.json`**: Defines the extension declaration at the tileset level to enable GeoJSON content loading
- **`metadataEntity.MAXAR_content_geojson.schema.json`**: Defines the extension properties that can be added to 3D Tiles metadata entities
- **`geojsonproperties.schema.json`**: Defines the structure and validation rules for external properties metadata schema files