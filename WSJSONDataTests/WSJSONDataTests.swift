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
    
    func testPopulate_WithNSNull_ShouldSkip() {
        let jsonTestData = ["icon": NSNull(), "name_key": "namevalue", "lat": 52]
        let mockObject = TestObject()
        let jsonData = WSJSONData()
        jsonData.populate(mockObject, jsonData: jsonTestData)
        XCTAssertNil(mockObject.icon)
        XCTAssertEqual(mockObject.name, jsonTestData["name_key"])
        XCTAssertEqual(mockObject.lat, jsonTestData["lat"])
    }
    
    func testPopulate_WithTransformable_ShouldHandleTransformable() {
        let jsonTestData = ["icon": "iconValue", "name_key": "namevalue", "lat": 52, "transformableObject":  "{\"0\":0,\"1\":0,\"2\":0,\"3\":0,\"4\":0,\"5\":0,\"6\":0,\"7\":0,\"8\":0,\"9\":0,\"10\":0,\"11\":0,\"12\":0,\"13\":0,\"14\":0,\"15\":0,\"16\":0,\"17\":0,\"18\":0,\"19\":0,\"20\":0,\"21\":0,\"22\":0,\"23\":0}"]
        let mockObject = TestObject()
        let jsonData = WSJSONData()
        jsonData.populate(mockObject, jsonData: jsonTestData)
        XCTAssertEqual(mockObject.icon, jsonTestData["icon"])
        XCTAssertEqual(mockObject.name, jsonTestData["name_key"])
        XCTAssertEqual(mockObject.lat, jsonTestData["lat"])
        XCTAssertTrue((mockObject.transformable as? Dictionary<String, Int>) != nil)
    }
}

class TestObject: NSObject, WSJSONDataProtocol {
    var icon: String?
    var name: String?
    var lat: NSNumber?
    var transformable: AnyObject?
    
    var subObject: TestSubObject?
    var nonWSJSONDataProtocolsubObject: TestSubObjectThatDoesNotConformToWSJSONDataProtocol?
    
    func propertyNameForKey(key: String) -> String {
        var keyPath = key
        if key == "icon_key" {
            keyPath = "icon"
        } else if key == "name_key" {
            keyPath = "name"
        } else if key == "transformableObject" {
            keyPath = "transformable"
        }
        return keyPath
    }
    
    func objectForKeyPath(key: String, value: AnyObject?) -> AnyObject? {
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
    
    func isTransFormableValueForKeyPath(key: String) -> Bool {
        return key == "transformableObject"
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
    
    func propertyNameForKey(key: String) -> String {
        return key
    }
    
    func objectForKeyPath(key: String, value: AnyObject?) -> AnyObject? {
        return nil
    }
    
    func isTransFormableValueForKeyPath(key: String) -> Bool {
        return false
    }
}