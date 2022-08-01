# 3D Tiles JSON Schema

Parts of 3D Tiles are represented with JSON. The JSON structure is defined using [JSON Schema](http://json-schema.org/) 2020-12 in schema subdirectories.

This directory contains the JSON schema definitions for different concepts. Some of the concepts are defined in subfolders, in order to modularize the schema and define clear dependencies. Dependencies in a JSON schema are established with the `$ref` keyword, and these references are assumed to be resolved against the respective subdirectories. 

- Root directory: The core concepts of 3D Tiles, including the definition of the [Tileset JSON](../README.adoc#tileset-json).

- [`Schema`](Schema) directory: A reference implementation of the Schema definition of the [3D Metadata Specification](../Metadata/README.adoc#schema). This is used by the Core 3D Tiles schema to define the structure of metadata for tilesets, tiles, groups, and content. And it is used by the glTF `EXT_structural_metadata` extension to define the structure of metadata in glTF assets.

- [`PropertyTable`](PropertyTable) directory: A reference implementation of a binary storage format of metadata property values according to the [3D Metadata Specification](../Metadata/README.adoc#storage-formats). This is used by [`Subtree`](Subtree) to define the binary storage of metadata in `.subtree` files, and by the glTF `EXT_structural_metadata` extension to define the binary storage of metadata in glTF assets.

- [`Statistics`](Statistics) directory: The JSON structure for statistics about metadata that appears in a 3D Tiles tileset. metadata in glTF assets.
  - *Depends on: 3D Tiles core schema* 

- [`Subtree`](Subtree) directory: The JSON part of a `.subtree` file that is used for implicit tiling in 3D Tiles.
  - *Depends on: [`PropertyTable`](PropertyTable), 3D Tiles core schema* 

- [`TileFormats`](TileFormats) directory: The JSON part of the [Feature Table](../TileFormats/FeatureTable/README.adoc) and [Batch Table](../TileFormats/BatchTable/README.adoc) for the different tile formats.
  - *Depends on: 3D Tiles core schema* 


The [common](common) directory contains common definitions that are used by all other JSON schemas, but have no dependency to any other schema.


## Usage

A JSON object can be validated against the schema using a JSON schema validator such as [Ajv JSON schema validator](https://github.com/ajv-validator/ajv), which supports JSON Schema 2020-12. A command-line tool is available on npm as [ajv-cli](https://www.npmjs.com/package/ajv-cli). Validating against the schema does not prove full compliance with the 3D Tiles specification since not all requirements can be represented with JSON schema.

