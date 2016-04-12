/*
 Muscle Book
 Copyright (C) 2016  Cristian Filipov

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation

/*
 Using the integer part of the FMA ID as the raw value. There are a few items that don't map directly to the FMA, so integer values have been generated for these items. It appears that FMA IDs start at 10000, so non-FMA integers in the range of [10,1000] have been reserved for this purpose.
 
 See:
 http://www.agiledata.org/essays/keys.html#Comparison
 http://c2.com/cgi/wiki?AutoKeysVersusDomainKeys
 */
enum Muscle: Int64 {

    /* Individual Muscles */

    case Abductor = 74997
    case ExtensorCarpiUlnaris = 38506
    case ExtensorPollicisBrevis = 38518
    case EntensorPollicisLongus = 38521
    case Anconeus = 37704
    case Adductor = 74998
    case AnteriorDeltoid = 83003
    case Biceps = 37670
    case BicepsFemoris = 22356
    case Brachioradialis = 38485
    case Coracobrachialis = 37664
    case ExternalOblique = 13335
    case FlexorCarpiRadialis = 38459
    case FlexorCarpiUlnaris = 38465
    case FlexorDigitorumSuperficialis = 38469
    case ExtensorDigitorum = 38500
    case GastrocnemiusLateralHead = 45959
    case GastrocnemiusMedialHead = 45956
    case Gastrocnemius = 22541
    case GluteusMaximus = 22314
    case GluteusMedius = 22315
    case GluteusMinimus = 22317
    case IliotibialBand = 51048
    case Infraspinatus = 32546
    case LateralDeltoid = 83006
    case LatissimusDorsi = 13357
    case LevatorScapulae = 32519
    case Peroneus = 22538
    case PosteriorDeltoid = 83007
    case RectusAbdominis = 9628
    case RectusFemoris = 22430
    case RhomboidMajor = 13379
    case RhomboidMinor = 13380
    case Sartorius = 22353
    case Semitendinosus = 22357
    case SerratusAnterior = 13397
    case Soleus = 22542
    case Subscapularis = 13413
    case Supraspinatus = 9629
    case TeresMajor = 32549
    case TeresMinor = 32550
    case TransversusAbdominis = 15570
    case TrapeziusLowerFibers = 32555
    case TrapeziusUpperFibers = 32557
    case TrapeziusMiddleFibers = 32556
    case TricepsSurae = 51062
    case VastusinterMedius = 22433
    case VastusLateralis = 22431
    case VastusMedialis = 22432
    case TricepsLongHead = 37692
    case TricepsLateralHead = 37694
    case Iliocostalis = 77177
    case Longissimus = 77178
    case Spinalis = 77179
    case PectoralisMinor = 13109
    case PectoralisMajorClavicular = 34687
    case PectoralisMajorSternal = 34696
    case PsoasMajor = 18060
    case Iliacus = 22310

    /* Muscle Groups */

    case Iliopsoas = 64918
    case ErectorSpinae = 71302
    case LowerBack = 10 // Does not map to FMA!
    case Forearm = 37371
    case MiddleBack = 11 // Does not map to FMA!
    case Abductors = 12 // Does not map to FMA!
    case Deltoids = 32521
    case Trapezius = 9626
    case RotatorCuff = 82650
    case Triceps = 37688
    case Shoulder = 33531
    case Arm = 37370
    case Back = 85216
    case Glutes = 64922
    case Quadriceps = 22428
    case Hamstrings = 81022
    case Thigh = 50208
    case Calves = 65004
    case Legs = 9622
    case Abdominals = 78435
    case PectoralisMajor = 9627
    case Pectorals = 50223
}

extension Muscle {

    var isMuscleGroup: Bool {
        return !components.isEmpty
    }

    var individualMuscles: [Muscle] {
        guard isMuscleGroup else { return [self] }
        return components.flatMap{$0.individualMuscles}
    }
    
    var flattenedComponents: [Muscle] {
        guard isMuscleGroup else { return [self] }
        return [self] + components.flatMap{$0.flattenedComponents}
    }

    static var muscleGroups: [Muscle] = {
        return allMuscles.filter{$0.isMuscleGroup}
    }()

    static var individualMuscles: [Muscle] = {
        return allMuscles.filter{!$0.isMuscleGroup}
    }()

