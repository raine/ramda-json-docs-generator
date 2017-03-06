#!/usr/bin/env lsc

require! treis
require! 'bluebird': Promise
require! 'ramda': {take, zip-obj, pipe-p, to-pairs, pipe, apply, for-each, assoc, concat, replace, default-to, nth, chain, tap, split, join, curry-n, invoker, gte, complement, filter}
require! 'data.maybe': {from-nullable: maybe}
require! './lib/github'
require! './lib/parse-jsdoc-output'
require! './lib/jsdoc'

require! mkdirp
require! path
write-file = Promise.promisify <| require 'fs' .write-file
debug = require 'debug' <| 'index'

get-arg = maybe . (nth _, process.argv)

die = (err) ->
    console.error 'something went wrong', err
    process.exit 1

lines = split '\n'
unlines = join '\n'
str-contains = curry-n 2, (invoker 1, 'indexOf') >> gte _, 0
filter-lines = (pred, str) -->
    lines str |> filter pred |> unlines

# typedef annotations in ramda jsdoc comments break jsdoc parsing for those
# functions that have it
remove-typedefs = pipe do
    (.to-string 'utf8')
    filter-lines (complement str-contains '* @typedef')
    -> new Buffer it

get-latest-tags = pipe-p github.list-tags, take process.argv.2
get-ramda-js    = github.get-contents _, 'dist/ramda.js'
parse-buffer    = pipe-p jsdoc.explain-buffer, parse-jsdoc-output
get-and-parse   = pipe-p get-ramda-js, remove-typedefs, parse-buffer
tag-to-filename = (concat _, '.json') . replace /\./g, '_'

concurrency     = -> parse-int default-to 0, process.env.CONCURRENCY
json-stringify  = JSON.stringify _, void, 2

dst-dir-path = get-arg 3
    .or-else -> console.error 'error: no dst dir path given'; process.exit 1
    .chain tap mkdirp.sync

get-latest-tags!
    .then (tags) ->
        Promise.map tags, get-and-parse, { concurrency: concurrency! }
            .then zip-obj tags
            .then (obj) -> assoc 'latest', obj[tags.0], obj
    .then pipe to-pairs, for-each apply (tag, doc) ->
        dst = path.join dst-dir-path, (tag-to-filename tag)
        write-file dst, json-stringify doc
          .tap -> debug "wrote to #dst"
    .catch die
