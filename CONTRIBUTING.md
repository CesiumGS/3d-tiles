## Generating the Specification PDF

To add any schema or markdown updates to the 3D Tiles Specification PDF, take the following steps:

1. Generate markdown property references from the schema.
    * Run the [wetzel](https://github.com/AnalyticalGraphicsInc/wetzel) tool on the schema to generate markdown property reference on the schemas in the `specification/schema` directory.
    * Paste the generated markdown in the corresponding section of `specification/README.md` or the `specification/TileFormats/<TILE_FORMAT>/README.md`.

1. Generate a `.docx` file for each section.
    * Run [pandoc](https://pandoc.org/demos.html) to generate a formatted `.docx` file from markdown. Run the following command in the directory that contains the input file to preserve images.
        * `pandoc ./README.md -o README.docx -f github_markdown`
    * Generate a `.docx` each of the following files:
        * `specification/README.md`
        * `specification/TileFormats/BatchTable/README.md`
        * `specification/TileFormats/FeatureTable/README.md`
        * Each tile format type `README.md` (the remainfing directories in `specification/TileFormats/`)

1. Update, save, and commit changes to `specification/specification.docx`.
    * Copy the formatted content generated in the previous step into the relevant sections of `specification/specification.docx`, with each of Tile Formats listed in the "Tile Formats" section. Headers should match the proper level, and can be edited in "Outline View".
    * Update formatting where needed, especially images and tables. Images should be captioned by adding "Insert Caption".  Check internal links.
    * Update any dates, version numbers, or document numbers.
    * Add a row to the table in "Annex C: Revision History" with the date, your name, and any relevant details.
    * Regenerate the "Table of Contents" and "Table of Figures".

1. Generate the `specification/specification.pdf` file from `specification/specification.docx` and commit the change.

## 3D Tiles Format Spec Writing Guide

As we add more tile formats, 3D Tiles needs to stay consistent.

### Terminology

* Tiles are composed of `sections` such as `header` and `body`.  Sections are composed of `fields` such as `magic` and `version`.
* "Feature" - indicates one model in a batch of models (`b3dm`), one instance in a collection of instances (`i3dm`), one point in a point cloud (`pnts`), etc.

#### Fields

* Field names are in camelCase.
* `Length` - a `Length` suffix on a field name indicates the number of elements in an array.
* `ByteLength` - a `ByteLength` suffix indicates the number of bytes, not to be confused with just `Length`.

### Header

* Each tile format starts with a header that starts with the following fields:
```
magic            // uchar[4], indicates the tile format
version          // uint32,   1
byteLength       // uint32,   length, in bytes, of the entire tile.
```

### Binary

* All binary data, e.g., tile formats, are in little endian.

## Code of Conduct

To ensure an inclusive community, contributors and users in the Cesium community should follow the [code of conduct](./CODE_OF_CONDUCT.md).
