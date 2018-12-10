require! 'bluebird': Promise
require! '@octokit/rest': Github
require! 'ramda': {pluck, nth, prop}
debug = require 'debug' <| 'github'

b64-decode = (str) -> new Buffer str, 'base64'

github = new Github do
    version: '3.0.0'

list-tags   = Promise.promisify github.repos.get-tags
get-content = Promise.promisify github.repos.get-content

github.authenticate do
    type: 'oauth'
    token: process.env.GITHUB_TOKEN

# :: () → Promise [tag]
exports.list-tags = ->
    debug 'list-tags'
    list-tags owner: 'ramda' repo: 'ramda'
        .then (.data)
        .then pluck 'name'
        .tap -> debug 'list tags done'

# :: ref → path → Promise Buffer
exports.get-contents = (ref, path) ->
    debug {ref}, 'get-contents'
    get-content {owner: 'ramda', repo: 'ramda', path, ref}
        .then (.data)
        .then (b64-decode . prop 'content')
        .tap -> debug 'get contents done'
