#!/bin/sh

for f in *.txt
   do
      python make_surface.py "$f"

      'ConvertPlyVtkSmooth' "${f/.txt}".ply "${f/.txt}".vtk

#rm "$f"
#rm "${f/.txt}".ply
done


