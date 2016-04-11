# Contributing

By contributing to the Muscle Book, you agree to [assign copyright of any contribution back to the project](COPYRIGHT.md) under the [nominated license](LICENSE.md). We are open to, and grateful for, any contributions made by the community.

# How to contribute

Contributions to Muscle Book are very welcome. Please read the [Non-Goals section of the README](README.md#non-goals) making a pull request.

## Technical Overview

Muscle Book is written in [Swift](https://developer.apple.com/swift/) and uses a [SQLite](https://www.sqlite.org/) backend. The most heavily used Swift frameworks in this project are [SQLite.swift](https://github.com/stephencelis/SQLite.swift), a Swift framework for SQLite and [Eureka](https://github.com/xmartlabs/Eureka), a framework for building table view forms. The central structure is the `Workset` which represents a single set of a particular exercise. A set may contain multiple reps, and often a weight and/or duration.

# Additional Resources

* [Eureka](https://github.com/xmartlabs/Eureka)
* [SQLite.swift Documentation](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#sqliteswift-documentation)