    private static func normalized(name: String) -> String {
        return name.stringByReplacingOccurrencesOfString("(", withString: "")
            .stringByReplacingOccurrencesOfString(")", withString: "")
            .stringByReplacingOccurrencesOfString("muscle", withString: "")
            .stringByReplacingOccurrencesOfString("muscles", withString: "")
            .stringByReplacingOccurrencesOfString("fiber", withString: "")
            .stringByReplacingOccurrencesOfString("fibers", withString: "")
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            .lowercaseString
    }

    static var allMuscles: [Muscle] = [.Abductor, .ExtensorCarpiUlnaris, .ExtensorPollicisBrevis, .EntensorPollicisLongus, .Anconeus, .Adductor, .AnteriorDeltoid, .Biceps, .BicepsFemoris, .Brachioradialis, .Coracobrachialis, .ExternalOblique, .FlexorCarpiRadialis, .FlexorCarpiUlnaris, .FlexorDigitorumSuperficialis, .ExtensorDigitorum, .GastrocnemiusLateralHead, .GastrocnemiusMedialHead, .Gastrocnemius, .GluteusMaximus, .GluteusMedius, .GluteusMinimus, .IliotibialBand, .Infraspinatus, .LateralDeltoid, .LatissimusDorsi, .LevatorScapulae, .Peroneus, .PosteriorDeltoid, .RectusAbdominis, .RectusFemoris, .RhomboidMajor, .RhomboidMinor, .Sartorius, .Semitendinosus, .SerratusAnterior, .Soleus, .Subscapularis, .Supraspinatus, .TeresMajor, .TeresMinor, .TransversusAbdominis, .TrapeziusLowerFibers, .TrapeziusUpperFibers, .TrapeziusMiddleFibers, .TricepsSurae, .VastusinterMedius, .VastusLateralis, .VastusMedialis, .TricepsLongHead, .TricepsLateralHead, .Iliocostalis, .Longissimus, .Spinalis, .PectoralisMinor, .PectoralisMajorClavicular, .PectoralisMajorSternal, .PsoasMajor, .Iliacus, .Iliopsoas, .ErectorSpinae, .LowerBack, .Forearm, .MiddleBack, .Abductors, .Deltoids, .Trapezius, .RotatorCuff, .Triceps, .Shoulder, .Arm, .Back, .Glutes, .Quadriceps, .Hamstrings, .Thigh, .Calves, .Legs, .Abdominals, .PectoralisMajor, .Pectorals]

    var components: [Muscle] {
        switch self {
        case .Iliopsoas: return [.PsoasMajor,.Iliacus]
        case .ErectorSpinae: return [.Iliocostalis,.Longissimus,.Spinalis]
        case .LowerBack: return [.ErectorSpinae]
        case .Forearm: return [.Anconeus,.FlexorCarpiUlnaris,.Brachioradialis,.ExtensorDigitorum,.ExtensorCarpiUlnaris,.ExtensorPollicisBrevis,.EntensorPollicisLongus,.FlexorCarpiRadialis,.FlexorDigitorumSuperficialis]
        case .MiddleBack: return [.RhomboidMajor,.TrapeziusLowerFibers]
        case .Abductors: return [.GluteusMinimus,.GluteusMedius]
        case .Deltoids: return [.AnteriorDeltoid,.LateralDeltoid,.PosteriorDeltoid]
        case .Trapezius: return [.TrapeziusLowerFibers,.TrapeziusUpperFibers,.TrapeziusMiddleFibers]
        case .RotatorCuff: return [.Infraspinatus,.TeresMinor,.Subscapularis,.Supraspinatus]
        case .Triceps: return [.TricepsLongHead,.TricepsLateralHead]
        case .Shoulder: return [.Deltoids,.RotatorCuff,.TeresMajor]
        case .Arm: return [.Biceps,.Triceps,.Forearm,.Shoulder]
        case .Back: return [.LatissimusDorsi,.RhomboidMajor,.RhomboidMinor,.Infraspinatus,.TeresMajor,.TeresMinor,.ErectorSpinae]
        case .Glutes: return [.GluteusMaximus,.GluteusMedius]
        case .Quadriceps: return [.Adductor,.RectusFemoris,.VastusLateralis,.VastusMedialis]
        case .Hamstrings: return [.BicepsFemoris,.Semitendinosus,.IliotibialBand]
        case .Thigh: return [.Quadriceps,.Hamstrings]
        case .Calves: return [.Peroneus,.Soleus,.GastrocnemiusMedialHead,.GastrocnemiusLateralHead]
        case .Gastrocnemius: return [.GastrocnemiusMedialHead, .GastrocnemiusLateralHead]
        case .Legs: return [.Thigh,.Calves]
        case .Abdominals: return [.RectusAbdominis,.ExternalOblique,.SerratusAnterior]
        case .PectoralisMajor: return [.PectoralisMajorSternal,.PectoralisMajorClavicular]
        case .Pectorals: return [.PectoralisMajor,.PectoralisMinor]
        default: return []
        }
    }

