import Foundation
import UIKit

/*
 for Objective C import:
 #import "ProjectName-Swift.h"
 */

private func isSimulator(completion: (() -> Void)?) {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        completion?()
    #endif
}

private func handleLocalizations(table: String, key: String) {
    isSimulator {
        Localizationhandler.shared.currentTable = table
        Localizationhandler.shared.initLocalizationsUtils()
        
        let tableDict = Localizationhandler.shared.dictWithLanguages[table]
        Localizationhandler.shared.checkIfKeyExist(in: tableDict, key: key)
    }
}

extension String {
    var localized: String {
        let table = "Localizable"
        handleLocalizations(table: table, key: self)
        
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(table: String) -> String {
        handleLocalizations(table: table, key: self)
        
        return NSLocalizedString(self, tableName: table, comment: "")
    }
}

extension NSString {
    var localized: String {
        let table = "Localizable"
        handleLocalizations(table: table, key: self as String)
        
        return NSLocalizedString(self as String, comment: "")
    }
    
    func localized(table: String) -> String {
        handleLocalizations(table: table, key: self as String)
        
        return NSLocalizedString(self as String, tableName: table, comment: "")
    }
}
