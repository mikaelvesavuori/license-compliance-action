# `license-compliance` GitHub Action

**License compliance for Node application made ultra easy. Provide it a string of licenses or fetch licenses dynamically from an online source.**

Uses [license-compliance](https://www.npmjs.com/package/license-compliance) to check if open source packages you are using for production builds have allowed licenses.

_Note that you will need to have a `package.json` file present for this action to run (else it will exit gracefully). The action will install all dependencies before checking, so that the licenses can be accessed_.

## Setup and usage

There really is not that much to setup! However, if you want your toggles living somewhere else, you will need to provide a service that accepts `GET` requests. The response must not be deeper than one level (if it is nested, use `nested_field` explained below).

A hot tip is to use a basic service like [Mockachino](https://www.mockachino.com/) to serve them, at least as a start. An object that matches the defaults would look like:

```json
{
  "licenseString": "MIT;ISC;0BSD;BSD-2-Clause;BSD-3-Clause;Apache-2.0"
}
```

## Optional input arguments

### `allow_licenses`

A list of allowed licenses. It will default to the very open and generous set of `MIT;ISC;0BSD;BSD-2-Clause;BSD-3-Clause;Apache-2.0`.

### `nested_field`

If pointing the `allow_licenses` input to an URL, use this to indicate whether the response will be in a single-level-nested object, such as under `allowedLicenses`.

### `exclude_pattern`

An exclusion pattern, such as `/^@the-project/;some-package`.

## Example of how to use this action in a workflow

Minimal use-case where you want to just get going with the defaults:

```yml
on: [push]

jobs:
  main:
    runs-on: ubuntu-latest
    steps:
      - name: License compliance check
        uses: mikaelvesavuori/license-compliance-action@v1.0.0
```

If you want a more dynamic setup with the allowed licenses residing somewhere else, then you can do:

```yml
on: [push]

jobs:
  main:
    runs-on: ubuntu-latest
    steps:
      - name: License compliance check
        uses: mikaelvesavuori/license-compliance-action@v1.0.0
        with:
          allow_licenses: "https://www.mockachino.com/{{YOUR_RANDOM_STRING}}/licenses"
          nested_field: "licenseString"
```
