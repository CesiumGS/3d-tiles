@Echo off

cd output

echo Combining...
pdftk *.pdf cat output ../3d-tiles-reference-card-1.1.pdf
echo Combining DONE

cd ..
