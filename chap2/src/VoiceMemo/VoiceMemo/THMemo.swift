//
//  THMemo.swift
//  VoiceMemo
//
//  Created by Joon on 02/05/2017.
//  Copyright © 2017 Joon. All rights reserved.
//

import UIKit

let Title_Key = "title"
let URL_Key = "url"
let Date_String_Key = "dateString"
let Time_String_Key = "timeString"

class THMemo: NSObject, NSCoding {
    var title: String
    var url: URL
    var dateString: String?
    var timeString: String?
    
    init(title: String, url: URL) {
        self.title = title
        self.url = url
        super.init()
        let now = Date()
        self.dateString = date(date: now)
        self.timeString = date(date: now)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Title_Key)
        aCoder.encode(url, forKey: URL_Key)
        aCoder.encode(dateString, forKey: Date_String_Key)
        aCoder.encode(timeString, forKey: Time_String_Key)
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: Title_Key) as? String ?? ""
        url = aDecoder.decodeObject(forKey: URL_Key) as? URL ?? URL(fileURLWithPath: "")
        dateString = aDecoder.decodeObject(forKey: Date_String_Key) as? String ?? ""
        timeString = aDecoder.decodeObject(forKey: Time_String_Key) as? String ?? ""
        super.init()
    }
    
    func formatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.dateFormat = format
        return formatter
    }
    
    func date(date: Date) -> String {
        let formatter = self.formatter(format: "MMddyyyy")
        return formatter.string(from: date)
    }
    
    func time(time: Date) -> String {
        let formatter = self.formatter(format: "HHmmss")
        return formatter.string(from: time)
    }
    
    func deleteMemo() -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            print("-- unable to delete \(error.localizedDescription)")
            return false
        }
    }
}
