//
//  WSJSONData.swift
//  WSJSONData
//
//  Created by Riley Crebs on 11/14/15.
//  Copyright © 2015 Incravo. All rights reserved.
//

import Foundation

protocol WSJSONDataProtocol {
    func keyPathForKey(key: String) -> String
    func objectForKeyPath(key: String) -> AnyObject?
}

class WSJSONData: NSObject {
    func populate(object: AnyObject, jsonData: AnyObject) {
        if NSJSONSerialization.isValidJSONObject(jsonData) {
            for (key, value) in jsonData as! Dictionary<String, AnyObject> {
                self.populatePropertyFor(object, key: key, value: value)
            }
        }
    }
    
    private func getKeyPathForKey(key: String, object: WSJSONDataProtocol) -> String {
       return object.keyPathForKey(key)
    }
    
    private func getObjectForKey(key: String, parentObject: WSJSONDataProtocol) -> AnyObject? {
        return parentObject.objectForKeyPath(key);
    }
    
    private func populateSubObjectForParent(parentObject: AnyObject?, subObjectKey: String, subObjectData: Dictionary<String, AnyObject>) {
        if let objectForKey = self.getObjectForKey(subObjectKey, parentObject: parentObject as! WSJSONDataProtocol) {
            self.populate(objectForKey, jsonData: subObjectData)
        }
    }
    
    private func updatePropertyFor(object: AnyObject, jsonKey: String, jsonValue: AnyObject) {
        if ((object as? WSJSONDataProtocol) != nil) {
            var keyPath: NSString = self.getKeyPathForKey(jsonKey, object: object as! WSJSONDataProtocol)
            keyPath = (keyPath.length > 0) ? keyPath : jsonKey;
            if (object.respondsToSelector(Selector(keyPath as String))) {
                object.setValue(jsonValue, forKeyPath: keyPath as String)
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
}