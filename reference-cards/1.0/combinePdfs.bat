@Echo off

cd output

echo Combining...
pdftk *.pdf cat output ../3d-tiles-reference-card.pdf
echo Combining DONE

cd ..
