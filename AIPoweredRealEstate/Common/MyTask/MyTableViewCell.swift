//
//  MyTableViewCell.swift
//  AIPoweredRealEstate
//
//  Created by Shireen on 19/08/26.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    

    @IBOutlet weak var flatImage: UIImageView!
    
    
    var imgTask:URLSessionDataTask? = nil
    var imageCache = NSCache<NSString,UIImage>()
    
    private var currentURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgTask?.cancel()
        imgTask = nil
        flatImage.image = #imageLiteral(resourceName: "propertyLuxuryVilla")
      }
    
    func configureCell(urlstr:String){
       
        imgTask?.cancel()
        imgTask = nil
        
        guard let url =  URL(string: urlstr) else{
            return
        }
        
        //check cache
        
        if let cahedImage = imageCache.object(forKey: urlstr  as NSString){
            flatImage.image = cahedImage
            return
        }
        
        //download image
        
        imgTask = URLSession.shared.dataTask(with: url){[weak self]data,_,error in
            
            guard let self = self,let data = data else{return}
           
            guard let image = UIImage(data: data) else{return}
            
            //save in cahche
            
            self.imageCache.setObject(image, forKey: urlstr as NSString)
            
            
            DispatchQueue.main.async {
                
                guard self.currentURL == urlstr else {
                    return
                }
                
                self.flatImage.image = image
                self.imgTask = nil
            }
              
        }
        
        imgTask?.resume()
    }
    
}
