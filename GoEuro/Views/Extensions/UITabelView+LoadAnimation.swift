//
//  UITabelView+LoadAnimation.swift
//  GoEuro
//
//  Created by GlobalSysInfo-Mac-001 on 21/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//

import Foundation


import Foundation
import UIKit
enum AnimationDirect{
    case DropDownFromTop
    case LiftUpFromBottum
    case FromRightToLeft
    case FromLeftToRight
}
extension UITableView {
   
    func reloadDataWithAnimate(direct:AnimationDirect,animationTime:TimeInterval,interval:TimeInterval)->Void{
        self.setContentOffset(self.contentOffset, animated: false)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.isHidden = true
            self.reloadData()
        }) { (finished) -> Void in
            self.isHidden = false
            self.visibleRowsBeginAnimation(direct: direct, animationTime: animationTime, interval: interval)
        }
    }
    func visibleRowsBeginAnimation(direct:AnimationDirect,animationTime:TimeInterval,interval:TimeInterval)->Void{
        let visibleArray : NSArray = self.indexPathsForVisibleRows! as NSArray
        let count =  visibleArray.count
        switch direct{
        case .DropDownFromTop:
            
            if count == 0{
                return
            }
            
            for i in 0...(count-1){
                let path : NSIndexPath = visibleArray.object(at: count - 1 - i) as! NSIndexPath
                let cell : UITableViewCell = self.cellForRow(at: path as IndexPath)!
                cell.isHidden = true
                let originPoint : CGPoint = cell.center
                cell.center = CGPoint(x:originPoint.x, y:originPoint.y - 1000)
                UIView.animate(withDuration: animationTime + TimeInterval(i) * interval, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    cell.center = CGPoint(x:originPoint.x ,  y:originPoint.y + 2.0)
                    cell.isHidden = false
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                        cell.center = CGPoint(x:originPoint.x , y: originPoint.y - 2.0)
                    }, completion: { (finished) -> Void in
                        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                            cell.center = originPoint
                        }, completion: { (finished) -> Void in
                            
                        })
                    })
                    
                })
            }
        case .LiftUpFromBottum:
            for i in 0...(count-1){
                let path : NSIndexPath = visibleArray.object(at: i) as! NSIndexPath
                let cell : UITableViewCell = self.cellForRow(at: path as IndexPath)!
                cell.isHidden = true
                let originPoint : CGPoint = cell.center
                cell.center = CGPoint(x:originPoint.x, y:originPoint.y + 1000)
                UIView.animate(withDuration: animationTime + TimeInterval(i) * interval, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    cell.center = CGPoint(x:originPoint.x , y: originPoint.y - 2.0)
                    cell.isHidden = false
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                        cell.center = CGPoint(x:originPoint.x , y: originPoint.y + 2.0)
                    }, completion: { (finished) -> Void in
                        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                            cell.center = originPoint
                        }, completion: { (finished) -> Void in
                            
                        })
                    })
                })
            }
        case .FromLeftToRight:
            for i in 0...(count-1){
                let path : NSIndexPath = visibleArray.object(at: i) as! NSIndexPath
                let cell : UITableViewCell = self.cellForRow(at: path as IndexPath)!
                cell.isHidden = true
                let originPoint : CGPoint = cell.center
                cell.center = CGPoint(x:-cell.frame.size.width,  y:originPoint.y)
                UIView.animate(withDuration: animationTime + TimeInterval(i) * interval, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    cell.center = CGPoint(x:originPoint.x - 2.0, y: originPoint.y)
                    cell.isHidden = false;
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                        cell.center = CGPoint(x:originPoint.x + 2.0, y: originPoint.y)
                    }, completion: { (finished) -> Void in
                        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                            cell.center = originPoint
                        }, completion: { (finished) -> Void in
                            
                        })
                    })
                })
            }
        case .FromRightToLeft:
            for i in 0...(count-1){
                let path : NSIndexPath = visibleArray.object(at: i) as! NSIndexPath
                let cell : UITableViewCell = self.cellForRow(at: path as IndexPath)!
                cell.isHidden = true
                let originPoint : CGPoint = cell.center
                cell.center = CGPoint(x: cell.frame.size.width * 3.0, y: originPoint.y)
                UIView.animate(withDuration: animationTime + TimeInterval(i) * interval, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    cell.center = CGPoint(x:originPoint.x + 2.0, y: originPoint.y)
                    cell.isHidden = false;
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                        cell.center = CGPoint(x : originPoint.x - 2.0, y: originPoint.y)
                    }, completion: { (finished) -> Void in
                        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                            cell.center = originPoint
                        }, completion: { (finished) -> Void in
                            
                        })
                    })
                })
                
            }
        
        }
        
    }
    
}
