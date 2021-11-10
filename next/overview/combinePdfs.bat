@Echo off

cd output

echo Combining...
pdftk *.pdf cat output ../3d-tiles-next-overview.pdf
echo Combining DONE

cd ..
