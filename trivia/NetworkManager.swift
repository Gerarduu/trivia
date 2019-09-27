//
//  NetworkManager.swift
//  trivia
//
//  Created by Gerard Riera Puig on 26/09/2019.
//  Copyright © 2019 Gerard Riera Puig. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static func downloadData(completion:@escaping ((_ json: Data?) -> Void)) {
        
        let url = URL(string: "https://opentdb.com/api.php?amount=20")
        
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            
           
            if error != nil {
                
                print("Error! \(error)")
            } else {
                
                if let urlContent = data {
                    
                    let dataAsString = String(data: urlContent, encoding: .utf8)!
                    
                    let decodedString = dataAsString.decodingHTMLEntities()
                    
                    DispatchQueue.main.sync(execute: {
                        
                        completion(Data(decodedString.utf8))
                    })
                }
            }
        }
        
        task.resume()
    }
}
