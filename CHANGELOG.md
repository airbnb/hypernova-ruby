# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

- Developer plugin will now display Hypernova error stack traces in monospaced font, instead of as list items. HTML-escape stack traces.

## [1.1.0] - 2016-11-10

### Added

- Attribute `data-hypernova-id` was added to the fallback HTML. This is a random `id` that
  Hypernova uses to bootstrap the application.

## [1.0.3] - 2016-08-11

### Fixed

- Developer plugin did not include fallback HTML for client-side remounting, now it does.

## [1.0.1] - 2016-06-15

### Fixed

- Errors encountered no longer raise another error due to uninitialized constants.

## [1.0.0] - 2016-06-08

Initial Release
