import Foundation
import UIKit

let appDelegate                         = UIApplication.shared.delegate as? AppDelegate
var DontHideLoader                      = false
var showLabel : Bool                    = false

struct Constants {
    static let authKey                              = "authKey"
    static let refreshKey                           = "refreshKey"
    static let deviceToken                          = "deviceToken"
    static let deviceType                           = 2
    static let isLoggedIn                           = "isLoggedIn"
    static let isFirstLoggedIn                      = "isFirstLoggedIn"
    static let platform                             = 1
    static let userId                               = "userId"
    static let latitude                             = "latitude"
    static let longitude                            = "longitude"
    static let uuid                                 = UUID()
    static let loginData                            = "loginData"
    static let deviceName                           = UIDevice.current.name
    static let deviceModel                          = UIDevice.current.model
    static let systemName                           = UIDevice.current.systemName
    static let systemVersion                        = UIDevice.current.systemVersion
    static let googleMapApiKey                      = "AIzaSyAjueXZzKodaxXdG2mZYG21_Jaf_ikFicQ"
    static let googleToken                          = "AIzaSyC8QkcmKT-p9tpMnamwLZ3xY4RSTxcvaKk"
    let userDefaults                                = UserDefaults.standard
    
    static func getUniqueDeviceIdentifier() -> String {
        let uniqueIdKey = "com.findingMyNirvana.app"
        let userDefaults = UserDefaults.standard
        // Try to load the identifier from UserDefaults
        if let uniqueId = userDefaults.string(forKey: uniqueIdKey) {
            return uniqueId
        } else {
            // Generate a new identifier if not found in UserDefaults
            let newUniqueId = UUID().uuidString
            userDefaults.set(newUniqueId, forKey: uniqueIdKey)
            return newUniqueId
        }
    }
    
    static func saveDefaults(value: Any?, key: String) {
        if value != nil {
            UserDefaults.standard.set(value!, forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func saveUserDatainLogin(value : LoginResponseData, Key : String){
        if value != nil
        {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey:Key)
        }
        UserDefaults.standard.synchronize()
    }
    
    //    static func saveUserDetails(value : UserInfoData, Key : String){
    //        if value != nil
    //        {
    //            UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey:Key)
    //        }
    //        UserDefaults.standard.synchronize()
    //    }
    
    func getUserloginData() -> LoginResponseData {
        var items = LoginResponseData()
        if let data = UserDefaults.standard.value(forKey:Constants.loginData) as? Data {
            let sidemenuDt = try? PropertyListDecoder().decode(LoginResponseData.self, from: data)
            items = sidemenuDt ?? LoginResponseData()
        }
        return items
    }
    
    static func latLongDoubleConversion(latitude:String,longitude:String) -> (Double,Double) {
        var lat = getLat()
        var long = getLong()
        if latitude != ""{
            lat = Double(latitude) ?? getLat()
        }
        if longitude != ""{
            long = Double(longitude) ?? getLong()
        }
        return (lat,long)
    }
    
    static func getLat() -> Double {
        if let savedData = UserDefaults.standard.string(forKey: Constants.latitude) {
            return Double(savedData) ?? 0.0
        }
        return 0.0
    }
    
    static func getLong() -> Double {
        if let savedData = UserDefaults.standard.string(forKey: Constants.longitude) {
            return Double(savedData) ?? 0.0
        }
        return 0.0
    }
    
    static func getUserDefaultsValue(for key: String) -> String {
        let value = UserDefaults.standard.string(forKey: key)
        if value == nil {
            return ""
        }
        return value!
    }
    
    static func getUserDefaultsIntValue(for key: String) -> Int {
        let value = UserDefaults.standard.integer(forKey: key)
        return value
    }
    
    static func getUserDefaultsBooleanValue(for key: String) -> Bool {
        let value = UserDefaults.standard.bool(forKey: key)
        return value
    }
    
    static func getUserId() -> String {
        let value = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
        return value
    }
    
    static func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key == Constants.deviceToken || key ==  Bundle.main.bundleIdentifier ?? "com.findingMyNirvana.app" || key == "token" || key == "lat" || key == "long" || key == Constants.isFirstLoggedIn {
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static func removeDefaults(key: String) {
        let defaults = UserDefaults.standard
        _ = defaults.dictionaryRepresentation()
        defaults.removeObject(forKey: key)
    }
}

enum SnackBarType {
    case warning
    case info
    case error
    case success
}

enum DropData {
    case country
    case religion
    case caste
    case horoscope
    case star
    case state
    case city
    case highestQualification
    case employmentStatus
    case occupation
    case annualIncome
    case height
    case dietary
    case language
    case documentType
}

struct ConstantMethods{
    static let shared = ConstantMethods()
    private init() {}
    
    func formatDateAndTime(dateString: String, timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let combinedString = "\(dateString) \(timeString)"
        if let date = inputFormatter.date(from: combinedString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMMM dd, yyyy, HH:mm" // 24-hour format
            return outputFormatter.string(from: date)
        } else {
            return "\(dateString), \(timeString)"
        }
    }
    
    func formatDateString(_ dateString: String, inputFormat: String, outputFormat: String) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // consistent parsing
        
        // Set input format and parse date
        formatter.dateFormat = inputFormat
        guard let date = formatter.date(from: dateString) else {
            return nil
        }
        
        // Set output format and return formatted string
        formatter.dateFormat = outputFormat
        return formatter.string(from: date)
    }
    
    func formatTimeRange(_ input: String, inputFormat: String, outputFormat: String) -> String? {
        let components = input.components(separatedBy: " - ")
        guard components.count == 2 else { return nil }
        
        let startString = components[0] // e.g., "2025-06-09 12:00:00"
        let endTimeString = components[1] // e.g., "14:00:00"
        
        // Formatter for input date strings
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let startDate = inputFormatter.date(from: startString) else {
            return nil
        }
        
        // Create full end datetime string
        let datePart = String(startString.prefix(10)) // "2025-06-09"
        let endDateString = "\(datePart) \(endTimeString)"
        
        guard let endDate = inputFormatter.date(from: endDateString) else {
            return nil
        }
        
        // Formatter for output
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formattedStart = outputFormatter.string(from: startDate)
        
        let timeOnlyFormatter = DateFormatter()
        timeOnlyFormatter.dateFormat = "HH:mm"
        timeOnlyFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formattedEnd = timeOnlyFormatter.string(from: endDate)
        
        return "\(formattedStart) - \(formattedEnd)"
    }
    
    func formatTimeDifference(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Parse the date string
        guard let inputDate = dateFormatter.date(from: dateString) else {
            return "Invalid date string"
        }
        
        // Get the difference from the current date
        let currentDate = Date()
        let difference = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: inputDate,
            to: currentDate
        )
        
        // Extract components safely
        let days = difference.day ?? 0
        let hours = difference.hour ?? 0
        let minutes = difference.minute ?? 0
        let seconds = difference.second ?? 0
        
        // Logic for output
        if days > 30 {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd-MM-yyyy"
            return outputFormatter.string(from: inputDate)
        } else if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return hours == 1 ? "\(hours)hr" : "\(hours)hrs"
        } else if minutes > 0 {
            return minutes == 1 ? "\(minutes)min" : "\(minutes)mins"
        } else {
            return "\(seconds)secs"
        }
    }
    
