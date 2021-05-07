//
//  OfflineAlertViewController.swift
//
//  Created by Iurii Pleskach on 3/23/18.
//

import UIKit

class OfflineAlertViewController: BaseViewController, Popup {

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        hide(animated: false, completion: nil)
        super.viewWillDisappear(animated)
    }

    // MARK: - Public interface

    func show(in viewController: UIViewController, animated: Bool, closeHandler: KLDCloseHandler?) {
        self.closeHandler = closeHandler

        let containerView = viewController.view!
        containerView.addSubview(view)

        let topMessageLabelMargin = messageLabelBottomConstraint.constant // Top message label margin from the status bar
        let initialTopConstraintHeight: CGFloat = animated ? -view.frame.height - topMessageLabelMargin : 0.0

        topConstraint = view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: initialTopConstraintHeight)
        topConstraint!.isActive = true
        view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true

        if #available(iOS 11, *) {
            let guide = containerView.safeAreaLayoutGuide
            labelConstraint = messageLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: initialTopConstraintHeight + topMessageLabelMargin)
            labelConstraint!.isActive = true
        } else {
            labelConstraint = messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIApplication.shared.statusBarFrame.height + initialTopConstraintHeight + topMessageLabelMargin)
            labelConstraint!.isActive = true
        }

        viewController.addChild(self)
        didMove(toParent: viewController)

        if animated {
            slide(by: -initialTopConstraintHeight)
        }
    }

    func hide(animated: Bool, completion: KLDCloseHandler?) {
        let handler = {
            self.app_removeFromContainerView()
            self.closeHandler?()
            completion?()
        }
        if animated {
            slide(by: -view.frame.size.height, completion: { _ in
                handler()
            })
        } else {
            handler()
        }
    }

    // MARK: - Implementation

    private let animationDuration = 0.3

    private var closeHandler: KLDCloseHandler? = nil
    private var topConstraint: NSLayoutConstraint?
    private var labelConstraint: NSLayoutConstraint?

    @IBOutlet private weak var messageLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageLabel: UILabel!

    @IBAction private func close(_ sender: UIButton) {
        hide(animated: true, completion: nil)
    }

    private func slide(by pixels: CGFloat, completion: ((Bool) -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            self.view.removeConstraint(self.topConstraint!)
            self.topConstraint?.constant += pixels
            self.labelConstraint?.constant += pixels

            UIView.animate(withDuration: self.animationDuration, animations: {
                self.view.superview?.layoutIfNeeded()
            }, completion: completion)
        }
    }
}
