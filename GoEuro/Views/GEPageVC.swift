//
//  GEPageVC.swift
//  GoEuro
//
//  Created by Rachit on 15/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import UIKit

@objc protocol GEPageVCDelegate {
    
    @objc optional func willTransit(_ toIndex : Int)
    @objc optional func didTransit(_ fromIndex : Int, completed : Bool)
    
    @objc optional func setSortingDetails(_ sortLabel : String, isAscending : Bool)
    
}

class GEPageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, GEListVCDelegate {
    
    weak var _delegate : GEPageVCDelegate? = nil
    
    private var nextTransitionIndex : Int = -99
    private var activeChildVC : UIViewController? = nil

    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.generateNewListVC("TrainsContentVC"),
                self.generateNewListVC("BusContentVC"),
                self.generateNewListVC("FlightContentVC")]
    }()
    
    fileprivate func generateNewListVC(_ storyboardID: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(storyboardID)")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true) { (isDone : Bool) in
                                
                                self.activeChildVC = firstViewController
                                
                                if let childVC : GEListVC = firstViewController as? GEListVC{
                                    
                                    childVC._delegate = self
                                }
            }
            
             self.getData(nextIndex: 0, vc: firstViewController)
        }
        
       

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK:    -   Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK:    -   Page Controller DataSource
    
    
        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
        }
    
    
  
    
    
    // MARK:    -   Page Controller Delegate
    
    func changeScreen(_ nextScreenIndex : Int, forward:Bool){
        
        
         var aDirection  : UIPageViewControllerNavigationDirection =  .forward
        
        if forward == false {
            
            aDirection = .reverse
        }
        
    
        if let currentViewController : UIViewController = orderedViewControllers[nextScreenIndex] {
            setViewControllers([currentViewController],
                               direction:aDirection,
                               animated: true,
                               completion: nil)
            
            self.activeChildVC = currentViewController
            
            if let childVC : GEListVC = currentViewController as? GEListVC{
                
                childVC._delegate = self
            }
            
            self.getData(nextIndex: nextScreenIndex, vc: currentViewController)
            
           


            
           
        }
    
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        
        
        if self._delegate != nil {
            
            self.nextTransitionIndex = self.orderedViewControllers.index(of: pendingViewControllers[0])!
            
            _delegate?.willTransit!(self.orderedViewControllers.index(of: pendingViewControllers[0])!)
            
    
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        
        self.nextTransitionIndex = completed == true ? self.nextTransitionIndex : -99
        
        if self._delegate != nil {
            
            _delegate?.didTransit!(self.orderedViewControllers.index(of: previousViewControllers[0])!, completed: completed)
        }
    }
        
    
    
    //MARK : - GEListVC Delegate Methods
    
    
    func passSortingDetails(_ sortLabel : String, isAscending : Bool){
        
        self._delegate?.setSortingDetails!(sortLabel, isAscending: isAscending)
    }
    
    
    //MARK: -   Other Methods
    
    func sortData(_ ascending : Bool){
    
        if let activeVC : UIViewController = self.activeChildVC {
            
            if let aListVC : GEListVC = activeVC as? GEListVC{
                
                aListVC.applySort(ascending)
            }
        }
    }


    func getData(nextIndex : Int, vc : UIViewController){
        
        if let aVC  =  vc as? GEListVC{
            
            if (nextIndex == 0){
                
                aVC.fetchData(ofType: .Train)
            }
            else{
                
                let travelType : TravelMode = nextIndex > 1 ? .Flight  : .Bus
                
                aVC.fetchData(ofType: travelType)
            }
            
        }

    }

}
