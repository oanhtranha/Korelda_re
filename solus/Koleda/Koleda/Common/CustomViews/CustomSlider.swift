//
//  CustomSlider.swift
//  Koleda
//
//  Created by Oanh Tran on 9/15/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import UIKit

func delay(_ delay:Double, closure:@escaping ()->()) {
	let when = DispatchTime.now() + delay
	DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

class CustomSlider: UISlider {
	
	required init?(coder: NSCoder) {
		super.init(coder:coder)
		self.setThumbImage(UIImage(named:"timer-slider_thumb")!, for:.normal)
		self.setThumbImage(UIImage(named:"timer-slider_thumb")!, for:.highlighted)
		self.setThumbImage(UIImage(named:"timer-slider_thumb")!, for:.focused)
		self.setMinimumTrackImage(UIImage(named: "slider-active"), for: .normal)
		self.setMaximumTrackImage(UIImage(named: "slider-inactive"), for: .normal)
	}
	
	
	@IBInspectable open var trackWidth: CGFloat = 2 {
		didSet {setNeedsDisplay()}
	}
    
	override open func trackRect(forBounds bounds: CGRect) -> CGRect {
		let defaultBounds = super.trackRect(forBounds: bounds)
		
		return CGRect(
			x: defaultBounds.origin.x,
			y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
			width: defaultBounds.size.width,
			height: trackWidth
		)
	}
	
}