    var fmaID: String? {
        switch self {
        case .Abductor: return "FMA:74997"
        case .ExtensorCarpiUlnaris: return "FMA:38506"
        case .ExtensorPollicisBrevis: return "FMA:38518"
        case .EntensorPollicisLongus: return "FMA:38521"
        case .Anconeus: return "FMA:37704"
        case .Adductor: return "FMA:74998"
        case .AnteriorDeltoid: return "FMA:83003"
        case .Biceps: return "FMA:37670"
        case .BicepsFemoris: return "FMA:22356"
        case .Brachioradialis: return "FMA:38485"
        case .Coracobrachialis: return "FMA:37664"
        case .ExternalOblique: return "FMA:13335"
        case .FlexorCarpiRadialis: return "FMA:38459"
        case .FlexorCarpiUlnaris: return "FMA:38465"
        case .FlexorDigitorumSuperficialis: return "FMA:38469"
        case .ExtensorDigitorum: return "FMA:38500"
        case .GastrocnemiusLateralHead: return "FMA:45959"
        case .GastrocnemiusMedialHead: return "FMA:45956"
        case .Gastrocnemius: return "FMA:22541"
        case .GluteusMaximus: return "FMA:22314"
        case .GluteusMedius: return "FMA:22315"
        case .GluteusMinimus: return "FMA:22317"
        case .IliotibialBand: return "FMA:51048"
        case .Infraspinatus: return "FMA:32546"
        case .LateralDeltoid: return "FMA:83006"
        case .LatissimusDorsi: return "FMA:13357"
        case .LevatorScapulae: return "FMA:32519"
        case .Peroneus: return "FMA:22538"
        case .PosteriorDeltoid: return "FMA:83007"
        case .RectusAbdominis: return "FMA:9628"
        case .RectusFemoris: return "FMA:22430"
        case .RhomboidMajor: return "FMA:13379"
        case .RhomboidMinor: return "FMA:13380"
        case .Sartorius: return "FMA:22353"
        case .Semitendinosus: return "FMA:22357"
        case .SerratusAnterior: return "FMA:13397"
        case .Soleus: return "FMA:22542"
        case .Subscapularis: return "FMA:13413"
        case .Supraspinatus: return "FMA:9629"
        case .TeresMajor: return "FMA:32549"
        case .TeresMinor: return "FMA:32550"
        case .TransversusAbdominis: return "FMA:15570"
        case .TrapeziusLowerFibers: return "FMA:32555"
        case .TrapeziusUpperFibers: return "FMA:32557"
        case .TrapeziusMiddleFibers: return "FMA:32556"
        case .TricepsSurae: return "FMA:51062"
        case .VastusinterMedius: return "FMA:22433"
        case .VastusLateralis: return "FMA:22431"
        case .VastusMedialis: return "FMA:22432"
        case .TricepsLongHead: return "FMA:37692"
        case .TricepsLateralHead: return "FMA:37694"
        case .Iliocostalis: return "FMA:77177"
        case .Longissimus: return "FMA:77178"
        case .Spinalis: return "FMA:77179"
        case .PectoralisMinor: return "FMA:13109"
        case .PectoralisMajorClavicular: return "FMA:34687"
        case .PectoralisMajorSternal: return "FMA:34696"
        case .PsoasMajor: return "FMA:18060"
        case .Iliacus: return "FMA:22310"
        case .Iliopsoas: return "FMA:64918"
        case .ErectorSpinae: return "FMA:71302"
        case .LowerBack: return nil // Does not map to FMA!
        case .Forearm: return "FMA:37371"
        case .MiddleBack: return nil // Does not map to FMA!
        case .Abductors: return nil // Does not map to FMA!
        case .Deltoids: return "FMA:32521"
        case .Trapezius: return "FMA:9626"
        case .RotatorCuff: return "FMA:82650"
        case .Triceps: return "FMA:37688"
        case .Shoulder: return "FMA:33531"
        case .Arm: return "FMA:37370"
        case .Back: return "FMA:85216"
        case .Glutes: return "FMA:64922"
        case .Quadriceps: return "FMA:22428"
        case .Hamstrings: return "FMA:81022"
        case .Thigh: return "FMA:50208"
        case .Calves: return "FMA:65004"
        case .Legs: return "FMA:9622"
        case .Abdominals: return "FMA:78435"
        case .PectoralisMajor: return "FMA:9627"
        case .Pectorals: return "FMA:50223"
        }
    }

