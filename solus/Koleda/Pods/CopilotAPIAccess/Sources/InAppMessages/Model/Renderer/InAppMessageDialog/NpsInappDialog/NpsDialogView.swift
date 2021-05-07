//
//  NpsDialogView.swift
//  CopilotAPIAccess
//
//  Created by Elad on 17/05/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import UIKit
import CopilotLogger

class NpsDialogView: UIView {
    
    //MARK: - outlets
    
    let kCONTENT_XIB_NAME = "NpsDialogView"
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var notLikelyLabel: UILabel!
    @IBOutlet weak var veryLikelyLabel: UILabel!
    @IBOutlet var surveyButtons: [UIButton]!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var seperateView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var thankYouLabel: UILabel!
    
    //MARK: - Consts
    
    private struct Consts {
        
        static let titleFontSize: CGFloat = 18.0
        static let labelsFontSize: CGFloat = 12.0
        static let doneButtonFontSize: CGFloat = 13.0
        static let thankYouButtonFontSize: CGFloat = 18.0
        static let surveyButtonsFontSize: CGFloat = 13.0
        static let buttonBorderWidth: CGFloat = 1.0
        static let buttonBackgroundAlpha: CGFloat = 0.08
        static let textAlpha: CGFloat = 0.54
    }
    
    //MARK: - Properties
    
    var completion: ((String?) -> Void)?
    
    var labelQuestionText: String? {
        didSet {
            titleLabel.text = labelQuestionText
        }
    }
    
    var ctaBackgroundColor: UIColor? {
        didSet {
            guard let ctaBackgroundColor = ctaBackgroundColor else { return }
            surveyButtons.forEach {
                $0.layer.borderColor = ctaBackgroundColor.cgColor
                $0.layer.borderWidth = Consts.buttonBorderWidth
                $0.setBackgroundColor(color: ctaBackgroundColor, forState: .selected)
                $0.setBackgroundColor(color: ctaBackgroundColor.withAlphaComponent(Consts.buttonBackgroundAlpha), forState: .normal)
            }
            selectedCta = nil//Set the bottom buttons
        }
    }
    
    var ctaTextColor: UIColor? {
        didSet {
            surveyButtons.forEach {
                $0.setTitleColor(ctaTextColor, for: .normal)
                $0.setTitleColor(.white, for: .selected)
            }
        }
    }
    
    var bgColor: UIColor? {
        didSet {
            bgView.backgroundColor = bgColor
            selectedCta = nil//Set the bottom buttons
        }
    }
    
    var textColorHex: UIColor? {
        didSet {
            guard let textColorHex = textColorHex else { return }
            titleLabel.textColor = textColorHex
            seperateView.backgroundColor = textColorHex.withAlphaComponent(Consts.textAlpha)
            veryLikelyLabel.textColor = textColorHex.withAlphaComponent(Consts.textAlpha)
            notLikelyLabel.textColor = textColorHex.withAlphaComponent(Consts.textAlpha)
            doneButton.setTitleColor(textColorHex.withAlphaComponent(Consts.textAlpha), for: .normal)
        }
    }
    
    var labelNotLikely: String? {
        didSet {
            notLikelyLabel.text = labelNotLikely
        }
    }
    
    var labelExtremelyLikely: String? {
        didSet {
            veryLikelyLabel.text = labelExtremelyLikely
        }
    }
    
    var labelAskMeAnotherTime: String? {
        didSet {
            doneButton.setTitle(labelAskMeAnotherTime, for: .normal)
        }
    }
    
    var labelDone: String? {
        didSet {
            doneButton.setTitle(labelDone, for: .selected)
        }
    }
    
    var labelThankYou: String? {
        didSet {
            thankYouLabel?.text = labelThankYou
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    private var selectedCta: Int? {
        didSet {
            if selectedCta != nil {
                bottomBackgroundView.backgroundColor = ctaBackgroundColor
                doneButton.isSelected = true
                doneButton.titleLabel?.font = UIFont.SFProTextBoldFont(size: Consts.doneButtonFontSize)
                thankYouLabel.textColor = .white
            }
            else {
                bottomBackgroundView.backgroundColor = bgColor
                doneButton.isSelected = false
                doneButton.titleLabel?.font = UIFont.SFProTextRegularFont(size: Consts.doneButtonFontSize)
                thankYouLabel.textColor = .clear
            }
        }
    }
    
    //MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let viewBundle = Bundle(for: NpsDialogView.self)
        viewBundle.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        
        frame = contentView.frame;
        addSubview(contentView);
        contentView.anchorToSuperview()
        
        setupViews()
        selectedCta = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Survey button corner radii need to be arranged only after laying out
        surveyButtons.forEach {
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
            $0.cornerRadius = $0.bounds.width/2
        }
    }
    
    //MARK: - Private
    
    private func setupViews() {
        
        setupLabelsAppearance()
        setupButtonsAppearance()
    }
    
    private func setupLabelsAppearance() {
        //title label
        titleLabel.font = UIFont.SFProTextBoldFont(size: Consts.titleFontSize)
        
        //bottom labels
        veryLikelyLabel.font = UIFont.SFProTextRegularFont(size: Consts.labelsFontSize)
        
        notLikelyLabel.font = UIFont.SFProTextRegularFont(size: Consts.labelsFontSize)
    }
    
    private func setupButtonsAppearance() {
        
        //survey buttons
        surveyButtons.forEach {
            $0.titleLabel?.font = UIFont.SFProTextRegularFont(size: Consts.surveyButtonsFontSize)
        }
        
        //dismiss button
        doneButton.titleLabel?.font = UIFont.SFProTextRegularFont(size: Consts.doneButtonFontSize)
        doneButton.setTitleColor(.white, for: .selected)
        
        //Thank you label
        thankYouLabel.font = UIFont.SFProTextBoldFont(size: Consts.thankYouButtonFontSize)
        thankYouLabel.textColor = .white
    }
    
    
    //MARK: - Actions
    @IBAction func npsSurveyButtonPressed(_ sender: UIButton) {
        surveyButtons.forEach {
            $0.isSelected = false
        }
        sender.isSelected = true
        selectedCta = sender.tag
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        completion?(selectedCta != nil ? "\(selectedCta ?? 0)" : nil)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        completion?(nil)
    }
}
