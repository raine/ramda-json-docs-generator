#!/usr/bin/env lsc

require! './lib/parse-jsdoc-output'
require! './lib/jsdoc'
require! ramda: {pipe-p}

# :: String (file-path) -> ()
ramda-src-to-json = pipe-p do
    jsdoc.explain
    parse-jsdoc-output
    console.log . (JSON.stringify _, void, 2)

ramda-src-to-json process.argv.2
