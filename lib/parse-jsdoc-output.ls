require! 'data.maybe': {from-nullable: maybe}
require! 'ramda': {prop-eq, all-pass, filter, complement, pick, map, where, find, assoc, prop, compose, pipe, apply, either}

is-function    = prop-eq 'kind', 'function'
is-constant    = prop-eq 'kind', 'constant'
is-member-of-r = prop-eq 'memberof', 'R'
is-public      = complement prop-eq 'access', 'private'
is-documented  = all-pass [
    (either is-function, is-constant)
    is-member-of-r
    is-public
]

get-tag-or-empty = (title, obj) -->
    prop 'tags', obj
    |> find where {title}
    |> maybe
    |> map prop 'text'
    |> (.get-or-else '')

pick-tag = (field, obj) -->
    get-tag-or-empty field, obj
    |> assoc field, _, obj

pick-tags   = map pick-tag, <[ category sig ]>
pick-output = pick <[ name description sig category ]>

# :: [JSDoc] → [{name, sig, description, category}]
module.exports = pipe do
    filter is-documented
    map pick-output . (apply compose, pick-tags)