    func convertDateStringFormat(input: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let inputDate = dateFormatter.date(from: input)
        let currentDate = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let inputComponents = calendar.dateComponents([.year, .month, .day], from: inputDate ?? Date())
        dateFormatter.timeZone = NSTimeZone.local
        let locale = NSLocale.current
        let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if formatter.contains("a") { //phone is set to 12 hours
            dateFormatter.dateFormat = "dd-MM-yyyy h:mm a"
        } else { //phone is set to 24 hours
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        }
        return dateFormatter.string(from: inputDate ?? Date())
    }
    
    func convertOnlyDateFormat(input: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let inputDate = dateFormatter.date(from: input)
        let currentDate = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let inputComponents = calendar.dateComponents([.year, .month, .day], from: inputDate ?? Date())
        dateFormatter.timeZone = NSTimeZone.local
        let locale = NSLocale.current
        let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if formatter.contains("a") { //phone is set to 12 hours
            dateFormatter.dateFormat = "dd-MM-yyyy"
        } else { //phone is set to 24 hours
            dateFormatter.dateFormat = "dd-MM-yyyy"
        }
        return dateFormatter.string(from: inputDate ?? Date())
    }
    
    func formateNumber(number:Int) -> String {
        var num:Double = Double(number)
        let sign = ((num < 0) ? "-" : "" )
        num = fabs(num)
        if (num < 1000.0){
            return "\(sign)\(Int(num))"
        }
        let exp:Int = Int(log10(num) / 3.0 )
        let units:[String] = ["K","M","G","T","P","E"]
        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
    
    func daysBetween(startDateStr: String, endDateStr: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust the date format as needed
        if let startDate = dateFormatter.date(from: startDateStr),
           let endDate = dateFormatter.date(from: endDateStr) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            return components.day ?? 0
        } else {
            return 0
        }
    }
    
