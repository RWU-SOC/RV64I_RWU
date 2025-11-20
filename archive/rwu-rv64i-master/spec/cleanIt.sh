#!/bin/sh
echo "Deleting all Latex temporaries!"
pwd
pathx=pwd
echo $pathx
rm -f ./*.gz
rm -f ./*.snm
rm -f ./*.out
rm -f ./*.log
rm -f ./*.aux
rm -f ./*.nav
rm -f ./*.toc
rm -f ./*.bbl
rm -f ./*.blg
rm -f ./*.xml
rm -f ./*.bcf
rm -f ./*.lof
rm -f ./*.lot
