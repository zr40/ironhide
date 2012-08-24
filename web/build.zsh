#!/bin/zsh
set -e

cd ../../web

rsync -ru --delete src/ build/

pushd build

coffee -c *.coffee &
handlebars -k columns *.handlebars -f templates.js &
lessc -x style.less style.css &
wait

rm *.coffee *.handlebars *.less

popd
rsync -ru --delete build/ public/