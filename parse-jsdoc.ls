require! 'data.maybe': Maybe
require! 'ramda': {prop-eq, all-pass, filter, pluck, complement, pick, map, tap, where, head, find, assoc, prop, compose, pipe, apply}

is-function      = prop-eq 'kind', 'function'
is-member-of-r   = prop-eq 'memberof', 'R'
is-public        = complement prop-eq 'access', 'private'
is-docs-function = all-pass [is-function, is-member-of-r, is-public]

get-tag-or-empty = (title, obj) -->
    prop 'tags', obj
    |> find where {title}
    |> Maybe.from-nullable
    |> map prop 'text'
    |> (.get-or-else '')

pick-tag = (field, obj) -->
    get-tag-or-empty field, obj
    |> assoc field, _, obj

pick-tags   = map pick-tag, <[ category sig ]>
pick-output = pick <[ name description sig category ]>

# :: [JSDoc] -> [{name, sig, description, category}]
module.exports = pipe do
    filter is-docs-function
    map pick-output . (apply compose, pick-tags)
