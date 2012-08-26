#!/bin/zsh
set -e

cd ../../web

rsync -r --inplace --delete src/ build/

pushd build

coffee -c *.coffee &
handlebars -k columns *.handlebars -f templates.js &
lessc -x style.less style.css &
wait

rm *.coffee *.handlebars *.less

popd
rsync -r --inplace --delete build/ public/
