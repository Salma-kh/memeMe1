//
//  ViewController.swift
//  memeMe last draft
//
//  Created by salma apple on 11/24/18.
//  Copyright © 2018 Udacity. All rights reserved.
//
import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    //set the iboutlets
    @IBOutlet weak var NavBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //disabled cameraButton when app is run on devices without a camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        //Setting the attributes for texts field
        setattributes(textField: topText)
        setattributes(textField: bottomText)
//     set dalegate for text
        topText.delegate = self
        bottomText.delegate = self
    }
    //    Make the text field blank when user start typing
    func textFieldDidBeginEditing(_ topField: UITextField) {
        if topField.text=="TOP" || topField.text=="BOTTOM" {
            topField.text = ""
        }
    }
    
    //function to the return button
    func textFieldShouldReturn(_ topField: UITextField) -> Bool {
        topField.resignFirstResponder()
        return true;
        
    }
    // text attributes
    let textattributes:[NSAttributedString.Key: Any] = [
    NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.strokeColor: UIColor.black,
    NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 40)!,
    NSAttributedString.Key.strokeWidth: -2]

    func setattributes(textField: UITextField)
    {
        textField.defaultTextAttributes = textattributes
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = UITextField.BorderStyle.none
    }
    
    //struct to store text fields, image selected and the meme image
    struct Memeattr {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var selectedImage: UIImage
        
    }
    func chooseImageFromCameraOrPhoto(sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated:true, completion:nil)
    }
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
         chooseImageFromCameraOrPhoto(sourceType: .camera)
    }

 // pick image from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        chooseImageFromCameraOrPhoto(sourceType: .photoLibrary)
    }
    //image settings
    func imagePickerController(_ image: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: Any) {
        imageView.image = nil
        topText.text="TOP"
        bottomText.text="BOTTOM"
        shareButton.isEnabled=false

    }
    //nav and tool bar status
    func configureBars(_ isHidden: Bool) {
        toolBar.isHidden = isHidden
        NavBar.isHidden = isHidden

    }

    // method to create the meme
    func createMeme() -> UIImage {
        
        //to hide toolbar and navigation bar
        configureBars(true)

        //Combining the image and the text fields
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //show the toolbar and navigation bar
        configureBars(false)
        return memeImage
    }
    
    //Save the meme
    func save() {
        let memedImage = createMeme()
        _ = Memeattr(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, selectedImage: memedImage)
    }
    
    // create share meme function
    @IBAction func shareMeme(_ sender: Any) {
        let memeImage = createMeme()
        let controller2 = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        controller2.completionWithItemsHandler = { activity, completed, items, error in
            if completed{
                //Save the image
                self.save()
                //To dismiss view controller2
                self.dismiss(animated: true, completion: nil)
           }
            
            //present the shareMeme
            self.present(controller2, animated: true, completion: nil)
        }
        
    }
  override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:  UIWindow.keyboardWillHideNotification , object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name:  UIWindow.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromHideKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name:  UIWindow.keyboardWillHideNotification, object: nil)
    }
    
     @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
}


