//
//  ViewController.swift
//  GoEuro
//
//  Created by Rachit on 15/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import UIKit



class ViewController: UIViewController, GEPageVCDelegate {
    
    //MARK:     -   IBoutlets
    
    @IBOutlet weak var vwSegmentContainr: UIView!
    
    @IBOutlet weak var vwContainer: UIView!
    
    @IBOutlet weak var lblSortingFactor: UILabel!
    
    
    
    
    
    //MARK:     -   Vars
    fileprivate var  segmented : GESegmentControl?
    
    fileprivate var selectedIndex : Int = 0
    
    fileprivate var aPageVC : GEPageVC? = nil
    
    fileprivate var willMoveToIndex : Int = -99
    
    
    private var isAscending : Bool = true
    
    
    
    //MARK:     -   IBActions
    
    @IBAction func actionToggleOrder(_ sender: Any) {
        
         if self.aPageVC != nil{
            
            if self.aPageVC != nil{
                
                performOnMain {
                    
                    let btn = sender as! UIButton
                    
                    UIView.animate(withDuration: 0.7, animations: {
                        
                        btn.transform = CGAffineTransform(rotationAngle: self.isAscending != true ? CGFloat.pi : 0)
                    })
                
                }
                
                self.aPageVC!.sortData(!self.isAscending)
                
            }
        }
    }
    
    @IBAction func actionSortData(_ sender: Any) {
        
        if self.aPageVC != nil{
            
            
            performOnMain {
                
                let layerAnimation  = CABasicAnimation.init(keyPath: "transform")
                
                layerAnimation.duration = 0.5
                
                layerAnimation.beginTime = 0.0
                
                layerAnimation.valueFunction = CAValueFunction.init(name: kCAValueFunctionRotateZ)
                
                layerAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
                
                layerAnimation.toValue = NSNumber.init(floatLiteral: M_PI)
                
                let btn = sender as! UIButton
                
                btn.layer.add(layerAnimation, forKey: "layerAnimation")
                
                
            }
            
            self.aPageVC!.sortData(self.isAscending)
            
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.segmented == nil{
            
            self.segmented = initializeSegmentView()
            
            segmented!.appearance.backgroundColor  = UIColor.clear
            segmented!.appearance.textColor = UIColor.white
            segmented!.appearance.selectorColor = UIColor.yellow
            segmented!.appearance.selectedTextColor = UIColor.yellow
            
            self.vwSegmentContainr.addSubview(segmented!)

        }
        
        print(self.vwContainer.subviews)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -   Other Methods
    
    private func initializeSegmentView() -> GESegmentControl{
        
        let aControl = GESegmentControl(
            
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.size.width,
                height: 44),
            titles: [
                "TRAIN",
                "BUS",
                "FLIGHT"
            ],
            action: {
                control, index in
                
                print ("segmented did pressed \(index)")
                
                let directionIsForward : Bool  = index > self.selectedIndex ? true : false
                
                self.selectedIndex = index
                
                self.aPageVC?.changeScreen(self.selectedIndex,forward: directionIsForward)
                
        })
        
        return aControl
    }
    
    
    //MARK:     -   Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embedpagevc" {
            
            if let aPageVC : GEPageVC = segue.destination as? GEPageVC{
                
                self.aPageVC = aPageVC
                
                self.aPageVC?._delegate = self
            }
            else{
                
                print("Can't reach to GEPageVC")
            }
            
        }
    }
    
    
    //MARK:     -   PageVC Delegate Methods
    
    func willTransit(_ toIndex : Int){
        
        self.willMoveToIndex = toIndex
    }
    
    func didTransit(_ fromIndex : Int, completed : Bool){
        
        if completed == true && self.willMoveToIndex != -99{
            
            self.segmented?.selectItemAtIndex(self.willMoveToIndex, withAnimation: true)
            
            self.segmented!.action!(self.segmented!, self.willMoveToIndex)
            
        }
        else{
            
            self.willMoveToIndex = -99
        }
    }
    
    
    func setSortingDetails(_ sortLabel : String, isAscending : Bool){
        
        self.lblSortingFactor.text = sortLabel
        
        self.isAscending = isAscending
    }


}

