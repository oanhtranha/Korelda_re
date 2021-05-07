//
//  Cells.swift
//  Koleda
//
//  Created by Oanh tran on 10/22/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import SpreadsheetView

class DateCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TimeCell: Cell {
    let label = VerticalTopAlignLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.app_SFProDisplayMedium(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .gray
        contentView.addSubview(label)
    }
    
    override var frame: CGRect {
        didSet {
            label.frame = bounds.insetBy(dx: 6, dy: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ScheduleCell: Cell {
    let scheduleViewController = StoryboardScene.SmartSchedule.instantiateScheduleViewController() as? ScheduleViewController
    
    var scheduleContent: ScheduleBlock? {
        didSet {
            scheduleViewController?.reloadData(content: scheduleContent)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scheduleViewController?.view.frame = bounds
        scheduleViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        guard let view = scheduleViewController?.view else {
            return
        }
        contentView.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
 
}

class VerticalTopAlignLabel: UILabel {
    
    override func drawText(in rect:CGRect) {
        guard let labelText = text else {  return super.drawText(in: rect) }
        
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedString.Key.font: font])
        var newRect = rect
        newRect.size.height = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil).size.height
        
        if numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(numberOfLines) * font.lineHeight)
        }
        
        super.drawText(in: newRect)
    }
    
}
