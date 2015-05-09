require! 'bluebird': Promise
require! 'ramda': {take, zip-obj, pipe-p, to-pairs, pipe, apply, for-each, assoc, concat, replace, default-to}
require! './lib/github'
require! './lib/parse-jsdoc-output'
require! './lib/jsdoc'
require! mkdirp
require! path
write-file = Promise.promisify <| require 'fs' .write-file
debug = require 'debug' <| 'index'

OUT_DIR = 'out'
mkdirp.sync OUT_DIR

die = (err) ->
    console.error 'something went wrong', err
    process.exit 1

get-ramda-js    = github.get-contents _, 'dist/ramda.js'
parse-buffer    = pipe-p jsdoc.explain-buffer, parse-jsdoc-output
get-and-parse   = pipe-p get-ramda-js, parse-buffer
tag-to-filename = (concat _, '.json') . replace /\./g, '_'
tag-to-path     = (path.join OUT_DIR, _) . tag-to-filename

concurrency     = -> parse-int default-to 0, process.env.CONCURRENCY
json-stringify  = JSON.stringify _, void, 2

github.list-tags!
    .then take 5
    .then (tags) ->
        Promise.map tags, get-and-parse, { concurrency: concurrency! }
          .then zip-obj tags
          .then (obj) -> assoc 'latest', obj[tags.0], obj
    .then pipe to-pairs, for-each apply (tag, doc) ->
        write-file (tag-to-path tag), json-stringify doc
    .catch die
