@Echo off
set "inkscapePath=C:\Program Files\Inkscape\bin\inkscape.exe"

md output

for %%f in (*.svg) do (
    echo Converting %%f to %%~nf.pdf ...
    "%inkscapePath%" --export-filename="output\%%~nf.pdf" "%%f"
    echo Converting %%f to %%~nf.pdf DONE
)

