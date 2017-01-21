//
//  GEListVC.swift
//  GoEuro
//
//  Created by Rachit on 15/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import UIKit

@objc protocol GEListVCDelegate {
    
    @objc optional func passSortingDetails(_ sortLabel : String, isAscending : Bool)
    
}


class GEListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:     -   IBOutlets
    
    @IBOutlet weak var tblResult: UITableView!
    
    
    //MARK:     -   Vars
    
    weak var _delegate : GEListVCDelegate? = nil
    
    var dataArray: [TravelInfo]?
    
    private var travelMode : TravelMode = .Train
    
    private var shouldAnimate : Bool = false
    
    private var animDirection : AnimationDirect = .DropDownFromTop
    
    private var sortingOrder : TravleInfoSortBy = .Departure
    
    private var sortAscending : Bool = true

    
    //MARK:     -   View Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tblResult.delegate = self
        self.tblResult.dataSource = self
        
        self.tblResult.rowHeight = UITableViewAutomaticDimension
        
         self.tblResult.estimatedRowHeight = 120.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.tblResult.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.tblResult.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: -   Tableview DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellResult :  GEResultListCell? =   tableView.dequeueReusableCell(withIdentifier: "GEResultListCell", for: indexPath) as? GEResultListCell
        
        let travelInfo = dataArray?[indexPath.row]
        
        cellResult?.bindCell(data: travelInfo)
        
        cellResult?.selectionStyle = .none

        return cellResult!
    }
    
    
    //MARK: -   Data Interaction Methods
    
    func fetchData(ofType mode: TravelMode)
    {
        
        
        weak var weakSelf = self
        
        Client.sharedInstance.getListForTravel(mode: mode) { (status, results, error) in
            
            if let results = results
            {
                CoreDataManager.sharedManager.saveTravelInfo(data: results as! [[String:Any]], forType: mode)
            }
            
            weakSelf?.dataArray?.removeAll()
            weakSelf?.dataArray = CoreDataManager.sharedManager.fetchRecords(ofType: mode.rawValue)
            
            performOnMain {
                
                self.travelMode = mode
                
                if (self.shouldAnimate == true  ){
                    
                    weakSelf?.tblResult.reloadDataWithAnimate(direct: (weakSelf?.animDirection)!, animationTime: 0.5, interval: 0.05)
                    
                    self.shouldAnimate = false
                }
                else{
                    
                    weakSelf?.tblResult.reloadData()
                }
                
            }
        }
    }
    
    
    func applySort(_ isAscending : Bool){
        
        let shouldUpdateFactpr  = self.sortAscending == isAscending ? true : false
        self.sortingOrder =  CoreDataManager.sharedManager.sortRecords(ascending: isAscending, updateSortingFactor: shouldUpdateFactpr)
        self.sortAscending = isAscending
        self.shouldAnimate = true
        self.animDirection  = .LiftUpFromBottum
        self.fetchData(ofType: self.travelMode)
        
        self._delegate?.passSortingDetails!(self.sortingOrder.getlabelFor(indexValue: self.sortingOrder.hashValue), isAscending: self.sortAscending)
        
    }



}
