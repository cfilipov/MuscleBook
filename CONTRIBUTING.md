# Contributing

By contributing to the Muscle Book, you agree to [assign copyright of any contribution back to the project](COPYRIGHT.md) under the [nominated license](LICENSE.md). We are open to, and grateful for, any contributions made by the community.

## How to contribute

Contributions to Muscle Book are very welcome. Please read the [Non-Goals section of the README](README.md#non-goals) before spending any considerable effort on a pull request.

## What to Contribute

Take a look at the [issues page](https://github.com/cfilipov/MuscleBook/labels/help%20wanted) to see if there's anything you can help with. Contributions don't have to be limited to what's in the issues, but if you don't know where to start this should give you an idea.

## Non-Technical Contributions

Don't shy away from contributing just because you can't program. In fact, I believe the most valuable contributions at this point are non-technical in nature. There's more to this project than just code. Here is a list of at least a few non-technical areas where contributions are highly welcome (also have a look at the [issues page](https://github.com/cfilipov/MuscleBook/labels/help%20wanted) page):

* Iconography
* Exercise illustrations
* Exercises (copy, accuracy verification, metadata)
* Documentation (README file, instructions, help info)
* Corrections (is an exercise improperly defined? Spelling error in the UI? Did I get the math wrong somewhere?)
* Translations   
	* *The app is not currently setup for translations, but if someone offers it, I'll make it in. Translating the UI would be relatively easy, the exercise database... not so much..*
* Math (lots of calculations everywhere, suggest new ones or identify areas where the math is done incorrectly)
* Exercise Science   
	* Share research papers that might be relevant to the app. Point out areas that might go against established research.
* UX and design advice   
	* *I'm pretty opinionated on the UX, and the app mostly reflects what I felt a workout journal app should be. But I'd still like to hear people's suggestions. Just don't be offended if it's not implemented.*   
	* *I'd __love__ design input, but I'm not looking to re-design the whole app. The most welcome design input would involve small tweaks here and there to make the app better. One of my goals of the app is to make use of built-in iOS interface components as much as possible, and make the app feel native and avoid reinventing when possible.*

## Technical Overview

Muscle Book is written in [Swift](https://developer.apple.com/swift/) and uses [SQLite](https://www.sqlite.org/) as its data store. The most heavily used Swift frameworks in this project are [SQLite.swift](https://github.com/stephencelis/SQLite.swift), a Swift framework for SQLite and [Eureka](https://github.com/xmartlabs/Eureka), a framework for building table view forms. The central structure is the `Workset` which represents a single set of a particular exercise. A set may contain multiple reps, and often a weight or duration.

### Dependencies

The app makes use of a number of git submodules which are found in the `Submodules` directory. These dependencies are manually added to the project rather than using Carthage or CocoaPods. In addition to the submodules, there is an `Extern` directory for dependencies that could not be included as submodules because some changes were made that have not been contributed back upstream (and I was too lazy to fork them). The goal is to eventually move everything from `Extern` back to `Submodules`. 

# Additional Resources

* [Eureka](https://github.com/xmartlabs/Eureka)
* [SQLite.swift Documentation](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#sqliteswift-documentation)