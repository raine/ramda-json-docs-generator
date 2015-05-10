# ramda-docs-json-generator

Parse Ramda source (`dist/ramda.js`) with JSDoc into JSON.

```
[
  {
    "description": "Adds two numbers (or strings). Equivalent to `a + b` but curried.",
    "name": "add",
    "sig": "Number -> Number -> Number",
    "category": "Math"
  },
  ...
]
```

See also: [ramda-json-docs](https://github.com/raine/ramda-json-docs), [alfred-ramda-workflow](https://github.com/raine/alfred-ramda-workflow)

## usage

```sh
# install deps
npm install -g LiveScript
npm install
```

```sh
./ramda-src-to-json.ls path/to/dist/ramda.js
```

```sh
DEBUG=* GITHUB_TOKEN=deadbeef \
  ./fetch-github-tags.ls outdir
```
