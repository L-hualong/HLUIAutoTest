//
//  HLSwiftMirrorTool.swift
//  HLUIAutoTest
//
//  Created by 刘华龙 on 2018/8/28.
//  Copyright © 2018年 liuhualong. All rights reserved.
//

import UIKit

open class HLSwiftMirrorTool: NSObject {
    
    @objc static func swiftNameWithInstance(cla: Any, instance: AnyObject) -> String?{
        
        var key:String? = nil

        let classMirror = Mirror.init(reflecting: cla)
        
        for property in classMirror.children {
            
            let value: AnyObject = property.value as AnyObject
            
            if (value === instance) {
                key = property.label!
                //去除swift懒加载变量名后面的".storage"
                if key!.contains(".storage") {
                    key = key?.replacingOccurrences(of: ".storage", with: "")
                }
                return key
            }
        }
        return nil
    }
}
