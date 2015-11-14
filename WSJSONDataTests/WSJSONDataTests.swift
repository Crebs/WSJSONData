//
//  WSJSONDataTests.swift
//  WSJSONDataTests
//
//  Created by Riley Crebs on 11/14/15.
//  Copyright © 2015 Incravo. All rights reserved.
//

import XCTest
@testable import WSJSONData

class WSJSONDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPopulate_WithValidData_ShouldPopulate() {
        let jsonTestData = ["icon_key": "iconvalue", "name_key": "namevalue"]
        let mockObject = TestObject()
        let jsonData = WSJSONData()
        jsonData.populate(mockObject, jsonData: jsonTestData)
        
        XCTAssertEqual(mockObject.name, jsonTestData["name_key"])
        XCTAssertEqual(mockObject.icon, jsonTestData["icon_key"])
    }
    
    func testPopulate_WithUnKnownKeyPath_NonSpecifiedUnknowPropertyShouldBeNil() {
        let jsonTestData = ["icon_key": "iconvalue", "name_key": "namevalue", "longitude": 5]
        let mockObject = TestObject()
        let jsonData = WSJSONData()
        jsonData.populate(mockObject, jsonData: jsonTestData)
        
        XCTAssertEqual(mockObject.name, jsonTestData["name_key"])
        XCTAssertEqual(mockObject.icon, jsonTestData["icon_key"])
        XCTAssertNil(mockObject.lat)
    }
    
    func testPopulate_WithNonSpecifiedKeyPathWithSamePropertyName_ShouldPopulate() {
        let jsonTestData = ["icon": "iconvalue", "name": "namevalue", "lat": 5]
        let mockObject = TestObject()
        let jsonData = WSJSONData()
        jsonData.populate(mockObject, jsonData: jsonTestData)
        
        XCTAssertEqual(mockObject.name, jsonTestData["name"])
        XCTAssertEqual(mockObject.icon, jsonTestData["icon"])
        XCTAssertEqual(mockObject.lat, jsonTestData["lat"])
    }
    
    func testPopulate_WithSubObjectThatDoesNotConformToWSJSONDataProtocol_ShouldSkipSubObject () {
        let jsonSubObjectTestData = ["address": "addressvalue", "name": "namevalue", "number": 42]
        let jsonTestData = ["icon": "iconvalue", "name_key": "namevalue", "lat": 5, "nonConformSubObject": jsonSubObjectTestData]
        let mockObject = TestObject()
        let jsonData = WSJSONData()
        jsonData.populate(mockObject, jsonData: jsonTestData)
        
        XCTAssertEqual(mockObject.name, jsonTestData["name_key"] as? String)
        XCTAssertEqual(mockObject.icon, jsonTestData["icon"] as? String)
        XCTAssertEqual(mockObject.lat, jsonTestData["lat"] as? NSNumber)
        
        let mockSubObject = mockObject.nonWSJSONDataProtocolsubObject;
        XCTAssertNil(mockSubObject?.name)
        XCTAssertNil(mockSubObject?.number)
        XCTAssertNil(mockSubObject?.address)
        
    }
    
    func testPopulate_WithSubObject_ShouldPopulate() {
        let jsonSubObjectTestData = ["address": "addressvalue", "name": "namevalue", "number": 42]
        let jsonTestData = ["icon": "iconvalue", "name_key": "namevalue", "lat": 5, "subObject": jsonSubObjectTestData]
        let mockObject = TestObject()
        let jsonData = WSJSONData()
        jsonData.populate(mockObject, jsonData: jsonTestData)
        
        XCTAssertEqual(mockObject.name, jsonTestData["name_key"] as? String)
        XCTAssertEqual(mockObject.icon, jsonTestData["icon"] as? String)
        XCTAssertEqual(mockObject.lat, jsonTestData["lat"] as? NSNumber)
        
        let mockSubObject = mockObject.subObject;
        XCTAssertEqual(mockSubObject?.number, jsonSubObjectTestData["number"])
        XCTAssertEqual(mockSubObject?.address, jsonSubObjectTestData["address"])
        XCTAssertEqual(mockSubObject?.name, jsonSubObjectTestData["name"])
        
    }
}

class TestObject: NSObject, WSJSONDataProtocol {
    var icon: String?
    var name: String?
    var lat: NSNumber?
    var subObject: TestSubObject?
    var nonWSJSONDataProtocolsubObject: TestSubObjectThatDoesNotConformToWSJSONDataProtocol?
//    var array: Array?
    
    func keyPathForKey(key: String) -> String {
        var keyPath = key
        if key == "icon_key" {
            keyPath = "icon"
        } else if key == "name_key" {
            keyPath = "name"
        }
        return keyPath
    }
    
    func objectForKeyPath(key: String) -> AnyObject? {
        var object: AnyObject? = nil
        if key == "nonConformSubObject" {
            if self.nonWSJSONDataProtocolsubObject == nil {
                self.nonWSJSONDataProtocolsubObject = TestSubObjectThatDoesNotConformToWSJSONDataProtocol()
            }
            object = self.nonWSJSONDataProtocolsubObject
        } else if key == "subObject" {
            if self.subObject == nil {
                self.subObject = TestSubObject()
            }
            object = self.subObject
        }
        return object
    }
}

class TestSubObjectThatDoesNotConformToWSJSONDataProtocol: NSObject {
    var number: NSNumber?
    var name: String?
    var address: String?
}

class TestSubObject: NSObject, WSJSONDataProtocol {
    var number: NSNumber?
    var name: String?
    var address: String?
    
    func keyPathForKey(key: String) -> String {
        return key
    }
    
    func objectForKeyPath(key: String) -> AnyObject? {
        return nil
    }
}