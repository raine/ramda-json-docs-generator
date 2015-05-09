#!/usr/bin/env lsc

require! treis
require! 'bluebird': Promise
require! 'ramda': {take, zip-obj, pipe-p, to-pairs, pipe, apply, for-each, assoc, concat, replace, default-to, nth, chain, tap}
require! 'data.maybe': Maybe
require! './lib/github'
require! './lib/parse-jsdoc-output'
require! './lib/jsdoc'

require! mkdirp
require! path
write-file = Promise.promisify <| require 'fs' .write-file
debug = require 'debug' <| 'index'

get-arg = Maybe.from-nullable . (nth _, process.argv)

die = (err) ->
    console.error 'something went wrong', err
    process.exit 1

get-ramda-js    = github.get-contents _, 'dist/ramda.js'
parse-buffer    = pipe-p jsdoc.explain-buffer, parse-jsdoc-output
get-and-parse   = pipe-p get-ramda-js, parse-buffer
tag-to-filename = (concat _, '.json') . replace /\./g, '_'

concurrency     = -> parse-int default-to 0, process.env.CONCURRENCY
json-stringify  = JSON.stringify _, void, 2

dst-dir-path = get-arg 2
    .or-else -> console.error 'error: no dst dir path given'; process.exit 1
    .chain tap mkdirp.sync

github.list-tags!
    .then take 5
    .then (tags) ->
        Promise.map tags, get-and-parse, { concurrency: concurrency! }
          .then zip-obj tags
          .then (obj) -> assoc 'latest', obj[tags.0], obj
    .then pipe to-pairs, for-each apply (tag, doc) ->
        dst = path.join dst-dir-path, (tag-to-filename tag)
        write-file dst, json-stringify doc
          .tap -> debug "wrote to #dst"
    .catch die
