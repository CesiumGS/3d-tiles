
# Building the specification 

**NOTE**: Right now, these are internal notes. When the transition to AsciiDoc is Done®, this should describe the minimal process that is necessary to create the HTML and PDF outputs from a freshly cloned repository.

---

## Asciidoctor setup

- Install the Ruby interpreter, 2.3 or later, from http://www.ruby-lang.org/
- Install Asciidoctor: `gem install asciidoctor`
- In order to be able to generate PDF output: `gem install asciidoctor-pdf`
- Install some rogue software: `gem install rouge` - no worries, that's the syntax highlighter...
- In order go create compressed PDF files:
  - Install ghostscript from https://www.ghostscript.com/
  - Install the Ruby ghostscript gem: `gem install rghost`

- A VSCode plugin for AsciiDoc syntax highlighting and preview: https://marketplace.visualstudio.com/items?itemName=asciidoctor.asciidoctor-vscode

## Generating HTML and PDF with AsciiDoc

- Generating HTML:
  - `asciidoctor Specification.adoc -o Specification-1.1.0.html`
- Generating PDF:
  - `asciidoctor-pdf -a scripts=cjk -a pdf-theme=default-with-fallback-font Specification.adoc -o Specification-1.1.0.pdf`
  
- Note: The last call is derived from https://asciidoctor.org/docs/asciidoctor-pdf/#support-for-non-latin-languages and handles Japanese characters. Without them, the call could just be `asciidoctor -r asciidoctor-pdf -b pdf Specification.adoc -o Specification-1.1.0.pdf`

- Note: If the call does not appear to do anything, neither generate a PDF nor print an error message, make sure you typed `asciidoctor` and not just `asciidoc`

- Optimizing the resulting PDF:
  - On windows, call 
  
    `set GS=C:\Program Files\gs\gs9.56.1\bin\gswin64.exe`
  - Afterwards, call
   
    `asciidoctor-pdf-optimize --quality screen Specification-1.1.0.pdf`  

    (this will overwrite the given file!)

   Afterwards, the links will not work. See https://bugs.ghostscript.com/show_bug.cgi?id=699830 and the linked ones.

---

## Generating AsciiDoc from Markdown

The following are some notes for the process of converting the original markdown into AsciiDoc. 

The bulk work of generating a first version of the AsciiDoc specification can be done by auto-converting the existing Markdown files to AsciiDoc with a tool called 'kramdown':

- Install the Ruby interpreter, 2.3 or later, from http://www.ruby-lang.org/
- Install kramdown: `gem install kramdown`
- Convert a single Markdown file `kramdoc -o Specification.adoc README.md`


### Basic steps for the 3D Tiles specification:

- In the input `README.md`:
  - Remove any appearance of `<sup>` tags. They seem to confuse kramdoc.

- In the output `Specification.adoc`:
  - Remove all appearances of `// omit in toc`. In AsciiDoc, a section can be prevented from showing up in the TOC by prefixing it with a line that just contains `[discrete]`
  - Replace appearances of `&mdash;` with ` -- `
  - Replace appearances of `&pi;` with `π`
  - Replace that clever GitHub-specific image selection from
    ```
    image:../figures/3DTiles_light_color_small.png#gh-dark-mode-only[]
    image:../figures/3DTiles_dark_color_small.png#gh-light-mode-only[]
    ```
    with
    ```
    image:../figures/3DTiles_dark_color_small.png[]
    ```
- In all images that appear in tables, like
  `image:figures/replacement_1.jpg[]`,
  insert a sensible width for the table cell, like
  `image:figures/replacement_1.jpg[pdfwidth=1.5in]`
  or try to find another workaround. See https://github.com/asciidoctor/asciidoctor-pdf/issues/830#issuecomment-568169214 


### Section IDs

The automatic naming for `#anchors` based on section titles is different for Markdown and AsciiDoc. While the latter _can_ be configured to some extent, this would still cause problems when generating a single HTML document. While an anchor may be something like `#overview` _locally_ (in the single `.adoc` file viewn on GitHub), the name may be `#overview_7` when creating a single HTML document. Therefore, unique identifiers for the sections have been inserted. These identifiers follow the pattern

_`<directoryName>`_ `-` _`<markdownAnchor>`_

where `directoryName` is the full directory name in lowercase (with subdirectories separated by `-`), and `markdownAnchor` is the section title as a markdown anchor. For example, the section

`./Metadata/ReferenceImplementation/README.md -> == Overview`

received the ID 

`[#metadata-semantics-overview]`


### Cross-linking between files 

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






---

## For this Makefile approach

- Install https://chocolatey.org/install
- Install `make` in PowerShell (with Administrator rights): `choco install make`
- Have a flashback to the 90's, where hand-written Makefiles had been a thing
- Remember the quote from the Asciidoctor documentation page: 
  > Imagine if writing documentation was as simple as writing an email. It **can** be. 
- Consider using the docker container from https://github.com/KhronosGroup/Vulkan-Docs/blob/15d807ce4839d8feb523ca5c133a42a2aa448ade/BUILD.adoc , **iff** this works and makes sense for non-Khronos documentation...

---

## Internal notes

For wetzel, use commit d7707c7e315abc78eb231d67fd4fe0fcaa3e7576