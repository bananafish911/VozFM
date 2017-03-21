//
//  AboutVC.swift
//  VozFM
//
//  Created by Victor on 11/1/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import UIKit
import MessageUI

class AboutVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var designLabel: UILabel!
    @IBOutlet weak var developLabel: UILabel!
    @IBOutlet weak var feedbackButton: UIButton!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - VC lifecycle
    
    func cinfigureOnLoad() {
        self.title = "Про додаток"
        navigationController?.navigationBar.topItem?.title = "Назад"
        
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Application"
        versionLabel.text?.append(" - версія додатку ")
        if let versionStr = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text?.append(versionStr)
        } else {
            versionLabel.text?.append("[unknown]")
        }
        
        applyAttributedStringLabels()
        // add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cinfigureOnLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Actions

    @IBAction func feedbackButtonTap(_ sender: UIButton) {
//        sendEmail()
        Smooch.show()
    }
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        
        let touchPoint = gesture.location(in: self.view)
        
        if designLabel.containsSuperviewPoint(touchPoint) {
            UIApplication.shared.openURLSafely(Constants.Feedback.designerURL)
        }
        if developLabel.containsSuperviewPoint(touchPoint) {
            UIApplication.shared.openURLSafely(Constants.Feedback.developerURL)
        }
    }
    
    /// Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func labelTapped() {
        //
    }
}

// MARK: - Stuff

extension AboutVC {
    
    func applyAttributedStringLabels() {
        // apply texts
        let attributedString = NSMutableAttributedString()
        let fontSize: CGFloat = 16
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        let blackTextAttr = [ NSForegroundColorAttributeName: UIColor.black,
                              NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        let blueTextAttr = [ NSForegroundColorAttributeName: UIColor.blue,
                             NSFontAttributeName: UIFont.systemFont(ofSize: fontSize) ]

        // design label
        attributedString.append(NSAttributedString(string: "Дизайн: ", attributes: blackTextAttr))
        attributedString.append(NSAttributedString(string: "Dizzzup", attributes: blueTextAttr))
        designLabel.attributedText = attributedString
        
        // developer label
        attributedString.mutableString.setString("")
        attributedString.append(NSAttributedString(string: "Розробка: ", attributes: blackTextAttr))
        attributedString.append(NSAttributedString(string: "Victor Dombrovskiy", attributes: blueTextAttr))
        developLabel.attributedText = attributedString
    }
}
