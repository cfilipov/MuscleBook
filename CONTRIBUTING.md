# Contributing

By contributing to the Muscle Book, you agree to [assign copyright of any contribution back to the project](COPYRIGHT.md) under the [nominated license](LICENSE.md). We are open to, and grateful for, any contributions made by the community.

# How to contribute

Contributions to Muscle Book are very welcome. Please read the [Non-Goals section of the README](README.md#non-goals) making a pull request.

## Technical Overview

Muscle Book is written in [Swift](https://developer.apple.com/swift/) and uses [SQLite](https://www.sqlite.org/) as its data store. The most heavily used Swift frameworks in this project are [SQLite.swift](https://github.com/stephencelis/SQLite.swift), a Swift framework for SQLite and [Eureka](https://github.com/xmartlabs/Eureka), a framework for building table view forms. The central structure is the `Workset` which represents a single set of a particular exercise. A set may contain multiple reps, and often a weight and/or duration.

### Dependencies

The app makes use of a number of git submodules which are found in the `Submodules` directory. These dependencies are manually added to the project rather than using Carthage or CocoaPods. In addition to the submodules, there is an `Extern` directory for dependencies that could not be included as submodules because some changes were made that have not been contributed back upstream (and I was too lazy to fork them). The goal is to eventually move everything from `Extern` back to `Submodules`. 

# Additional Resources

* [Eureka](https://github.com/xmartlabs/Eureka)
* [SQLite.swift Documentation](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#sqliteswift-documentation)