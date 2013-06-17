#!/bin/bash
set -e

rm -rf build
mkdir build
cp -r src build/work

# Save time by not minifying development-only libraries.
pushd build/work/lib
rm less.js require.js
popd

lessc build/work/style.less build/work/css.css

r.js -o build.js

mv build/minified/lib/almond.js build/js.js
mv build/minified/css.css build/css.css
mv build/minified/release.html build/index.html
mv build/minified/lib/almond.js.map build

rm -rf build/work
rm -rf build/minified
