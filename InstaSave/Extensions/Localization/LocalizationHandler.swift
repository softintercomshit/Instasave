import Foundation


class Localizationhandler {
    
    static let shared = Localizationhandler()
    
    var dictWithLanguages = [String: Any]()
    var currentTable = ""
    var localizedLanguages = [String]()
    
    func checkIfKeyExist(in tableDict: Any?, key: String) {
        if let tableDict = tableDict as? [String: Any] {
            for lang in localizedLanguages {
                if let langDict = tableDict[lang] as? [String: String],
                    let _ = langDict[key] {
                    
                    removeKeyFromDict(lang: lang, key: key)
                } else {
                    saveKey(lang: lang, key: key)
                }
            }
        }
    }
    
    private func removeKeyFromDict(lang: String, key: String) {
        if var stringsDict = stringsDict {
            guard var dictValue = stringsDict[key] else {
                return;
            }
            
            var allLanguages = dictValue.components(separatedBy: ", ")
            if !allLanguages.contains(lang) {return}
            
            for language in allLanguages {
                if language.contains(lang) {
                    let indexOfObject = allLanguages.index(of: language)!
                    allLanguages.remove(at: indexOfObject)
                    break
                }
            }
            
            if allLanguages.count > 0 {
                dictValue = allLanguages.joined(separator: ", ")
            }else{
                stringsDict.removeValue(forKey: key)
            }
            
            writeDictToStringsFile(stringsDict: stringsDict, dictValue: dictValue, key: key)
        }
    }
    
    private func saveKey(lang: String, key: String) {
        func handleStringsDict(stringsDict: inout [String: String]) {
            var dictValue = stringsDict[key] ?? lang
            
            if !dictValue.contains(lang) {
                dictValue = dictValue.appending(", \(lang)")
            }
            
            stringsDict[key] = dictValue
            writeDictToStringsFile(stringsDict: stringsDict, dictValue: dictValue, key: key)
        }
        
        if var stringsDict = stringsDict {
            handleStringsDict(stringsDict: &stringsDict)
        } else {
            var stringsDict = [String: String]()
            handleStringsDict(stringsDict: &stringsDict)
        }
    }
    
    private var desktopUrl: URL {
        let theDesktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)[0];
        let array = theDesktopPath.components(separatedBy: "/")
        let realDesktopPath = "/" + array[1] + "/" + array[2] + "/" + array.last!
        
        return URL(fileURLWithPath: realDesktopPath)
    }
    
    private var appFolderUrl: URL {
        var appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        appName = appName.appending(" localizations")
        let appFolderUrl = desktopUrl.appendingPathComponent(appName)
        
        return appFolderUrl
    }
    
    private var stringsUrl: URL {
        return appFolderUrl.appendingPathComponent("\(currentTable).strings")
    }
    
    private var stringsDict: [String: String]? {
        return NSDictionary(contentsOf: stringsUrl) as? [String: String]
    }
    
    private func writeDictToStringsFile(stringsDict: [String: String], dictValue: String, key: String){
        var finalString = ""
        
        for item in stringsDict {
            if item.key == key {
                finalString = finalString.appending("\"\(key)\" = \"\(dictValue)\";\n\n")
            }else{
                finalString = finalString.appending("\"\(item.key)\" = \"\(item.value)\";\n\n")
            }
        }
        
        // TODO: remove file if dict is empty and remove app folder if there are not files
        try? FileManager.default.createDirectory(atPath: appFolderUrl.path, withIntermediateDirectories: false, attributes: nil)
        try? finalString.write(toFile: stringsUrl.path, atomically: true, encoding: .utf8)
        cleanFiles()
    }
    
    private func cleanFiles() {
        if stringsDict == nil {
            try? FileManager.default.removeItem(at: stringsUrl)
            try? FileManager.default.removeItem(at: appFolderUrl.appendingPathComponent(".DS_Store"))
            
            if let dirs = try? FileManager.default.contentsOfDirectory(atPath: appFolderUrl.path), dirs.isEmpty {
                try? FileManager.default.removeItem(at: appFolderUrl)
            }
        }
    }
    
    func initLocalizationsUtils() {
        guard dictWithLanguages.isEmpty else {
            return
        }
        
        if let bundleUrl = Bundle.main.resourceURL,
            let bundleDirectoryDirs = try? FileManager.default.contentsOfDirectory(atPath: bundleUrl.path) {
            
            for element in bundleDirectoryDirs {
                if element.contains("lproj") {
                    let languageName = element.replacingOccurrences(of: ".lproj", with: "")
                    localizedLanguages.append(languageName)
                    
                    let languageFolderUrl = bundleUrl.appendingPathComponent(element)
                    
                    if let langDir = try? FileManager.default.contentsOfDirectory(atPath: languageFolderUrl.path) {
                        for file in langDir {
                            if file.contains("strings") {
                                let tableName = file.replacingOccurrences(of: ".strings", with: "")
                                let tableUrl = languageFolderUrl.appendingPathComponent(file)
                                
                                if let languageDict = NSDictionary(contentsOfFile: tableUrl.path) as? [String: String] {
                                    if var tableDict = dictWithLanguages[tableName] as? [String: Any] {
                                        tableDict[languageName] = languageDict
                                        dictWithLanguages[tableName] = tableDict
                                    } else {
                                        var tableDict = [String: Any]()
                                        tableDict[languageName] = languageDict
                                        dictWithLanguages[tableName] = tableDict
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
