#!/bin/sh

LC_ALL=C
METADATA=metadata.ttl
EXPORT=graph_tmp.nt
GRAPH=graph.nt
BASE_IRI=https://posters.lswt2021.aksw.org/

MESSAGE="Update ORKG Data"
LOG=""

LOG="${LOG}"$( date '+%Y-%m-%d %H.%M.%S%z' )"\n"

touch $EXPORT
echo "" > $EXPORT

# TODO add mapping

i=0
for dir in _data/poster/*; do
  i=$((i + 1))
  dirname=$(basename $dir)
  echo "<https://posters.lswt2021.aksw.org/$i> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Document> ." >> $EXPORT
  echo "<https://posters.lswt2021.aksw.org/$i> <http://www.w3.org/2000/01/rdf-schema#seeAlso> <https://posters.lswt2021.aksw.org/$dirname> ." >> $EXPORT
  echo "<https://posters.lswt2021.aksw.org/$dirname> <https://posters.lswt2021.aksw.org/slug> \"$dirname\" ." >> $EXPORT
  echo "<https://posters.lswt2021.aksw.org/$dirname> <https://posters.lswt2021.aksw.org/number> \"$i\" ." >> $EXPORT
  ERROR=$( { rapper -i turtle -o ntriples $dir/$METADATA $BASE_IRI >> $EXPORT; } 2>&1 )
  LOG="${LOG}${ERROR}\n"
done
sort -u $EXPORT > $GRAPH
LOG="${LOG}"$( wc -l $GRAPH )"\n"
rm $EXPORT

#echo $LOG

mkdir img

for dir in _data/poster/*; do
  dirname=$(basename $dir)
  ERROR=$( { pdftocairo -png -scale-to 1200 -singlefile $dir/poster.pdf img/${dirname}_s; } 2>&1 )
  LOG="${LOG}${ERROR}\n"
  ERROR=$( { pdftocairo -png -scale-to 3000 -singlefile $dir/poster.pdf img/${dirname}_l; } 2>&1 )
  LOG="${LOG}${ERROR}\n"
done

echo $LOG

# for dir in _data/poster/
# dirname = localpart(dir)
