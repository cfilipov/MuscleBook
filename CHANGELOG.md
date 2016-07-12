# Change Log

### [0.1.1](https://github.com/cfilipov/MuscleBook/releases/tag/v0.1.1)

* Fixed: Crash when looking up max weight for bodyweight exercise ([#44](https://github.com/cfilipov/MuscleBook/issues/44)).
* Fixed: Error recalculating workouts when entering warmup set ([#43](https://github.com/cfilipov/MuscleBook/issues/43)).
* Fixed: Not dismissing view controllers properly when deleting sets.
* Fixed: When editing a data point, the weight in the the workout summary doesn't update until refreshed ([#40](https://github.com/cfilipov/MuscleBook/issues/40)).

### [0.1.0](https://github.com/cfilipov/MuscleBook/releases/tag/v0.1.0)

* New: Exercise statistics in exercise detail screen. Stats include max weight, max e1rm, volume, total workouts, total sets and a punchcard graph.
* Fixed: Bug with intensity calculation/display (default to light instead of none).
* Fixed: Punchcard graph not displaying the latest days.
* Better punchcard coloring. Previously punchcard colors were based on volume only, now it's volume or intensity, whichever is higher.
* New: Sort exercises based on frequency. Default for frequency sort when there are 3 or more exercises performed.
* Fixed: workout calculations don't appear on first workout.
* New: Data entry fields are now based on exercise. Example: Pull ups only have a field for bodyweight, weighted pull ups have added weight field, etc...
* Gif animation in exercise instructions (network connection required)
* Added exercise instructions
* Fixed: Workout duration calculations were off
* New: You can now manually enter duration.
* YAML exercise import/export.

##### Known Issues in 0.1.0

* While it's possible to edit or delete a past workout set, doing so requires all workouts that follow to have to be recalculated. The input data should not be effected, but PRs and other stats will. This process might take a while and will lock up the UI.
* It's not possible to add a set to a past workout.
* Github-style punchcard graph doesn't refresh unless you restart the app.

### [0.0.1](https://github.com/cfilipov/MuscleBook/releases/tag/v0.0.1)

* Major database schema migration, allows for more useful data and faster lookups.
* Added the ability to edit past workout sets.
* Added the ability to delete past workout sets.
	* *Note, you cannot add new sets to past workouts for now, only to current workouts.*
* Added github-style punchcard graph to main screen.
* Added "Last Rest Day" and "Last Workout" day counter to main screen.
* Fixed bugs with rendering anatomy diagram muscles where only one muscle would render.
* Added list of exercises performed for the selected day on the main screen.
* Moved "Add Data Point" button to the main screen.
* Improvement: "Add Data Point" now automatically creates a workout.
* Improved layout/readability in "Workouts" screen.
* Anatomy diagram now only renders target muscles.
* Workout summary screen now displays more data: Ave volume, intensity, time etc...
* Sets section in workout summary now shows reps, weight, duration when applicable.
* Data entry screen now supports tracking duration instead of just start time. This is a step towards reporting on time between sets.
* Added "Failure" rep toggle data entry screen.
* Added "Warmup" set toggle to data entry screen. Warmup reps are not counter towards volume or intensity.
* Fixed: e1rm row in data entry screen not always accurate and sometimes doesn't appear.
* Added: Volume calculation to data entry screen.
* Added: Personal records with % of record calculation to data entry screen.
* Added more statistics: "Big 3" lifts total, other totals.
* Added tab bar
* Added credits screen

##### Known Issues in 0.0.1

* While it's possible to edit or delete a past workout set, doing so requires all workouts that follow to have to be recalculated. The input data should not be effected, but PRs and other stats will. This process might take a while and will lock up the UI.
* It's not possible to add a set to a past workout.
* Duration numbers seem off.
* Github-style punchcard graph doesn't render the last couple days for some reason.
* YAML and CSV import is non-functional (removed for now). You can still export the saw SQLite3 file **and should back it up periodically**.

### 0.0.0

Initial version. Note, this version was accidentally marked as `1.0.0` in the `Info.plist`.
