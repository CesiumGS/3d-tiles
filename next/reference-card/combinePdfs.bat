@Echo off

cd output

echo Combining...
pdftk *.pdf cat output ../3d-tiles-next-reference-card.pdf
echo Combining DONE

cd ..