    var name: String {
        switch self {
        case .Abductor: return "Abductor"
        case .ExtensorCarpiUlnaris: return "Extensor Carpi Ulnaris"
        case .ExtensorPollicisBrevis: return "Extensor Pollicis Brevis"
        case .EntensorPollicisLongus: return "Entensor Pollicis Longus"
        case .Anconeus: return "Anconeus"
        case .Adductor: return "Adductor"
        case .AnteriorDeltoid: return "Anterior Deltoid"
        case .Biceps: return "Biceps"
        case .BicepsFemoris: return "Biceps Femoris"
        case .Brachioradialis: return "Brachioradialis"
        case .Coracobrachialis: return "Coracobrachialis"
        case .ExternalOblique: return "External Obliques"
        case .FlexorCarpiRadialis: return "Flexor Carpi Radialis"
        case .FlexorCarpiUlnaris: return "Flexor Carpi Ulnaris"
        case .FlexorDigitorumSuperficialis: return "Flexor Digitorum Superficialis"
        case .ExtensorDigitorum: return "Extensor Digitorum"
        case .GastrocnemiusLateralHead: return "Gastrocnemius (Lateral head)"
        case .GastrocnemiusMedialHead: return "Gastrocnemius (Medial Head)"
        case .Gastrocnemius: return "Gastrocnemius"
        case .GluteusMaximus: return "Gluteus Maximus"
        case .GluteusMedius: return "Gluteus Medius"
        case .GluteusMinimus: return "Gluteus Minimus"
        case .IliotibialBand: return "Iliotibial Band"
        case .Infraspinatus: return "Infraspinatus"
        case .LateralDeltoid: return "Lateral Deltoid"
        case .LatissimusDorsi: return "Latissimus dorsi"
        case .LevatorScapulae: return "Levator scapulae"
        case .Peroneus: return "Peroneus"
        case .PosteriorDeltoid: return "Posterior Deltoid"
        case .RectusAbdominis: return "Rectus Abdominis"
        case .RectusFemoris: return "Rectus Femoris"
        case .RhomboidMajor: return "Rhomboid Major"
        case .RhomboidMinor: return "Rhomboid Minor"
        case .Sartorius: return "Sartorius"
        case .Semitendinosus: return "Semitendinosus"
        case .SerratusAnterior: return "Serratus Anterior"
        case .Soleus: return "Soleus"
        case .Subscapularis: return "Subscapularis"
        case .Supraspinatus: return "Supraspinatus"
        case .TeresMajor: return "Teres Major"
        case .TeresMinor: return "Teres Minor"
        case .TransversusAbdominis: return "Transversus Abdominis"
        case .TrapeziusLowerFibers: return "Trapezius (Lower Fibers)"
        case .TrapeziusUpperFibers: return "Trapezius (Upper Fibers)"
        case .TrapeziusMiddleFibers: return "Trapezius (Middle Fibers)"
        case .TricepsSurae: return "Triceps surae"
        case .VastusinterMedius: return "Vastus interMedius"
        case .VastusLateralis: return "Vastus Lateralis"
        case .VastusMedialis: return "Vastus Medialis"
        case .TricepsLongHead: return "Triceps (Long Head)"
        case .TricepsLateralHead: return "Triceps (Lateral Head)"
        case .Iliocostalis: return "Iliocostalis"
        case .Longissimus: return "Longissimus"
        case .Spinalis: return "Spinalis"
        case .PectoralisMinor: return "Pectoralis Minor"
        case .PectoralisMajorClavicular: return "Pectoralis Major (Clavicular)"
        case .PectoralisMajorSternal: return "Pectoralis Major (Sternal)"
        case .PsoasMajor: return "Psoas Major"
        case .Iliacus: return "Iliacus"
        case .Iliopsoas: return "Iliopsoas"
        case .ErectorSpinae: return "Erector spinae"
        case .LowerBack: return "Lower Back"
        case .Forearm: return "Forearms"
        case .MiddleBack: return "Middle Back"
        case .Abductors: return "Abductors"
        case .Deltoids: return "Deltoids"
        case .Trapezius: return "Trapezius"
        case .RotatorCuff: return "Rotator Cuff"
        case .Triceps: return "Triceps"
        case .Shoulder: return "Shoulders"
        case .Arm: return "Arm"
        case .Back: return "Back"
        case .Glutes: return "Glutes"
        case .Quadriceps: return "Quadriceps"
        case .Hamstrings: return "Hamstrings"
        case .Thigh: return "Thigh"
        case .Calves: return "Calves"
        case .Legs: return "Legs"
        case .Abdominals: return "Abdominals"
        case .PectoralisMajor: return "Pectoralis Major"
        case .Pectorals: return "Pectorals"
        }
    }

