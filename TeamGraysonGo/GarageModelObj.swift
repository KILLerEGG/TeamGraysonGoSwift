//
//  GarageModelObj.swift
//  GraysonApp
//
//  Created by Graham Turbyne on 7/28/16.
//  Copyright © 2016 Graham Turbyne. All rights reserved.
//

import Foundation

class GarageModelObj: NSObject {
    
    var name: String?
    var garage: String?
    var outside: String?
    var pass: String?
    var order: String?
    var idNum: String?
    
    override init() {
        
    }
    
    init(name: String, garage: String, outside: String, pass: String, order: String, idNum: String){
        
        self.name = name
        self.garage = garage
        self.outside = outside
        self.pass = pass
        self.order = order
        self.idNum = idNum
    }
}