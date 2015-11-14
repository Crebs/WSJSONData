//
//  WSJSONData.swift
//  WSJSONData
//
//  Created by Riley Crebs on 11/14/15.
//  Copyright © 2015 Incravo. All rights reserved.
//

import Foundation

@objc public protocol WSJSONDataProtocol {
    /* Called on object when checking the property name for a key path. This will map an objects property to the JSON key value. If the key and the property name are the same then you can just return the key.
    @param key The key in the JSON object that needs to be mapped to a property on the object conforming to this protocol
    @return The object conforming to this protocol must return the property name that should be mapped to the JSON key.  If the key and the property name are the same just return the key.
    */
    @objc func propertyNameForKey(key: String) -> String
    
    /* The object conforming to the WSJSONDataProtocol is responsible for providing newly allocated objects.  When a new JSON object is encounder the conforming object will be asked for the new object to poulate with JSON
    @param key The JSON key for the new JSON object. It is the conforming objects job to provide the object to be poplualted by looking at the key and determining what object to return.
    @param valude The object conforming to the protocol may use the value to determine what object to create or find.
    @return Object to be poplated in the matching key and value
    */
    @objc func objectForKeyPath(key: String, value: AnyObject?) -> AnyObject?
    
    /* If a property type is a transformable type the conforming object returns true.
    @param key The key to check if a property type is transformable
    return True if the property value/type is suppose to be transformable. False otherwise.
    */
    @objc func isTransFormableValueForKeyPath(key: String) -> Bool
}

public class WSJSONData: NSObject {
    /* Populates a give object that conforms to WSJSONDataProtocal.
    @param object Object to popluate
    @param jsonData JSON to populate the object with
    */
    @objc public func populate(object: AnyObject, jsonData: AnyObject) {
        if NSJSONSerialization.isValidJSONObject(jsonData) {
            for (key, value) in jsonData as! Dictionary<String, AnyObject> {
                if ((value as? NSNull) == nil) {
                    self.populatePropertyFor(object, key: key, value: value)
                }
            }
        }
    }
    
    private func getKeyPathForKey(key: String, object: WSJSONDataProtocol) -> String {
        return object.propertyNameForKey(key)
    }
    
    private func getObjectForKey(key: String, value: AnyObject?, parentObject: WSJSONDataProtocol) -> AnyObject? {
        return parentObject.objectForKeyPath(key, value: value);
    }
    
    private func isTransformableValueForKeyPath(key:String, object: WSJSONDataProtocol) -> Bool {
        return object.isTransFormableValueForKeyPath(key)
    }
    
    private func populateSubObjectForParent(parentObject: AnyObject?, subObjectKey: String, subObjectData: Dictionary<String, AnyObject>) {
        if let objectForKey = self.getObjectForKey(subObjectKey, value: subObjectData, parentObject: parentObject as! WSJSONDataProtocol) {
            self.populate(objectForKey, jsonData: subObjectData)
        }
    }
    
    private func updatePropertyFor(object: AnyObject, jsonKey: String, jsonValue: AnyObject) {
        if ((object as? WSJSONDataProtocol) != nil) {
            
            var keyPath: NSString = self.getKeyPathForKey(jsonKey, object: object as! WSJSONDataProtocol)
            keyPath = (keyPath.length > 0) ? keyPath : jsonKey;
            if (object.respondsToSelector(Selector(keyPath as String))) {
                let objectValue = self.transformableValueForKeyPath(jsonKey, value: jsonValue, object: object)
                object.setValue(objectValue, forKeyPath: keyPath as String)
            }
        }
    }
    
    private func populatePropertyFor(object: AnyObject, key: String, value: AnyObject) {
        if let subObjectData = value as? Dictionary<String, AnyObject> {
            self.populateSubObjectForParent(object, subObjectKey: key, subObjectData: subObjectData)
        } else {
            self.updatePropertyFor(object, jsonKey: key, jsonValue: value)
        }
    }
    
    private func transformableValueForKeyPath(key: String, value: AnyObject, object: AnyObject) -> AnyObject {
        var objectValue = value;
        if value as? String != nil {
            if self.isTransformableValueForKeyPath(key, object: object as! WSJSONDataProtocol) {
                let objectData: NSData = ((value as? NSString)?.dataUsingEncoding(NSUTF8StringEncoding))!
                do {
                    try objectValue = NSJSONSerialization.JSONObjectWithData(objectData, options: NSJSONReadingOptions.AllowFragments)
                } catch {
                    objectValue = NSNull()
                }
            }
        }
        return objectValue
    }
}