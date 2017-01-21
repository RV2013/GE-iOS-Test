//
//  GEResultListCell.swift
//  GoEuro
//
//  Created by Rachit on 15/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import UIKit

class GEResultListCell: UITableViewCell {
    
    
    //MARK: -   IBoutLets
    
    @IBOutlet weak var ivProviderLogo: UIImageView!
    
    @IBOutlet weak var lblPrice1: UILabel! // e.g. € 19
    
    @IBOutlet weak var lblPrice2: UILabel! // e.g. .99
    
    @IBOutlet weak var lblTime: UILabel! // may be departure or arrival format -- "hh:mm - hh:mm" -- no preceding ZERO
    
    @IBOutlet weak var lblStops: UILabel! // e.g. "Direct" or "n Stops"
    
    @IBOutlet weak var lblDuration: UILabel! // e.g. "hh:mm h"
    @IBOutlet weak var ivDisclosure: UIImageView!
    
    @IBOutlet weak var LC_aspect_ivProviderLogo: NSLayoutConstraint!
    
    @IBOutlet weak var LC_width_ivProviderLogo: NSLayoutConstraint!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindCell(data: TravelInfo?)
    {
        if let data = data
        {
            if let fileName = data.logo.components(separatedBy: "/").last
            {
                let path = "/logos/\(fileName)"
                let localPath = getLocalPath(forDirectory: .documentDirectory, withPath: path)
                
                ivProviderLogo.image = UIImage(contentsOfFile: localPath)
                
                if ivProviderLogo.image != nil && self.LC_aspect_ivProviderLogo != nil {
                                        
                    let ascale = (ivProviderLogo.image?.size.height)! / ivProviderLogo.frame.size.height
                    
                    let newWidth = (ivProviderLogo.image?.size.width)! / ascale
                    
                    if (self.LC_width_ivProviderLogo != nil){
                        
                        self.LC_width_ivProviderLogo.constant = newWidth
                    }
                    
                    self.LC_aspect_ivProviderLogo.constant = newWidth/ivProviderLogo.frame.size.height
                    
                    ivProviderLogo.frame.size = CGSize(width: newWidth, height: (ivProviderLogo.frame.size.height))
                    
                }
            
            }
            
            lblDuration.text = data.traveltime
            
            lblTime.text = data.departure + " - " + data.arrival
            
            let split = modf(data.price)
            let price = Int(split.0)
            lblPrice1.text = "€\(price)"
            lblPrice2.text = String(format:"%.2f", split.1).replacingOccurrences(of: "0.", with: ".")
            
            if data.stops == 0
            {
                lblStops.text = "Direct"
            }
                
            else
            {
                lblStops.text = "\(data.stops) stop(s)"
            }
        }
    }
    
    
}
