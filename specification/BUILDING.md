<!-- omit in toc -->
# Build instructions

- [Building the specification](#building-the-specification)
  - [Asciidoctor setup](#asciidoctor-setup)
  - [Generating HTML and PDF with AsciiDoc](#generating-html-and-pdf-with-asciidoc)
  - [Compressing the PDF](#compressing-the-pdf)
- [A note about section IDs](#a-note-about-section-ids)
- [Cross-linking between files](#cross-linking-between-files)

## Building the specification 

The following is a short summary of the basic process for generating a single HTML- or PDF file containing the whole specification.

> Note: This process might be extended in the future, with details about how [wetzel](https://github.com/CesiumGS/wetzel) is used to generate the property reference. Depending on the exact process, the required toolchain might be summarized in a Docker container, similar to [Vulkan](https://github.com/KhronosGroup/Vulkan-Docs/blob/15d807ce4839d8feb523ca5c133a42a2aa448ade/BUILD.adoc), and controlled via a Makefile.

### Asciidoctor setup

- Install the Ruby interpreter, 2.3 or later, from http://www.ruby-lang.org/
- Install Asciidoctor: `gem install asciidoctor`
- In order to be able to generate PDF output: `gem install asciidoctor-pdf`
- Install some rogue software: `gem install rouge` - no worries, that's the syntax highlighter...

- A VSCode plugin for AsciiDoc syntax highlighting and preview: https://marketplace.visualstudio.com/items?itemName=asciidoctor.asciidoctor-vscode

### Generating HTML and PDF with AsciiDoc

- Generating HTML:
  - `asciidoctor --verbose Specification.adoc --out-file Specification-1.1.0.html`
- Generating PDF:
  - `asciidoctor-pdf --verbose --trace --attribute scripts=cjk --attribute pdf-theme=default-with-fallback-font Specification.adoc --out-file Specification-1.1.0.pdf`
  
    > Note: The last call is derived from https://asciidoctor.org/docs/asciidoctor-pdf/#support-for-non-latin-languages and handles Japanese characters. Without them, the call could just be `asciidoctor -r asciidoctor-pdf -b pdf Specification.adoc -o Specification-1.1.0.pdf`

<sup>If the call does not appear to do anything, neither generate a PDF nor print an error message, make sure you typed `asciidoctor` and not just `asciidoc`</sup>


### Compressing the PDF

By default, the PDF file is large, due to the large image files being inserted uncompressed. There are tools for compressing the PDF, including a dedicated `asciidoctor-pdf-optimize` tool, but they have caveats. 

The process that worked for me:

- Download GhostScript **not later than 9.20** from https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/tag/gs920  
  - This is the latest version that did not contain the so-called ""bugfix"" from https://bugs.ghostscript.com/show_bug.cgi?id=699830 that apparently caused more harm than good.
     
  - Run the following command: 
    ```
    "C:\Program Files\gs\gs9.20\bin\gswin64.exe" ^
      -dPrinted=false ^
      -sDEVICE=pdfwrite ^
      -dCompatibilityLevel=1.4 ^
      -dPDFSETTINGS=/ebook ^
      -dNOPAUSE ^
      -dBATCH ^
      -dDetectDuplicateImages ^
      -sOutputFile=Specification-1.1.0-compressed.pdf ^
      Specification-1.1.0.pdf   
    ```
    (This is a Windows .BAT file. On Linux, replace the `^` with `\`)

The main tweaking takes place via the `dPDFSETTINGS` parameter. The value can be `screen`, `ebook`, `printer`, or `prepress`. The exact effects of these parameters are summarized at https://www.ghostscript.com/doc/9.54.0/VectorDevices.htm#distillerparams


## A note about section IDs

The automatic naming for `#anchors` based on section titles is different for Markdown and AsciiDoc. While the latter _can_ be configured to some extent, this would still cause problems when generating a single HTML document. While an anchor may be something like `#overview` _locally_ (in the single `.adoc` file viewn on GitHub), the name may be `#overview_7` when creating a single HTML document. Therefore, unique identifiers for the sections have been inserted. These identifiers follow the pattern

_`<directoryName>`_ `-` _`<markdownAnchor>`_

where `directoryName` is the full directory name in lowercase (with subdirectories separated by `-`), and `markdownAnchor` is the section title as a markdown anchor. For example, the section

`./Metadata/ReferenceImplementation/README.md -> == Overview`

received the ID 

`[#metadata-referenceimplementation-overview]`


## Cross-linking between files 

Two `adoc` files that are contained in sibling directories cannot trivially link to each other. When there are two files

    \ImplicitTiling\README.adoc
    \Matadata\README.adoc

and they should link to each other, then it is not possible to write

    See xref:../Metadata/README.adoc#anchor[Metadata]

in the first one. (See https://github.com/asciidoctor/asciidoctor/issues/650, https://github.com/asciidoctor/asciidoctor/issues/844, https://github.com/asciidoctor/asciidoctor/issues/3136, https://github.com/asciidoctor/asciidoctor/issues/3276 ...)

In order to create links between documents that work in GitHub **and** in the single HTML/PDF file, the following workaround can be used:

1. At the top of the `ImplicitTiling/README.adoc`, insert this:

    ```
    ifdef::env-github[]
    :url-specification-metadata: ../Metadata/
    endif::[]
    ifndef::env-github[]
    :url-specification-metadata:
    endif::[]
    ```

2. Then, use the following pattern for links:

    `See xref:{url-specification-metadata}README.adoc#anchor[An example]`

This will cause the _relative_ link to be used when the file is viewn on GitHub, and the "unqualified" link to be used inside the single HTML/PDF document. 
