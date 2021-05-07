//
//  UnderlineTextField.swift
//  Koleda
//
//  Created by Oanh tran on 5/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class UnderlineTextField: UITextField {
    // WARNING!!! iOS 11 calls textRect(forBounds:) before init(coder:) finishes.
    private var titleLabel: UILabel?
    private var lineView: UIView?
    private var errorLabel: UILabel?
    
    var accessoryView : UIView? {
        willSet {
            accessoryView?.removeFromSuperview()
        }
        didSet {
            guard let accessoryView = accessoryView else {
                return
            }
            addSubview(accessoryView)
            accessoryView.frame = accessoryViewRectForBounds(bounds)
            accessoryView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    var accessoryViewWidth : CGFloat? {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    var tapHandler : ((UnderlineTextField) -> Void)? {
        didSet {
            if tapHandler == nil {
                tapView?.removeFromSuperview()
            } else if tapView == nil {
                let view = UIView(frame: bounds)
                tapView = view
                tapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
                tapView?.backgroundColor = UIColor.clear
                tapView?.addGestureRecognizer(tapGesture)
                addSubview(view)
            }
        }
    }
    private var isErrorVisible = false
    private var tapView : UIView?
    
    func showError(_ show: Bool, _ animated: Bool = true) {
        
        if isErrorVisible == show {
            return
        }
        
        isErrorVisible = show
        updateLineColor()
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.1, options: [], animations: {
            self.frame.size.height = self.intrinsicContentSize.height
            
            self.setupSubviewsFrame()
            
            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    // MARK: - Helpers
    
    func setAccessoryImage(image: UIImage?) {
        if let imageView = accessoryView as? UIImageView {
            imageView.image = image
            return
        }
        
        if image == nil {
            accessoryView = nil
            return
        }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        accessoryView = imageView
    }
    
    // MARK: - Error IBInspectable
    
    @IBInspectable
    var errorText: String? {
        set {
            errorLabel?.text = newValue
        }
        get {
            return errorLabel?.text
        }
    }
    
    @objc var errorFont: UIFont = .app_FuturaPTBook(ofSize: 10) {
        didSet { updateErrorLabel() }
    }
    
    @IBInspectable
    var errorColor: UIColor = .red {
        didSet {
            errorLabel?.textColor = errorColor
        }
    }
    
    // MARK: - Title IBInspectable
    
    @IBInspectable
    public var leftSpacer:CGFloat {
        get {
            return leftView.map{ $0.frame.size.width } ?? 0
        } set {
            leftViewMode = .always
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
        }
    }
    
    @IBInspectable
    public var rightSpacer:CGFloat {
        get {
            return rightView.map{ $0.frame.size.width } ?? 0
        } set {
            rightViewMode = .always
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
        }
    }
    
    @IBInspectable
    var titleToTextFieldSpacing: CGFloat = 8 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var lineToTextFieldSpacing: CGFloat = 0 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var errorToLineSpacing: CGFloat = 4 {
        didSet {
            updateErrorLabel()
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var showTitle: Bool = true {
        didSet { updateTitleLabel() }
    }
    
    @IBInspectable
    var titleText: String? {
        didSet { updateTitleLabel() }
    }
    
    @objc var titleFont: UIFont = .app_FuturaPTDemi(ofSize: 15) {
        didSet { updateTitleLabel() }
    }
    
    @IBInspectable
    var titleColor: UIColor = .gray {
        didSet { updateTitleColor() }
    }
    
    @IBInspectable
    var selectedTitleColor: UIColor = .blue {
        didSet { updateTitleColor() }
    }
    
    // MARK: - Line IBInspectable
    
    @IBInspectable
    var selectedLineHeight: CGFloat = 1.0 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var lineHeight: CGFloat = 0.5 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var lineColor: UIColor = .lightGray {
        didSet { updateLineColor() }
    }
    
    @IBInspectable
    var selectedLineColor: UIColor = .black {
        didSet { updateLineColor() }
    }
    
    @IBInspectable
    var errorLineColor: UIColor = .red {
        didSet { updateLineColor() }
    }
}

// MARK: - Overrides

extension UnderlineTextField {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        borderStyle = .none
        updateControl()
        
        invalidateIntrinsicContentSize()
    }
    
    override var isHighlighted: Bool {
        didSet { updateControl() }
    }
    
    override var isSelected: Bool {
        didSet { updateControl() }
    }
    
    override var isEnabled: Bool {
        didSet { updateControl() }
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateControl()
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateControl()
        return result
    }
    
    override var intrinsicContentSize: CGSize {
        var intristicSize = super.intrinsicContentSize
        
        intristicSize.height = titleHeight + textHeight + titleToTextFieldSpacing + lineToTextFieldSpacing + max(selectedLineHeight, lineHeight) + (isErrorVisible ? errorHeight + errorToLineSpacing : 0)
        
        return intristicSize
    }
    
    // MARK: - UITextField positioning overrides
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        let titleHeight = self.titleHeight
        
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight + titleToTextFieldSpacing,
            width: superRect.width - (accessoryViewWidth ?? accessoryView?.frame.width ?? 0),
            height: superRect.height - titleHeight - max(selectedLineHeight, lineHeight) - lineToTextFieldSpacing - titleToTextFieldSpacing - (isErrorVisible ? errorHeight + errorToLineSpacing : 0)
        )
        return rect
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        let titleHeight = self.titleHeight
        
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight + titleToTextFieldSpacing,
            width: superRect.size.width - (accessoryViewWidth ?? accessoryView?.frame.size.width ?? 0),
            height: textHeight
        )
        return rect
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds:bounds)
    }
}

// MARK: - Updates

fileprivate extension UnderlineTextField {
    
    var isEditingOrSelected: Bool {
        return super.isEditing || isSelected
    }
    
    func updateColors() {
        updateLineColor()
        updateTitleColor()
    }
    
    func updateControl() {
        updateColors()
        updateLineView()
        updateTitleLabel()
    }
    
    func updateTitleColor() {
        titleLabel?.textColor = (isEditingOrSelected || isHighlighted) ? selectedTitleColor : titleColor
    }
    
    func updateLineView() {
        lineView?.frame = lineViewRectForBounds(bounds, editing: isEditingOrSelected)
        updateLineColor()
    }
    
    func updateTitleLabel() {
        titleLabel?.isHidden = nil == titleText
        titleLabel?.text = titleText
        titleLabel?.font = titleFont
        titleLabel?.frame = titleLabelRectForBounds(bounds)
    }
    
    func updateErrorLabel() {
        errorLabel?.text = errorText
        errorLabel?.font = errorFont
        errorLabel?.frame = errorLabelRectForBounds(bounds)
    }
    
    func updateLineColor() {
        if isErrorVisible {
            lineView?.backgroundColor = errorLineColor
        } else {
            lineView?.backgroundColor = isEditingOrSelected ? selectedLineColor : lineColor
        }
    }
}

// MARK: -

fileprivate extension UnderlineTextField {
    
    func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let height = editing ? selectedLineHeight : lineHeight
        return CGRect(x: 0,
                      y: bounds.height - height - (isErrorVisible ? errorHeight + errorToLineSpacing : 0),
                      width: bounds.width,
                      height: height)
    }
    
    func titleLabelRectForBounds(_ bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.size.width, height: titleHeight)
    }
    
    func errorLabelRectForBounds(_ bounds: CGRect) -> CGRect {
        return CGRect(x: 0,
                      y: bounds.height - (isErrorVisible ? errorHeight : 0),
                      width: bounds.size.width,
                      height: errorHeight)
    }
    
    func accessoryViewRectForBounds(_ bounds: CGRect) -> CGRect {
        let height = editingRect(forBounds: bounds).height
        let intrinsicWidth = accessoryView?.intrinsicContentSize.width ?? -1
        let width = accessoryViewWidth ?? ( intrinsicWidth >= 0 ? intrinsicWidth : height)
        return CGRect(x: bounds.width - width,
                      y: titleHeight + titleToTextFieldSpacing,
                      width: width,
                      height: height)
    }
    
    var titleHeight: CGFloat {
        guard let titleLabel = self.titleLabel else {
            return 0
        }
        
        return showTitle ? titleLabel.intrinsicContentSize.height : 0
    }
    
    var errorHeight: CGFloat {
        guard let errorLabel = self.errorLabel,
            let font = errorLabel.font else {
                return 10.0
        }
        
        return height(string: errorLabel.text ?? " ", withConstrainedWidth: bounds.size.width, font: font)
    }
    
    var textHeight: CGFloat {
        guard let font = font else { return 0.0 }
        let heightMargin : CGFloat = 7.0
        return font.lineHeight + heightMargin
    }
    
    private func height(string: String, withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
}

