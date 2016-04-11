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

enum SuccessOrFail {
    case Fail
    case Success

    init(error: ErrorType?) {
        if let _ = error {
            self = .Fail
        }
        else {
            self = .Success
        }
    }

    init(bool: Bool) {
        self = bool ? .Success : .Fail
    }
}

enum Result<T> {
    case Success(T)
    case Fail(ErrorType)

    init(value: T? = nil, error: ErrorType? = nil) {
        if let error = error {
            self = .Fail(error)
            return
        }
        if let value = value {
            self = .Success(value)
            return
        }
        preconditionFailure()
    }
}

extension SuccessOrFail: BooleanType {
    var boolValue: Bool {
        switch self {
        case Success: return true
        case Fail: return false
        }
    }
}

func stringOrNil<T>(val: T?) -> String? {
    guard let val = val else { return nil }
    return String(val)
}

func emptyStringIfNil<T>(val: T?) -> String {
    guard let val = val else { return "" }
    return String(val)
}

func BundlePath(name name: String, type: String) -> String {
    return NSBundle.mainBundle().pathForResource(name, ofType: type)!
}

func DocumentsPath(name name: String, type: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    return documentsPath + "/" + name + type
}

func expandedPath(path: String) -> String {
    var res = path
    res = res.stringByReplacingOccurrencesOfString("$BUNDLE_RESOURCE_PATH", withString: NSBundle.mainBundle().resourcePath!)
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    res = res.stringByReplacingOccurrencesOfString("$DOCUMENTS_PATH", withString: documentsPath)
    let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0]
    res = res.stringByReplacingOccurrencesOfString("$LIBRARY_PATH", withString: libraryPath)
    return res
}

// https://github.com/goktugyil/EZSwiftExtensions
extension UIViewController {
    static var topVC: UIViewController? {
        var presentedVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while let pVC = presentedVC?.presentedViewController {
            presentedVC = pVC
        }

        if presentedVC == nil {
            print("EZSwiftExtensions Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
        }
        return presentedVC
    }
}

// http://stackoverflow.com/a/29461082/952123
extension Dictionary {
    
    init<S: SequenceType where S.Generator.Element == Element>
        (_ seq: S) {
            self.init()
            for (k,v) in seq {
                self[k] = v
            }
    }

    func mapValues<T>(transform: Value->T) -> Dictionary<Key,T> {
        return Dictionary<Key,T>(zip(self.keys, self.values.map(transform)))
    }

    func mapKeys<T>(transform: Key->T) -> Dictionary<T,Value> {
        return Dictionary<T,Value>(zip(self.keys.map(transform), self.values))
    }
    
}

// http://stackoverflow.com/a/26954091/952123
func toByteArray<T>(value: T) -> [UInt8] {
    var v = value
    return withUnsafePointer(&v) {
        Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
    }
}

extension NSComparisonResult {
    init<T: Comparable>(a: T, b: T) {
        switch (a,b) {
        case _ where a < b: self = .OrderedDescending
        case _ where a > b: self = .OrderedAscending
        default: self = .OrderedSame
        }
    }
}


/*
Safely index into an array.

http://stackoverflow.com/a/30593673/952123
*/
extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public struct OrderedZipGenerator<G: GeneratorType where G.Element: Comparable>: GeneratorType {
    typealias GeneratorValue = (G.Element?, G)
    var gv1: GeneratorValue
    var gv2: GeneratorValue

    public init(_ gen1: G, _ gen2: G) {
        var g1 = gen1
        var g2 = gen2
        self.gv1 = (g1.next(), g1)
        self.gv2 = (g2.next(), g2)
    }

    public mutating func next() -> G.Element? {
        var (v1, g1) = gv1
        var (v2, g2) = gv2
        if v1 > v2 {
            defer {
                gv1 = (g1.next(), g1)
            }
            return v1
        } else if v1 < v2 {
            defer {
                gv2 = (g2.next(), g2)
            }
            return v2
        } else {
            defer {
                gv1 = (g1.next(), g1)
                gv2 = (g2.next(), g2)
            }
            return v1
        }
    }
}

public struct OrderedZipSequence<S: SequenceType where S.Generator.Element: Comparable>: SequenceType {
    let s1: S
    let s2: S

    init(_ s1: S, _ s2: S) {
        self.s1 = s1
        self.s2 = s2
    }

    public func generate() -> OrderedZipGenerator<S.Generator> {
        return OrderedZipGenerator(s1.generate(), s2.generate())
    }
}

func orderedZip<S: SequenceType where S.Generator.Element: Comparable>(s1: S, _ s2: S) -> OrderedZipSequence<S> {
    return OrderedZipSequence<S>(s1, s2)
}

func Alert(title: String? = nil, message: String, style: UIAlertControllerStyle = .Alert, buttonTitle: String = "OK", completion: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: buttonTitle, style: .Default, handler: completion))
    UIViewController.topVC!.presentViewController(alert, animated: true, completion: nil)
}

func WarnAlert(title: String? = nil, message: String, style: UIAlertControllerStyle = .Alert, cancelButtonTitle: String = "Cancel", actionButtonTitle: String = "Continue", completion: ((UIAlertAction) -> Void)) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: actionButtonTitle, style: .Destructive, handler: completion))
    alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: nil))
    UIViewController.topVC!.presentViewController(alert, animated: true, completion: nil)
}

