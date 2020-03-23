# 3D Tiles Overview

[![](../figures/3d-tiles-overview-single-layout-8x3.jpg)](../3d-tiles-overview.pdf)

The [**3D Tiles Overview**](../3d-tiles-overview.pdf) is an approachable and concise guide to learning about the main concepts in 3D Tiles and designed to help integrate 3D Tiles into runtime engines for visualization and analysis of massive heterogeneous 3D geospatial content.

This guide augments the fully detailed 3D Tiles specification with coverage of key concepts to help developers jumpstart adopting 3D Tiles.

## Changelog

* 2020-03-12: Initial release of version 1.0

## Source

This directory contains the source files for generating the 3D Tiles reference card.

### Editing

The input files are SVG files, originally created with [Inkscape](https://inkscape.org/). They can be converted to PDF files either by opening them in Inkscape and saving them as PDF, or more conveniently, using the `convertAllToPdf.bat` batch file. The file uses the command-line functionality of Inkscape to convert each SVG file from the input directory into a PDF file, which is then written into the `/output` subdirectory.

The resulting PDF files can be combined with any PDF tool, for example [PDFtk Server](https://www.pdflabs.com/tools/pdftk-server/). The `combinePdfs.bat` batch file contains the call that combines all PDF files from the `/output` directory, and writes the result as into the base directory as `3d-tiles-overview.pdf`.

### Resources

The `/resources` subdirectory contains the images (screenshots and SVG versions of the logos) that are used in the overview. They are not necessary for creating the PDF files, but are added here for reference.

The file `/resources/3d-tiles-overview-tables.odt` is an [OpenDocument Text](https://en.wikipedia.org/wiki/OpenDocument) that can be edited with any standard office program. It contains most of the tables that are used in the overview. In order to change one of the tables, it is edited in the ODT file, exported as PDF, and imported into Inkscape. (Considering the limited support for tables in Inkscape, this still seemed to be the most simple approach here.)

## Acknowldgements

Thanks to [Marco Hutter](https://github.com/javagl), a long-time member of the glTF community, for designing the first version of the 3D Tiles Overview.
