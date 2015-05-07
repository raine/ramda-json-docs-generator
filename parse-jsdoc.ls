require! 'data.maybe': Maybe
require! 'ramda': {prop-eq, all-pass, filter, pluck, complement, pick, map, tap, where, head, find, assoc, prop}

is-function      = prop-eq 'kind', 'function'
is-member-of-r   = prop-eq 'memberof', 'R'
is-public        = complement prop-eq 'access', 'private'
is-docs-function = all-pass [is-function, is-member-of-r, is-public]

find-sig-tag = find where title: 'sig'
get-sig      = (.get-or-else '') . (map prop 'text') . Maybe.from-nullable . find-sig-tag . prop 'tags'
set-sig      = (obj) -> assoc 'sig', (get-sig obj), obj

pick-output = pick <[ name description sig ]>

# :: [JSDoc] -> [{name, sig, description}]
module.exports = (map (pick-output . set-sig)) . filter is-docs-function
