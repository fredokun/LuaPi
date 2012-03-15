#! /bin/bash

. ./VERSION

echo "Archiving version v${MAJOR}.${MINOR} ..."
echo "---------"

INFO_FILES="COPYRIGHT VERSION HISTORY AUTHORS README prepare.sh"
LIBRARY_DIR="lib"
LIBRARY_FILES="pithreads.lua utils.lua utils-tests.lua"

EXAMPLE_DIR="examples"
EXAMPLE_FILES=`ls ./examples`

TUTEX_DIR="examples/tutorial"
TUTEX_FILES=`ls ./examples/tutorial`

DOC_DIR="doc"
DOC_FILES="LuaPiTut.pdf"

ARCHIVE="LuaPi-v${MAJOR}.${MINOR}"

## do not edit past this line

echo mkdir $ARCHIVE
mkdir $ARCHIVE

for infofile in $INFO_FILES ;
do
  echo cp $infofile $ARCHIVE/ ;
  cp $infofile $ARCHIVE/ ;
done

echo mkdir $ARCHIVE/$LIBRARY_DIR
mkdir $ARCHIVE/$LIBRARY_DIR

for libfile in $LIBRARY_FILES ;
do
  echo cp $LIBRARY_DIR/$libfile $ARCHIVE/$LIBRARY_DIR/
  cp $LIBRARY_DIR/$libfile $ARCHIVE/$LIBRARY_DIR/
done

echo mkdir $ARCHIVE/$EXAMPLE_DIR
mkdir $ARCHIVE/$EXAMPLE_DIR

for exfile in $EXAMPLE_FILES ;
do
  echo cp $EXAMPLE_DIR/$exfile $ARCHIVE/$EXAMPLE_DIR/
  cp $EXAMPLE_DIR/$exfile $ARCHIVE/$EXAMPLE_DIR/
done

echo mkdir $ARCHIVE/$TUTEX_DIR
mkdir $ARCHIVE/$TUTEX_DIR

for exfile in $TUTEX_FILES ;
do
  echo cp $TUTEX_DIR/$exfile $ARCHIVE/$TUTEX_DIR/
  cp $TUTEX_DIR/$exfile $ARCHIVE/$TUTEX_DIR/
done

echo mkdir $ARCHIVE/$DOC_DIR
mkdir $ARCHIVE/$DOC_DIR

for docfile in $DOC_FILES ;
do
  echo cp $DOC_DIR/$docfile $ARCHIVE/$DOC_DIR/
  cp $DOC_DIR/$docfile $ARCHIVE/$DOC_DIR/
done

echo tar czf $ARCHIVE.tar.gz $ARCHIVE/
tar czf $ARCHIVE.tar.gz $ARCHIVE/

echo rm -rf $ARCHIVE
rm -rf $ARCHIVE

echo "---------"
echo "... done"
