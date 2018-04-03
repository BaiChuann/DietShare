//
//  RecognitionRequester.swift
//  DietShare
//
//  Created by ZiyangMou on 2/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class RecognitionRequester {
    private let image: UIImage? = nil
    static let shared = RecognitionRequester()
    static let one: Int = 1
    
    private init() {}
    
    func post() {
        let url = URL(string: "https://api.dietlens.com/foodRec")!
        var request = URLRequest(url: url)
        request.setValue("access_key:secret_key", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let postString = "id-bd64b378-e144-11e7-9ea1-1a0051397901&image=@0.jpg"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}
