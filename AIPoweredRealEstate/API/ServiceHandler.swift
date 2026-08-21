//
//  ServiceHandler.swift
//  AIPoweredRealEstate
//
//  Created by Shireen on 18/08/26.
//

import Foundation
import UIKit

enum APIMethods:String{
   case get = "GET"
   case post = "POST"
   case put = "PUT"
   case delete = "DELETE"
}

class ServiceHandler{
    
    class func genericAPI<T:Codable>(url:String,method:APIMethods = .get,isMutable:Bool = false,param:[String:Any] = [:]) async throws -> T?{
        
        guard let url = URL(string: url) else{throw URLError(.badURL) }
        
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let token = UserDefaults.standard.string(forKey: "token") ?? ""
        
        if token != ""{
            req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if param.isEmpty == false{
            
            switch isMutable{
            case false:
                req.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = try JSONSerialization.data(withJSONObject: param)
                req.httpBody = body
            case true:
                let boundary = "Boundary-\(UUID().uuidString)"
                req.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                let body =  getMutableBody(param: param, boundary: boundary)
                req.httpBody = body
            }
        }
        
        let (data,response) = try await URLSession.shared.data(for: req)
        
        guard let response = response as? HTTPURLResponse else{return nil}
        
        let stscode = response.statusCode
        
        if stscode == 200 || stscode == 201{
            
            let newRes = try JSONDecoder().decode(T.self, from: data)
            
            return newRes
            
        }
        throw URLError(.badServerResponse)
        
    }
    
    class func getMutableBody(param:[String:Any],boundary:String) -> Data{
        
        let body = NSMutableData()
        
        for (key,value) in param{
            if let image = value as? UIImage{
                if let img = image.jpegData(compressionQuality: 0.7){
                    body.appendstr(str: "--\(boundary)\r\n")
                    body.appendstr(str: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"image.jpg\"\r\n")
                    body.appendstr(str: "Content-Type: image/jpeg\r\n\r\n")
                    body.append(img)
                    body.appendstr(str: "\r\n")
                }
            }
            else if let imageArray = value as? [UIImage]{
                for image in imageArray{
                    if let img = image.jpegData(compressionQuality: 0.7){
                        body.appendstr(str: "--\(boundary)\r\n")
                        body.appendstr(str: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"image.jpg\"\r\n")
                        body.appendstr(str: "Content-Type: image/jpeg\r\n\r\n")
                        body.append(img)
                        body.appendstr(str: "\r\n")
                    }
                }
            }
            else{
                body.appendstr(str: "--\(boundary)\r\n")
                body.appendstr(str: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendstr(str: "\(value)\r\n")
            }
        }
        
        body.appendstr(str: "--\(boundary)--\r\n")
        
        return body as Data
    }
     
}

extension NSMutableData{
    func appendstr(str:String){
        if let data = str.data(using: .utf8){
            append(data)
        }
    }
}