    func formatDuration(seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]//[.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        guard let formattedString = formatter.string(from: seconds) else {
            return ""
        }
        return formattedString
    }
    
    func checkForUrls(text: String) -> [URL] {
        let types: NSTextCheckingResult.CheckingType = .link
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            
            return matches.compactMap({$0.url})
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        return []
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGSize{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }
    
    func textViewHeight(_ textView: UITextView) -> CGFloat
    {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }
    
    func getUserId() -> String
    {
        let value = UserDefaults.standard.string(forKey: Constants.userId)
        if value == nil
        {
            return "";
        }
        return value ?? ""
    }
    
    func convertDateFormat(input: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let inputDate = dateFormatter.date(from: input)
        let currentDate = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let inputComponents = calendar.dateComponents([.year, .month, .day], from: inputDate ?? Date())
        dateFormatter.timeZone = NSTimeZone.local
        if currentComponents == inputComponents {
            // Date is today, display time
            let locale = NSLocale.current
            let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
            if formatter.contains("a") { //phone is set to 12 hours
                dateFormatter.dateFormat = "h:mm a"
            } else { //phone is set to 24 hours
                dateFormatter.dateFormat = "HH:mm"
            }
            //dateFormatter.dateFormat = "HH:mm a"
            return dateFormatter.string(from: inputDate ?? Date())
        } else if let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: currentDate), inputComponents == calendar.dateComponents([.year, .month, .day], from: tomorrowDate) {
            // Date is tomorrow, display "Tomorrow"
            return "Tomorrow"
        }else if let tomorrowDate = calendar.date(byAdding: .day, value: -1, to: currentDate), inputComponents == calendar.dateComponents([.year, .month, .day], from: tomorrowDate) {
            // Date is tomorrow, display "Tomorrow"
            return "Yesterday"
        }else {
            // Future date, display dd/mm/yyyy
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.string(from: inputDate ?? Date())
        }
    }
    
    func convertDateFormatToDateAndTime(input: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let inputDate = dateFormatter.date(from: input)
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "dd/MM/yyyy, h:mm a"
        return dateFormatter.string(from: inputDate ?? Date())
    }
}

//MARK: Device Type
class DeviceType{
    static let shared = DeviceType()
    private init() {}
    func isIphone()->Bool{
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        }else{
            return true
        }
    }
    
    func isIpadLandscape()->Bool{
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height{
            return true
        }else{
            return false
        }
    }
}

extension URL {
    func fileSizeInMB() -> String? {
        let path = self.path
        
        let attr = try? FileManager.default.attributesOfItem(atPath: path)
        
        if let attr = attr {
            let fileSize = Float(attr[FileAttributeKey.size] as? UInt64 ?? 0) / (
                1024.0 * 1024.0
            )
            
            return String(format: "%.2f", fileSize)
        } else {
            return "Failed to get size"
        }
    }
    
    func fileSizeInMBDouble() -> Double? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.path)
            if let fileSize = attributes[.size] as? Double {
                let fileSizeInMB = fileSize / (1024 * 1024)
                return fileSizeInMB
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
}

//Login status
func loginUpdate(isLogin:Bool) {
    UserDefaults.standard.setValue(isLogin, forKey: "loginstatus")
}

func isLogin()->Bool{
    if let isUserLoggedIn = UserDefaults.standard.value(forKey: "loginstatus") as? Bool {
        if isUserLoggedIn {
            print("User is logged in.")
            return true
        } else {
            print("User is not logged in.")
            return false
        }
    } else {
        print("User is not logged in.")
        return false
    }
}

class TimeChecker {
    private var timer: Timer?
    
    /// Always runs action if now >= (target - 5min), otherwise schedules it.
    func runFunctionBeforeFiveMinutes(of targetDate: Date, action: @escaping () -> Void) {
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -5, to: targetDate)!
        let now = Date()
        
        if now >= reminderDate {
            // We're already in or past the window — run immediately
            print("⚡️ Time passed or within window. Executing now.")
            action()
        } else {
            // Schedule for the reminder time
            let interval = reminderDate.timeIntervalSince(now)
            print("⏳ Scheduled to run after \(interval) seconds.")
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                action()
            }
        }
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}

func zoomRedirection(link:String){
    if let zoomAppURL = URL(string: link) {
        if UIApplication.shared.canOpenURL(zoomAppURL) {
            UIApplication.shared.open(zoomAppURL, options: [:], completionHandler: nil)
            //                } else if let zoomWebURL = URL(string: "zoomus://zoom.us/join?confno=93907436784&pwd=5spx1S") {
        } else if let zoomWebURL = URL(string: link) {
            // Fallback to Safari
            UIApplication.shared.open(zoomWebURL, options: [:], completionHandler: nil)
        }
    }
}

func isOnlyNumbers(_ name: String) -> (isValid: Bool, message: String?) {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let numberRegex = "^[0-9]+$"
    
    if NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: trimmedName) {
        return (false, "Name should not contain only numbers.")
    }
    
    return (true, nil)
}

func isOnlySpecialCharacters(_ name: String) -> (isValid: Bool, message: String?) {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let specialCharRegex = "^[^a-zA-Z0-9]+$"
    
    if NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: trimmedName) {
        return (false, "Name should not contain only special characters.")
    }
    
    return (true, nil)
}

func showSnakbarMsg(message : String, typeofMsg : SnackBarType) {
    let vw = Bundle.main.loadNibNamed("SnackBarVw", owner: UIApplication.topViewController()!, options: nil)?.first as! SnackBarVw
    vw.frame = UIApplication.topViewController()!.view.frame
    vw.mesgLabel.text = message
    vw.loadingDefaultUI(typeofMsg: typeofMsg)
    UIApplication.topViewController()!.view.addSubview(vw)
    UIView.animate(withDuration: 6.0, delay: 0.1, options: .curveEaseInOut, animations: {
        vw.alpha = 0.0
    }, completion: {(isCompleted) in
        vw.removeFromSuperview()
    })
}
