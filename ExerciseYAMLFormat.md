# Exercise YAML Format

Exercise data in Muscle Book is defined in [YAML](http://yaml.org) before it is imported into the database. This document describes the YAML format used for Muscle Book exercises.

Below is an example of a single exercise in the YAML format.

	---
	!MuscleBook.ExerciseCoder
	Identifier: 973
	Name: Barbell Squat
	Input: 11
	Equipment: Barbell
	Gif: http://exrx.net/AnimatedEx/Quadriceps/BBSquatHigh.gif
	Force: Push
	Muscles: !MuscleBook.MuscleMovementCoder
	  Target:
	  - 22428
	  Synergists:
	  - 22314
	  - Adductor Magnus
	  - 22542
	  Stabilizers:
	  - 71302
	  Dynamic Stabilizers:
	  - 81022
	  - 45959
	Mechanics: Compound
	Type: Basic
	Instructions:
	- Step 1 text...
	- Step 2 text...
	- Step 3 text...
	...

Muscle Book expects a file with one exercise per YAML document, multiple documents in one file can separated by `---` on its own line and `...` at the end of the file.

#### Identifier 

*REQUIRED*

Unique integer ID for this exercise

#### Name 

*REQUIRED*

Name used for display and search

#### Input

*REQUIRED*

Integer representation of the input options bitmask

    1 << 0  Reps
    1 << 1  Weight
    1 << 2  BodyWeight
    1 << 3  Duration
    1 << 4  AssistanceWeight

#### Equipment

*REQUIRED*

Equipment necessary to perform the exercise. Must be **one** of the following strings:

* `Cable`
* `Lever (plate loaded)`
* `Lever (selectorized)`
* `Weighted`
* `Body Weight`
* `Barbell`
* `Dumbbell`
* `Sled`
* `Smith`
* `Suspended`
* `Assisted`
* `Self-assisted`
* `Assisted (machine)`
* `Assisted (partner)`
* `Suspension`
* `Lever`
    
#### Gif 

*OPTIONAL* 

String representing the URL to an animated GIF resource

#### Force

*OPTIONAL* 

Must be one of the following strings
    
* `Push`
* `Pull`
* `PushAndPull`

#### Level

*OPTIONAL* 

Must be one of the following strings

* `Beginer`
* `Intermediate`
* `Advanced`

#### Muscles

*REQUIRED* 

Muscles are grouped by the following classifications

* `Target` *REQUIRED*
* `Agonist` *OPTIONAL* 
* `Antagonist` *OPTIONAL* 
* `Synergist` *OPTIONAL* 
* `Stabilizer` *OPTIONAL* 
* `DynamicStabilizer` *OPTIONAL* 
* `AntagonistStabilizer` *OPTIONAL* 
* `Other` *OPTIONAL* 

Note: Try not to use the `Other` classification. It's only defined for data sources that don't provide detailed information. This option can be thought of as "everything other than the target muscles".

Each classification is associated with a list of muscles. Muscles can be represented in two ways, the two representations can be freely mixed within the list:

1. An [FMA ID](http://sig.biostr.washington.edu/projects/fm/AboutFM.html) **integer**. This is an integer that uniquely identifies the muscle or muscle group. Every wikipedia article for a muscle contains an FMA ID. Be sure to use only the integer portion of the FMA ID (do not include the "FMA:" string). **This is the preferred way to represent muscles**.
2. The muscle name string. This is more error prone and ambiguous. Try to avoid using this option. If you have to use this option, make sure your muscle name string exactly matches one of the following muscle names to ensure Muscle Book understand this muscle. If the Muscle name does not match one of these options, it will still be imported to the database, but it won't be very useful because it won't be associated with any known muscle ID.
	* `Abductor`
	* `Extensor Carpi Ulnaris`
	* `Extensor Pollicis Brevis`
	* `Entensor Pollicis Longus`
	* `Anconeus`
	* `Adductor`
	* `Anterior Deltoid`
	* `Biceps`
	* `Biceps Femoris`
	* `Brachioradialis`
	* `Coracobrachialis`
	* `External Obliques`
	* `Flexor Carpi Radialis`
	* `Flexor Carpi Ulnaris`
	* `Flexor Digitorum Superficialis`
	* `Extensor Digitorum`
	* `Gastrocnemius (Lateral head)`
	* `Gastrocnemius (Medial Head)`
	* `Gastrocnemius`
	* `Gluteus Maximus`
	* `Gluteus Medius`
	* `Gluteus Minimus`
	* `Iliotibial Band`
	* `Infraspinatus`
	* `Lateral Deltoid`
	* `Latissimus dorsi`
	* `Levator scapulae`
	* `Peroneus`
	* `Posterior Deltoid`
	* `Rectus Abdominis`
	* `Rectus Femoris`
	* `Rhomboid Major`
	* `Rhomboid Minor`
	* `Sartorius`
	* `Semitendinosus`
	* `Serratus Anterior`
	* `Soleus`
	* `Subscapularis`
	* `Supraspinatus`
	* `Teres Major`
	* `Teres Minor`
	* `Transversus Abdominis`
	* `Trapezius (Lower Fibers)`
	* `Trapezius (Upper Fibers)`
	* `Trapezius (Middle Fibers)`
	* `Triceps surae`
	* `Vastus interMedius`
	* `Vastus Lateralis`
	* `Vastus Medialis`
	* `Triceps (Long Head)`
	* `Triceps (Lateral Head)`
	* `Iliocostalis`
	* `Longissimus`
	* `Spinalis`
	* `Pectoralis Minor`
	* `Pectoralis Major (Clavicular)`
	* `Pectoralis Major (Sternal)`
	* `Psoas Major`
	* `Iliacus`
	* `Iliopsoas`
	* `Erector spinae`
	* `Lower Back`
	* `Forearms`
	* `Middle Back`
	* `Abductors`
	* `Deltoids`
	* `Trapezius`
	* `Rotator Cuff`
	* `Triceps`
	* `Shoulders`
	* `Arm`
	* `Back`
	* `Glutes`
	* `Quadriceps`
	* `Hamstrings`
	* `Thigh`
	* `Calves`
	* `Legs`
	* `Abdominals`
	* `Pectoralis Major`
	* `Pectorals`

#### Mechanics

*OPTIONAL*

Must be one of the following strings:

* `Isolation`
* `Compound`

#### Type

*REQUIRED*

Must be one of the following strings:

* `BasicOrAuxiliary`
* `Auxiliary`
* `Basic`
* `Specialized`

#### Instructions

*OPTIONAL*

An array of one or more strings, one for each step of the exercise. Each string will be rendered as a separate row in the UI.

#### Link

*OPTIONAL*

A string representing the URL to the source of this exercise or its author.

#### Source

*OPTIONAL*

A free-form string describing the originator of this exercise data. This can be a name like "John Doe" or an organization or brand like "Exrx". This will typically be used as the label for the link.
