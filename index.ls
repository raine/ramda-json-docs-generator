require! treis
require! 'bluebird': Promise
require! 'temp-write'
require! 'ramda': {take, keys, nth, prop, is-empty, map, zip-obj, pipe-p, to-pairs, pipe, apply, for-each, assoc, concat, replace, default-to}
require! './github'
require! './parse-jsdoc'
require! 'child_process': {spawn}
require! 'concat-stream'
require! mkdirp
require! path
fs = Promise.promisify-all <| require 'fs'
debug = require 'debug' <| 'index'
temp-write = Promise.promisify <| require 'temp-write'

OUT_DIR   = 'out'
JSDOC_BIN = "#{require.main.paths.0}/jsdoc/jsdoc.js"

mkdirp.sync OUT_DIR

die = (err) ->
    console.error 'something went wrong', err
    process.exit 1

# :: String → Promise Object
jsdoc-explain = Promise.promisify (file, cb) ->
    debug {file}, 'jsdoc-explain'
    spawn JSDOC_BIN, [ '--explain', file ]
        ..stdout.pipe concat-stream -> cb null, JSON.parse it.to-string!
        ..stderr.pipe concat-stream -> cb it if !is-empty it

# :: Buffer → Promise Object
jsdoc-explain-buffer = (buf) ->
    debug 'jsdoc-explain-buffer'
    temp-write buf, 'script.js'
        .then jsdoc-explain
        .tap -> debug 'jsdoc-explain-buffer done'

get-ramda-js    = github.get-contents _, 'dist/ramda.js'
parse-buffer    = pipe-p jsdoc-explain-buffer, parse-jsdoc
get-and-parse   = pipe-p get-ramda-js, parse-buffer
tag-to-filename = (concat _, '.json') . replace /\./g, '_'
tag-to-path     = (path.join OUT_DIR, _) . tag-to-filename

get-concurrency = ->
    parse-int default-to 0, process.env.CONCURRENCY

write = (path, contents) ->
    fs.write-file-async path, contents, 'utf8'

json-stringify = JSON.stringify _, void, 2 

github.list-tags!
    .then take 5
    .then (tags) ->
        Promise.map tags, get-and-parse, { concurrency: get-concurrency! }
          .then zip-obj tags
          .then (obj) -> assoc 'latest', obj[tags.0], obj
    .then pipe to-pairs, for-each apply (tag, doc) ->
        write (tag-to-path tag), json-stringify doc
    .catch die
