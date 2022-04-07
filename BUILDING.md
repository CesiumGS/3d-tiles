
### Building the specification 

**NOTE**: Right now, these are internal notes. When the transition to AsciiDoc is Done®, this should describe the minimal process that is necessary to create the HTML and PDF outputs from a freshly cloned repository.

---

### Asciidoctor setup

- Install the Ruby interpreter, 2.3 or later, from http://www.ruby-lang.org/
- Install Asciidoctor: `gem install asciidoctor`
- In order to be able to generate PDF output: `gem install asciidoctor-pdf`
- A VSCode plugin for AsciiDoc syntax highlighting and preview: https://marketplace.visualstudio.com/items?itemName=asciidoctor.asciidoctor-vscode


### Generating AsciiDoc from Markdown

The bulk work of generating a first version of the AsciiDoc specification can be done by auto-converting the existing Markdown files to AsciiDoc with a tool called 'kramdown':

- Install the Ruby interpreter, 2.3 or later, from http://www.ruby-lang.org/
- Install kramdown: `gem install kramdown`
- Convert a single Markdown file `kramdoc -o Specification.adoc README.md`


#### Steps for the 3D Tiles specification:

- In the input `README.md`:
  - Remove any appearance of `<sup>` tags. They seem to confuse kramdoc.

- In the output `Specification.adoc`:
  - Remove all appearances of `// omit in toc` 
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
  `image:figures/replacement_1.jpg[pdfwidth=40%]`
  or try to find another workaround. See https://github.com/asciidoctor/asciidoctor-pdf/issues/830#issuecomment-568169214 

### Generating HTML and PDF with AsciiDoc

- Generating HTML:
  - `asciidoctor Specification.adoc -o Specification-1.1.0.html`
- Generating PDF:
  - `asciidoctor -r asciidoctor-pdf -b pdf Specification.adoc -o Specification-1.1.0.pdf`

- Note: If the call does not appear to do anything, neither generate a PDF nor print an error message, make sure you typed `asciidoctor` and not just `asciidoc` - the latter seems to be some outdated Python version of some AsciiDoc processor or so, whatever...

---

### For this Makefile approach

- Install https://chocolatey.org/install
- Install `make` in PowerShell (with Administrator rights): `choco install make`
- Have a flashback to the 90's, where hand-written Makefiles had been a thing
- Remember the quote from the Asciidoctor documentation page: 
  > Imagine if writing documentation was as simple as writing an email. It **can** be. 
- Consider using the docker container from https://github.com/KhronosGroup/Vulkan-Docs/blob/15d807ce4839d8feb523ca5c133a42a2aa448ade/BUILD.adoc , **iff** this works and makes sense for non-Khronos documentation...

