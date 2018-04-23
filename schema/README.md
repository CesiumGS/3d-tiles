# 3D Tiles JSON Schema

Parts of 3D Tiles, such as [tileset.json](../README.md#tileset-json-files), [Feature Table](../TileFormats/FeatureTable/README.md), and [Batch Table](../TileFormats/BatchTable/README.md), are represented with JSON.  The JSON schema is defined using [JSON Schema](http://json-schema.org/) draft v4 in schema subdirectories.

## Usage

A JSON object can be validated against the schema using a JSON schema validator such as [Ajv: Another JSON Schema Validator](https://github.com/epoberezkin/ajv), which supports JSON Schema draft v4.  A command-line tool is available on npm as [ajv-cli](https://www.npmjs.com/package/ajv-cli).

Validating against the schema does not prove full compliance with the 3D Tiles specification since not all requirements can be represented with JSON schema.  For full compliance validation, see [3d-tiles-tools](https://github.com/AnalyticalGraphicsInc/3d-tiles-tools/).

### Example

1. Install : `npm install ajv-cli -g`
2. Validate : `ajv -s schema/i3dm.featureTable.schema.json -r schema/featureTable.schema.json -d examples/i3dm.featureTable.json`

* The `-s` flag points to the schema you want to use for validation. 
* Multiple `-r` flags includes any external dependencies for the schema.
* The `-d` flag points to the JSON to validate.
