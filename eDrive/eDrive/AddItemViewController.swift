//
//  AddItemViewController.swift
//  eDrive
//
//  Created by Kata on 26/11/16.
//  Copyright © 2016 Kata. All rights reserved.
//

import UIKit

protocol AddItemViewControllerDelegate{
    // Called when the user presses the Send button to issue sending the message
    func addItemViewControllerDidSend(_ viewController: AddItemViewController)
    
    // Called when the user presses the Cancel button to cancel the message composer
    func addItemViewControllerDidCancel(_ viewController: AddItemViewController)
}

class AddItemViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var latText: UITextField!
    @IBOutlet weak var placeText: UITextField!
    
    var delegate: AddItemViewControllerDelegate?
    @IBOutlet weak var longText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CancelTap(_ sender: AnyObject) {
        delegate?.addItemViewControllerDidCancel(self)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func AddTap(_ sender: AnyObject) {
        delegate?.addItemViewControllerDidSend(self)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    
    @IBAction func textFieldDidEndOnExit(_ sender: AnyObject) {
        _ = sender.resignFirstResponder()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - UITextViewDelegate
extension AddItemViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Hide the keyboard when the user presses the return key
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
}
