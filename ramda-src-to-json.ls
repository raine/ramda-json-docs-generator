#!/usr/bin/env lsc

require! './lib/parse-jsdoc-output'
require! './lib/jsdoc'
require! ramda: {pipe-p, last}
require! fs: {read-file}
require! util: {promisify}

read-file-async = promisify read-file

# :: String (file-path) → ()
ramda-src-to-json = pipe-p do
    read-file-async
    jsdoc.explain-buffer
    parse-jsdoc-output
    console.log . (JSON.stringify _, void, 2)

ramda-src-to-json (last process.argv.lsc)
