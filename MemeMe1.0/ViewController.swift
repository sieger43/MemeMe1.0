//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by John Berndt on 11/14/18.
//  Copyright © 2018 John Berndt. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageViewOutlet: UIImageView!
 
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    let memeDelegate = MemeTextFieldDelegate()
    
    var theMeme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbarItems?[1] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action:(#selector(ViewController.pickAnImageFromCamera(_:))))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action:(#selector(ViewController.launchActivityView(_:))))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        setupTextField(tf: topTextField)
        setupTextField(tf: bottomTextField)
        
        theMeme = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toolbarItems?[1].isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupTextField(tf: UITextField) {
        tf.defaultTextAttributes = [
            NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
            NSAttributedStringKey.font.rawValue : UIFont(name: "HelveticaNeue-CondensedBlack", size:40)!,
            NSAttributedStringKey.strokeWidth.rawValue : -3.0 as AnyObject
        ]
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.delegate = self
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: AnyObject) {
        chooseImageFromCameraOrPhoto(source: UIImagePickerControllerSourceType.camera)
    }
    
    @IBAction func pickAnImage(_ sender: AnyObject) {
        chooseImageFromCameraOrPhoto(source: UIImagePickerControllerSourceType.photoLibrary)
   }
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func launchActivityView(_ sender: AnyObject) {
        if(imageViewOutlet != nil){
            
            let image = generateMemedImage()
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            activityController.completionWithItemsHandler = { activity, success, items, error in
                if success {
                    //self.save()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTheMeme(_ sender: AnyObject) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        self.imageViewOutlet.image = nil
        self.topTextField.text = nil
        self.bottomTextField.text = nil
        self.theMeme = nil
    }
    
    func generateMemedImage() -> UIImage
    {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
        theMeme = Meme()
        theMeme?.originalImage = self.imageViewOutlet.image
        theMeme?.memedImage = memedImage
        theMeme?.topText = self.topTextField.text
        theMeme?.bottomText = self.bottomTextField.text
        
        return memedImage
    }
    
    func imagePickerController(_ _picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any]){
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageViewOutlet.image = image
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }
            
            dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:))    , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:))    , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
                NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        unsubscribeFromKeyboardNotifications()
        return false
    }
}