    var synonyms: [String] {
        switch self {
        case .Abductor: return []
        case .ExtensorCarpiUlnaris: return []
        case .ExtensorPollicisBrevis: return []
        case .EntensorPollicisLongus: return []
        case .Anconeus: return []
        case .Adductor: return ["Inner Thigh"]
        case .AnteriorDeltoid: return ["Deltoid Anterior"]
        case .Biceps: return ["Biceps brachii"]
        case .BicepsFemoris: return []
        case .Brachioradialis: return []
        case .Coracobrachialis: return []
        case .ExternalOblique: return ["External Oblique", "Obliques"]
        case .FlexorCarpiRadialis: return []
        case .FlexorCarpiUlnaris: return []
        case .FlexorDigitorumSuperficialis: return []
        case .ExtensorDigitorum: return []
        case .GastrocnemiusLateralHead: return []
        case .GastrocnemiusMedialHead: return []
        case .Gastrocnemius: return ["Gastrocnemius"]
        case .GluteusMaximus: return []
        case .GluteusMedius: return []
        case .GluteusMinimus: return []
        case .IliotibialBand: return ["Semimembranosus"]
        case .Infraspinatus: return []
        case .LateralDeltoid: return ["Intermediate Deltoid", "Deltoid Lateral"]
        case .LatissimusDorsi: return ["Lats", "Lat"]
        case .LevatorScapulae: return []
        case .Peroneus: return []
        case .PosteriorDeltoid: return ["Deltoid Posterior"]
        case .RectusAbdominis: return ["Rectus Abdominus"]
        case .RectusFemoris: return []
        case .RhomboidMajor: return ["Rhomboids"]
        case .RhomboidMinor: return []
        case .Sartorius: return []
        case .Semitendinosus: return []
        case .SerratusAnterior: return []
        case .Soleus: return []
        case .Subscapularis: return []
        case .Supraspinatus: return []
        case .TeresMajor: return []
        case .TeresMinor: return []
        case .TransversusAbdominis: return []
        case .TrapeziusLowerFibers: return ["Trapezius (descending part)", "Trapezius Lower", "Lower Trapezius"]
        case .TrapeziusUpperFibers: return ["Trapezius (ascending part)", "Trapezius Upper", "Upper Trapezius)"]
        case .TrapeziusMiddleFibers: return ["Trapezius (transverse part)", "Trapezius Middle", "Middle Trapezius"]
        case .TricepsSurae: return []
        case .VastusinterMedius: return []
        case .VastusLateralis: return []
        case .VastusMedialis: return []
        case .TricepsLongHead: return []
        case .TricepsLateralHead: return []
        case .Iliocostalis: return []
        case .Longissimus: return []
        case .Spinalis: return []
        case .PectoralisMinor: return []
        case .PectoralisMajorClavicular: return []
        case .PectoralisMajorSternal: return ["Pectoralis Sternocostal"]
        case .PsoasMajor: return []
        case .Iliacus: return []
        case .Iliopsoas: return ["Inner hip muscles", "dorsal hip muscles", "hip flexors"]
        case .ErectorSpinae: return []
        case .LowerBack: return []
        case .Forearm: return ["Forearms"]
        case .MiddleBack: return []
        case .Abductors: return ["Abductor"]
        case .Deltoids: return ["Deltoid"]
        case .Trapezius: return ["Traps"]
        case .RotatorCuff: return []
        case .Triceps: return ["Triceps brachii", "Tricep"]
        case .Shoulder: return ["Shoulders"]
        case .Arm: return []
        case .Back: return ["General Back", "Back General"]
        case .Glutes: return []
        case .Quadriceps: return ["Quadriceps Femoris"]
        case .Hamstrings: return []
        case .Thigh: return ["Thighs"]
        case .Calves: return ["Calf"]
        case .Legs: return ["Leg"]
        case .Abdominals: return ["Abs", "Ab", "Core"]
        case .PectoralisMajor: return []
        case .Pectorals: return ["Pecs", "Pectoralis", "Chest"]
        }
    }
    
}

