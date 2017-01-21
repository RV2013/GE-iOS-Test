//
//  GESegmentControl.swift
//  GoEuro
//
//  Created by Rachit on 16/01/17.
//  Copyright © 2017 Rachit Vyas. All rights reserved.
//




import UIKit

// MARK: - Appearance
public struct GESegmentControlAppearance {
    public var backgroundColor: UIColor
    public var selectedBackgroundColor: UIColor
    public var textColor: UIColor
    public var font: UIFont
    public var selectedTextColor: UIColor
    public var selectedFont: UIFont
    public var bottomLineColor: UIColor
    public var selectorColor: UIColor
    public var bottomLineHeight: CGFloat
    public var selectorHeight: CGFloat
    public var labelTopPadding: CGFloat
    
}


// MARK: - Control Item
typealias GESegmentControlItemAction = (_ item: GESegmentControlItem) -> Void

class GESegmentControlItem: UIControl {
    
    // MARK: Properties
    
    fileprivate var willPress: GESegmentControlItemAction?
    fileprivate var didPressed: GESegmentControlItemAction?
    var label: UILabel!
    
    // MARK: Init
    
    init (
        frame: CGRect,
        text: String,
        appearance: GESegmentControlAppearance,
        willPress: GESegmentControlItemAction?,
        didPressed: GESegmentControlItemAction?) {
        super.init(frame: frame)
        self.willPress = willPress
        self.didPressed = didPressed
        label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        label.textColor = appearance.textColor
        label.font = appearance.font
        label.textAlignment = .center
        label.text = text
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    // MARK: Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        willPress?(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didPressed?(self)
    }
}


// MARK: - Control
@objc public protocol GESegmentControlDelegate {
    @objc optional func segmentedControlWillPressItemAtIndex (_ segmentedControl: GESegmentControl, index: Int)
    @objc optional func segmentedControlDidPressedItemAtIndex (_ segmentedControl: GESegmentControl, index: Int)
}

public typealias GESegmentControlAction = (_ segmentedControl: GESegmentControl, _ index: Int) -> Void

open class GESegmentControl: UIView {
    
    // MARK: Properties
    
    weak var delegate: GESegmentControlDelegate?
    var action: GESegmentControlAction?
    
    open var appearance: GESegmentControlAppearance! {
        didSet {
            self.draw()
        }
    }
    
    var titles: [String]!
    var items: [GESegmentControlItem]!
    var selector: UIView!
    
    // MARK: Init
    
    public init (frame: CGRect, titles: [String], action: GESegmentControlAction? = nil) {
        super.init (frame: frame)
        self.action = action
        self.titles = titles
        defaultAppearance()
    }
    
    required public init? (coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    // MARK: Draw
    
    fileprivate func reset () {
        for sub in subviews {
            let v = sub
            v.removeFromSuperview()
        }
        items = []
    }
    
    fileprivate func draw () {
        reset()
        backgroundColor = appearance.backgroundColor
        let width = frame.size.width / CGFloat(titles.count)
        var currentX: CGFloat = 0
        for title in titles {
            let item = GESegmentControlItem(
                frame: CGRect(
                    x: currentX,
                    y: appearance.labelTopPadding,
                    width: width,
                    height: frame.size.height - appearance.labelTopPadding),
                text: title,
                appearance: appearance,
                willPress: { segmentedControlItem in
                    let index = self.items.index(of: segmentedControlItem)!
                    self.delegate?.segmentedControlWillPressItemAtIndex?(self, index: index)
                },
                didPressed: {
                    segmentedControlItem in
                    let index = self.items.index(of: segmentedControlItem)!
                    self.selectItemAtIndex(index, withAnimation: true)
                    self.action?(self, index)
                    self.delegate?.segmentedControlDidPressedItemAtIndex?(self, index: index)
            })
            addSubview(item)
            items.append(item)
            currentX += width
        }
        // bottom line
        let bottomLine = CALayer ()
        bottomLine.frame = CGRect(
            x: 0,
            y: frame.size.height - appearance.bottomLineHeight,
            width: frame.size.width,
            height: appearance.bottomLineHeight)
        bottomLine.backgroundColor = appearance.bottomLineColor.cgColor
        layer.addSublayer(bottomLine)
        // selector
        selector = UIView (frame: CGRect (
            x: 0,
            y: frame.size.height - appearance.selectorHeight,
            width: width,
            height: appearance.selectorHeight))
        selector.backgroundColor = appearance.selectorColor
        addSubview(selector)
        
        selectItemAtIndex(0, withAnimation: true)
    }
    
    fileprivate func defaultAppearance () {
        appearance = GESegmentControlAppearance(
            backgroundColor: UIColor.clear,
            selectedBackgroundColor: UIColor.clear,
            textColor: UIColor.gray,
            font: UIFont.systemFont(ofSize: 15),
            selectedTextColor: UIColor.black,
            selectedFont: UIFont.systemFont(ofSize: 15),
            bottomLineColor: UIColor.black,
            selectorColor: UIColor.black,
            bottomLineHeight: 0.5,
            selectorHeight: 2,
            labelTopPadding: 0)
    }
    
    // MARK: Select
    
    open func selectItemAtIndex (_ index: Int, withAnimation: Bool) {
        moveSelectorAtIndex(index, withAnimation: withAnimation)
        for item in items {
            if item == items[index] {
                item.label.textColor = appearance.selectedTextColor
                item.label.font = appearance.selectedFont
                item.backgroundColor = appearance.selectedBackgroundColor
            } else {
                item.label.textColor = appearance.textColor
                item.label.font = appearance.font
                item.backgroundColor = appearance.backgroundColor
            }
        }
    }
    
    fileprivate func moveSelectorAtIndex (_ index: Int, withAnimation: Bool) {
        let width = frame.size.width / CGFloat(items.count)
        let target = width * CGFloat(index)
        UIView.animate(withDuration: withAnimation ? 0.3 : 0,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0,
                                   options: [],
                                   animations: {
                                    [unowned self] in
                                    self.selector.frame.origin.x = target
            },
                                   completion: nil)
    }
}
