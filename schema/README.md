# 3D Tiles JSON Schema

## Overview

3D Tiles JSON assets, like `tileset.json`, or the JSON header of a [Feature Table](../TileFormats/FeatureTable) have rules.
Those rules are expressed in human-readable form throughout the specification, but assets can also be verified using JSON Schema.

Every JSON asset in 3D Tiles has an accompanying schema document conforming to [JSON Schema](http://json-schema.org/) draft v4.

## Usage

For a JSON schema validator, we recommend [Ajv: Another JSON Schema Validator](https://github.com/epoberezkin/ajv). It is fast and has full draft v4 support.
A command line interface tool for node is available on [npm](https://www.npmjs.com/package/ajv-cli). 

### Example

1. Install : `npm install ajv-cli -g`
2. Validate : `ajv -s schema/i3dm.featureTable.schema.json -r schema/featureTable.schema.json -d examples/i3dm.featureTable.json`

The `-s` flag should point to the schema you want to use for validation. 
Multiple `-r` flags should be used to include any external dependencies for the schema.
The `-d` flag should point to the JSON you wish to validate.