enum AnatomicalOrientation {
    case Anterior
    case Posterior
}

extension AnatomicalOrientation {
    var name: String {
        switch self {
        case .Anterior: return "Anterior"
        case .Posterior: return "Posterior"
        }
    }
}

extension Muscle {
    var orientation: AnatomicalOrientation {
        switch self {
        case .Abductor: return .Posterior
        case .ExtensorCarpiUlnaris: return .Posterior
        case .ExtensorPollicisBrevis: return .Posterior
        case .EntensorPollicisLongus: return .Posterior
        case .Anconeus: return .Posterior
        case .Adductor: return .Anterior
        case .AnteriorDeltoid: return .Anterior
        case .Biceps: return .Anterior
        case .BicepsFemoris: return .Posterior
        case .Brachioradialis: return .Anterior
        case .Coracobrachialis: return .Anterior
        case .ExternalOblique: return .Anterior
        case .FlexorCarpiRadialis: return .Anterior
        case .FlexorCarpiUlnaris: return .Anterior
        case .FlexorDigitorumSuperficialis: return .Anterior
        case .ExtensorDigitorum: return .Posterior
        case .GastrocnemiusLateralHead: return .Posterior
        case .GastrocnemiusMedialHead: return .Posterior
        case .Gastrocnemius: return .Posterior
        case .GluteusMaximus: return .Posterior
        case .GluteusMedius: return .Posterior
        case .GluteusMinimus: return .Posterior
        case .IliotibialBand: return .Posterior
        case .Infraspinatus: return .Posterior
        case .LateralDeltoid: return .Anterior
        case .LatissimusDorsi: return .Posterior
        case .LevatorScapulae: return .Posterior
        case .Peroneus: return .Anterior
        case .PosteriorDeltoid: return .Posterior
        case .RectusAbdominis: return .Anterior
        case .RectusFemoris: return .Anterior
        case .RhomboidMajor: return .Posterior
        case .RhomboidMinor: return .Posterior
        case .Sartorius: return .Anterior
        case .Semitendinosus: return .Posterior
        case .SerratusAnterior: return .Anterior
        case .Soleus: return .Anterior
        case .Subscapularis: return .Anterior
        case .Supraspinatus: return .Posterior
        case .TeresMajor: return .Posterior
        case .TeresMinor: return .Posterior
        case .TransversusAbdominis: return .Anterior
        case .TrapeziusLowerFibers: return .Posterior
        case .TrapeziusUpperFibers: return .Posterior
        case .TrapeziusMiddleFibers: return .Posterior
        case .TricepsSurae: return .Posterior
        case .VastusinterMedius: return .Anterior
        case .VastusLateralis: return .Anterior
        case .VastusMedialis: return .Anterior
        case .TricepsLongHead: return .Posterior
        case .TricepsLateralHead: return .Posterior
        case .Iliocostalis: return .Posterior
        case .Longissimus: return .Posterior
        case .Spinalis: return .Posterior
        case .PectoralisMinor: return .Anterior
        case .PectoralisMajorClavicular: return .Anterior
        case .PectoralisMajorSternal: return .Anterior
        case .PsoasMajor: return .Anterior
        case .Iliacus: return .Anterior
        case .Iliopsoas: return .Anterior
        case .ErectorSpinae: return .Posterior
        case .LowerBack: return .Posterior
        case .Forearm: return .Anterior
        case .MiddleBack: return .Posterior
        case .Abductors: return .Posterior
        case .Deltoids: return .Anterior
        case .Trapezius: return .Posterior
        case .RotatorCuff: return .Posterior
        case .Triceps: return .Posterior
        case .Shoulder: return .Posterior
        case .Arm: return .Anterior
        case .Back: return .Posterior
        case .Glutes: return .Posterior
        case .Quadriceps: return .Anterior
        case .Hamstrings: return .Posterior
        case .Thigh: return .Anterior
        case .Calves: return .Posterior
        case .Legs: return .Anterior
        case .Abdominals: return .Anterior
        case .PectoralisMajor: return .Anterior
        case .Pectorals: return .Anterior
        }
    }
}