struct ConditionalPrefixSequence<S: SequenceType>: SequenceType {

    let base: S
    let maxLength: Int
    typealias Element = S.Generator.Element
    let condition: Element -> Bool

    init(_ base: S, maxLength: Int = Int.max, condition: Element -> Bool) {
        self.base = base
        self.maxLength = maxLength
        self.condition = condition
    }

    func generate() -> AnyGenerator<Element> {
        var gen = self.base.generate()
        var len = 0
        return AnyGenerator {
            guard len < self.maxLength else { return nil }
            guard let next = gen.next() else { return nil }
            guard self.condition(next) == true else { return nil }
            len += 1
            return next
        }
    }

}

extension SequenceType {
    func prefix(maxLength: Int = Int.max, condition: Self.Generator.Element -> Bool) -> AnySequence<Self.Generator.Element> {
        return AnySequence(ConditionalPrefixSequence(self, maxLength: maxLength, condition: condition))
    }
}

// http://stackoverflow.com/a/7520655/952123
extension NSData {
    var hexString : String {
        let buf = UnsafePointer<UInt8>(bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        func itoh(i: UInt8) -> UInt8 {
            return (i > 9) ? (charA + i - 10) : (char0 + i)
        }
        let p = UnsafeMutablePointer<UInt8>.alloc(length * 2)
        for i in 0..<length {
            p[i*2] = itoh((buf[i] >> 4) & 0xF)
            p[i*2+1] = itoh(buf[i] & 0xF)
        }
        return NSString(bytesNoCopy: p, length: length*2, encoding: NSUTF8StringEncoding, freeWhenDone: true)! as String
    }
}

// http://stackoverflow.com/questions/25761344
extension NSData {
    public func cc_sha1() -> NSData {
        let len = Int(CC_SHA1_DIGEST_LENGTH)
        let digest = UnsafeMutablePointer<UInt8>.alloc(len)
        CC_SHA1(bytes, CC_LONG(length), digest)
        return NSData(bytesNoCopy: UnsafeMutablePointer<Void>(digest), length: len)
    }
}

// See also: http://vombat.tumblr.com/post/60530544401/date-parsing-performance-on-ios-nsdateformatter
let k1970ToReferenceDate = NSDate(timeIntervalSince1970: 0).timeIntervalSinceReferenceDate
extension NSDate {
    static func parseISO8601Date(string: String) -> NSDate {
        let cstring = string.cStringUsingEncoding(NSUTF8StringEncoding)!
        let t = CBLParseISO8601Date(cstring) + k1970ToReferenceDate
        return NSDate(timeIntervalSinceReferenceDate: t)
    }
}

extension NSCalendar {
    public func isSameDay(d1: NSDate?, _ d2: NSDate?) -> Bool {
        if d1 == nil && d2 == nil { return true }
        guard let d1 = d1 else { return  false }
        guard let d2 = d2 else { return false }
        return isDate(d1, inSameDayAsDate: d2)
    }
}

// http://stackoverflow.com/a/28102175
extension UITableView {
    //set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    func setAndLayoutTableHeaderView(header: UIView, padding: CGFloat = 0) {
        self.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height + (padding * 2)
        header.frame = frame
        self.tableHeaderView = header
    }
}

extension UIViewController {
    func presentModalViewController(vc: UIViewController, animated: Bool = true, withNav: Bool = true, completion: (Void -> Void)? = nil) {
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: animated, completion: completion)
        // http://stackoverflow.com/a/30787046/952123
        // rdar://19563577
        CFRunLoopWakeUp(CFRunLoopGetCurrent());
    }
}

// https://gist.github.com/JadenGeller/ca466c6ccc96a92ca5c5
extension SequenceType where SubSequence: SequenceType {
    func reduce(@noescape combine: (Self.Generator.Element, Self.Generator.Element) throws -> Self.Generator.Element) rethrows -> Self.Generator.Element? {
        var generator = generate()
        var result = generator.next()
        while let next = generator.next() {
            result = try combine(result!, next)
        }
        return result
    }
}

extension UIViewController {
    @IBAction final func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // http://stackoverflow.com/questions/2798653
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
}

extension NSURL {
    static func cacheUUID() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(NSUUID().UUIDString)
    }
}

// https://gist.github.com/asarode/7b343fa3fab5913690ef
func generateRandomColor() -> UIColor {
    let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
    let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
    let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black

    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
}

// http://stackoverflow.com/a/35014969
extension UIImage {
    class func circle(radius: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx)

        let rect = CGRectMake(0, 0, radius, radius)
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillEllipseInRect(ctx, rect)

        CGContextRestoreGState(ctx)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img
    }
}

extension CollectionType where Index == Int {
    var repeatGenerator: AnyGenerator<Generator.Element> {
        var index = 0
        return AnyGenerator {
            defer { index += 1 }
            return self[index%self.count]
        }
    }
}

extension NSDateFormatter {
    func dateFromOptionalString(string: String?) -> NSDate? {
        guard let string = string else { return nil }
        return dateFromString(string)
    }
}

