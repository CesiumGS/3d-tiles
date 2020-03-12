@Echo off
set "inkscapePath=C:\Program Files\Inkscape\inkscape.exe"

md output

for %%f in (*.svg) do (
    echo Converting %%f to %%~nf.pdf ...
    "%inkscapePath%" --without-gui --file="%%f" --export-pdf="output\%%~nf.pdf" --export-dpi=90
    echo Converting %%f to %%~nf.pdf DONE
)