// MARK: - Initial setup

private extension UnderlineTextField {
    func initialSetup() {
        borderStyle = .none
        clipsToBounds = true
        
        let titleLabel = createTitleLabel()
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        setupDefaultLineHeight()
        
        let lineView = createLineView()
        lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(lineView)
        self.lineView = lineView
        
        let errorLabel = createErrorLabel()
        errorLabel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(errorLabel)
        self.errorLabel = errorLabel
        
        setupSubviewsFrame()
        
        updateColors()
        
        addEditingChangedObserver()
    }
    
    func setupSubviewsFrame() {
        guard let titleLabel = self.titleLabel,
            let lineView = self.lineView,
            let errorLabel = self.errorLabel else
        {
            assertionFailure()
            return
        }
        
        titleLabel.frame = titleLabelRectForBounds(bounds)
        lineView.frame = lineViewRectForBounds(bounds, editing: isEditingOrSelected)
        accessoryView?.frame = accessoryViewRectForBounds(bounds)
        errorLabel.frame = errorLabelRectForBounds(bounds)
    }
    
    func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        
        titleLabel.font = titleFont
        titleLabel.textColor = titleColor
        return titleLabel
    }
    
    func createLineView() -> UIView {
        let lineView = UIView()
        lineView.isUserInteractionEnabled = false
        return lineView
    }
    
    func createErrorLabel() -> UILabel {
        let label = UILabel()
        label.font = errorFont
        label.textColor = errorColor
        label.numberOfLines = 0
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    func addEditingChangedObserver() {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged() {
        updateControl()
        updateTitleLabel()
    }
    
    func setupDefaultLineHeight() {
        let onePixel: CGFloat = 1.0 / UIScreen.main.scale
        lineHeight = 2.0 * onePixel
        selectedLineHeight = 2.0 * lineHeight
    }
    
    @objc private func tap(_ sender: UITapGestureRecognizer) {
        tapHandler?(self)
    }
}
