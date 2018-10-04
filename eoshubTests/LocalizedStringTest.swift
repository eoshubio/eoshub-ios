//
//  LocalizedStringTest.swift
//  eoshubTests
//
//  Created by kein on 04/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import XCTest

class LocalizedStringTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLocalizedString() {
        
        var allStrings: [String: [String: String]] = [:]
        
        let supportedLanguages = ["en", "ko"]
        
        for lang in supportedLanguages {
            guard let langBundlePath =  Bundle.main.path(forResource: lang, ofType: "lproj") else {
                XCTAssert(false, "File not found")
                return
            }
            
            guard let bundle = Bundle(path: langBundlePath) else {
                XCTAssert(false, "Bundle not found")
                return
            }
            
            guard let localizingFilePath = bundle.path(forResource: "Localizable", ofType: "strings") else {
                XCTAssert(false, "File not found: Localizable.strings")
                return
            }
            
            guard let localizedStrings = NSDictionary(contentsOfFile: localizingFilePath) as? [String: String] else {
                XCTAssert(false)
                return
            }
            allStrings[lang] = localizedStrings
        }
        
        
        for lang in supportedLanguages {
            guard let keys = allStrings[lang]?.keys else { preconditionFailure() }
            
            let otherLangs = supportedLanguages.filter { $0 != lang }
            
            otherLangs.forEach { (otherLang) in
                guard let otherLangStrings = allStrings[otherLang] else { preconditionFailure() }
                for key in keys {
                    let value = otherLangStrings[key]
                    if value == nil {
                        //String Key not Found
                        XCTAssert(false, "String key not found: lang[\(otherLang)], key[\(key)]")
                    }
                }
            }
            
            
            
        }
        
        
    }
    

}
