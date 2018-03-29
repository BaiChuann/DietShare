//
//  IDList.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import SQLite

class IDList: Equatable, Codable {
    
    private var type: IDType
    private var list: [String]
    
    enum CodingKeys: String, CodingKey {
        case type
        case list
    }
    
    init(_ type: IDType, _ list: [String]) {
        self.type = type
        self.list = list
    }
    
    convenience init(_ type: IDType) {
        let list = [String]()
        self.init(type,list)
    }
    
    public func getType() -> IDType {
        return self.type
    }
    
    public func getList() -> [String] {
        return self.list
    }
    
    static func ==(lhs: IDList, rhs: IDList) -> Bool {
        return lhs.type == rhs.type && lhs.list == rhs.list
    }
    
    required init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        let typeRawValue = try value.decode(String.self, forKey: .type)
        guard let idType = IDType(rawValue: typeRawValue) else {
            fatalError("Error decoding type")
        }
        self.type = idType
        self.list = try value.decode([String].self, forKey: .list)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type.rawValue, forKey: .type)
        try container.encode(self.list, forKey: .list)
    }
}

extension IDList: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ blobValue: Blob) -> IDList {
        guard let list = try? JSONDecoder().decode(IDList.self, from: Data.fromDatatypeValue(blobValue)) else {
            fatalError("IDList not correctly decoded")
        }
        return list
    }
    public var datatypeValue: Blob {
        guard let listData = try? JSONEncoder().encode(self) else {
            fatalError("IDList not correctly encoded")
        }
        return listData.datatypeValue
    }
    
}
