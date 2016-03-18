//
//  MainViewController.swift
//  mememamia
//
//  Created by Timur Ridjanovic on 1/30/16.
//  Copyright © 2016 Timur Ridjanovic. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    private var keyboardHidden = false
    private let topInputDefaultText = "TOP"
    private let bottomInputDefaultText = "BOTTOM"
    private let defaultFontName: String = "Impact"
    private let defaultFontSize: CGFloat = 40.0
    private let defaultStrokeColor = UIColor.blackColor()
    private let defaultForegroundColor = UIColor.whiteColor()
    private let defaultStrokeWidth = -5.0
    private var defaultTextFieldConfig: [String: AnyObject] {
        return [
            NSStrokeColorAttributeName: defaultStrokeColor,
            NSForegroundColorAttributeName: defaultForegroundColor,
            NSFontAttributeName: UIFont(name: defaultFontName, size: defaultFontSize)!,
            NSStrokeWidthAttributeName: defaultStrokeWidth
        ]
    }
    private var topPositionConstraint : NSLayoutConstraint!
    private var bottomPositionConstraint : NSLayoutConstraint!
    private var topWidthConstraint: NSLayoutConstraint!
    private var bottomWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topInput: UITextField!
    @IBOutlet weak var bottomInput: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sharingButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTextFields()
        disableElements([sharingButton, cancelButton])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotification()
        subscribeToOrientationChange()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeFromKeyboardNotification()
    }
    
    @IBAction func cancelButtonEvent(sender: UIBarButtonItem) {
        imageView.image = nil
        initTextFields()
        disableElements([sharingButton, cancelButton])
    }
    
    @IBAction func albumButtonEvent(sender: UIBarButtonItem) {
        pickAnImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func cameraButtonEvent(sender: UIBarButtonItem) {
        pickAnImage(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func shareButtonEvent(sender: UIBarButtonItem) {
        if let image = imageView.image {
            let memedImage = generateMemedImage()
            let nextController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
            nextController.completionWithItemsHandler = { activity, success, items, error in
                if success {
                    let _ = Meme(topText: self.topInput.text!, bottomText: self.bottomInput.text!, image: image, memedImage: memedImage)
                    nextController.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            presentViewController(nextController, animated: true, completion: nil)
        }
    }
    
    private func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        presentViewController(controller, animated: true, completion: nil)
    }
    
    private func getAttributesWithNewFontSize(fontSize: CGFloat) -> [String: AnyObject] {
        return [
            NSStrokeColorAttributeName: defaultStrokeColor,
            NSForegroundColorAttributeName: defaultForegroundColor,
            NSFontAttributeName: UIFont(name: defaultFontName, size: fontSize)!,
            NSStrokeWidthAttributeName: defaultStrokeWidth
        ]
    }
    
    private func generateMemedImage() -> UIImage {
        // Render view to an image
        let imageWidth = (imageView.image?.size.width)!
        let imageHeight = (imageView.image?.size.height)!
        
        let scaleWidth = imageWidth/imageView.frame.size.width
        let scaleHeight = imageHeight/imageView.frame.size.height
        
        let scale = scaleWidth > scaleHeight ? scaleWidth : scaleHeight
        let topFontSize = (topInput.font?.pointSize)! * scale
        let bottomFontSize = (bottomInput.font?.pointSize)! * scale
        
        let topAttributes = getAttributesWithNewFontSize(topFontSize)
        let bottomAttributes = getAttributesWithNewFontSize(bottomFontSize)
        
        let topTextWidth = (topInput.text?.sizeWithAttributes(topAttributes).width)!
        let bottomTextWidth = (bottomInput.text?.sizeWithAttributes(bottomAttributes).width)!
        let bottomTextHeight = (topInput.text?.sizeWithAttributes(bottomAttributes).height)!
        
        let topTextX = imageWidth/2 - topTextWidth/2
        let bottomTextX = imageWidth/2 - bottomTextWidth/2
        let topTextY = imageHeight * 0.1
        let bottomTextY = imageHeight - bottomTextHeight - (imageHeight * 0.1)
    
        UIGraphicsBeginImageContext((imageView.image?.size)!)
        imageView.image?.drawInRect(CGRectMake(0, 0, imageWidth, imageHeight))
        topInput.text?.drawInRect(CGRectMake(topTextX, topTextY, imageWidth, imageHeight), withAttributes: topAttributes)
        bottomInput.text?.drawInRect(CGRectMake(bottomTextX, bottomTextY, imageWidth, imageHeight), withAttributes: bottomAttributes)
        
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    private func initTextFields() {
        setTextFieldProperties(topInput, text: topInputDefaultText, config: defaultTextFieldConfig, alignment: .Center, delegate: memeTextFieldDelegate, clearsOnBeginEditing: true, enabled: false)
        setTextFieldProperties(bottomInput, text: bottomInputDefaultText, config: defaultTextFieldConfig, alignment: .Center, delegate: memeTextFieldDelegate, clearsOnBeginEditing: true, enabled: false)
        layoutTextFields()
    }
    
    private func removeConstraints(constraints: [NSLayoutConstraint!]) {
        constraints.forEach({constraint in
            if let constraint = constraint {
                view.removeConstraint(constraint)
            }
        })
    }
    
    private func layoutTextFields() {
        removeConstraints([topPositionConstraint, topWidthConstraint, bottomPositionConstraint, bottomWidthConstraint])
        
        //Get the position of the image inside the imageView
        let size = imageView.image != nil ? imageView.image!.size : imageView.frame.size
        let frame = AVMakeRectWithAspectRatioInsideRect(size, imageView.bounds)
        
        //A margin for the new constraints; 10% of the frame's height
        let margin = frame.origin.y + frame.size.height * 0.10
        let width = frame.size.width - 10
        
        //Create and add the new constraints
        topPositionConstraint = NSLayoutConstraint(
            item: topInput,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: imageView,
            attribute: .Top,
            multiplier: 1.0,
            constant: margin)
        view.addConstraint(topPositionConstraint)
        
        topWidthConstraint = NSLayoutConstraint(
            item: topInput,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: width
        )
        view.addConstraint(topWidthConstraint)
        
        bottomWidthConstraint = NSLayoutConstraint(
            item: bottomInput,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: width
        )
        view.addConstraint(bottomWidthConstraint)
        
        bottomPositionConstraint = NSLayoutConstraint(
            item: bottomInput,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: imageView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: -margin)
        view.addConstraint(bottomPositionConstraint)
    }

    private func setTextFieldProperties(input: UITextField, text: String, config: [String:AnyObject], alignment: NSTextAlignment, delegate: UITextFieldDelegate, clearsOnBeginEditing: Bool, enabled: Bool) {
        input.defaultTextAttributes = config
        input.text = text
        input.textAlignment = alignment
        input.delegate = delegate
        input.clearsOnBeginEditing = clearsOnBeginEditing
        input.enabled = enabled
    }
    
    private func enableElements(elements: [NSObject]) {
        elements.forEach({el in
            if el.respondsToSelector("setEnabled:") {
                el.setValue(true, forKey: "enabled")
            }
        })
    }
    
    private func disableElements(elements: [NSObject]) {
        elements.forEach({el in
            if el.respondsToSelector("setEnabled:") {
                el.setValue(false, forKey: "enabled")
            }
        })
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomInput.editing && !keyboardHidden {
            keyboardHidden = true
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardHidden {
            keyboardHidden = false
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func updateTextFields(notification: NSNotification) {
        layoutTextFields()
    }
    
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToOrientationChange() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTextFields:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func unsubsribeFromKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        enableElements([topInput, bottomInput, sharingButton, cancelButton])
        layoutTextFields()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

