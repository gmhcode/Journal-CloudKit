//
//  EntryDetailViewController.swift
//  Journal Cloudkit
//
//  Created by Greg Hughes on 12/31/18.
//  Copyright © 2018 Greg Hughes. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    
    @IBOutlet weak var bodyTextView: UITextView!
    
    var entry: Entry?{
        didSet{
            loadViewIfNeeded()
            updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func updateView(){
        titleTextField.text = entry?.title
        bodyTextView.text = entry?.body
    }
    
    
    
    @IBAction func saveEntryButtonTapped(_ sender: Any) {
        
        guard let title = titleTextField.text,
            let body = bodyTextView.text,
            body != "",
            title != "" else {return}
        
        
        if let entry = entry {
            
            EntryController.shared.updateEntry(entry: entry, title: title, body: body) { (success) in
                
                
                if success {
                    
                    print("SUCCESS!, updating entry")
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                    
                else {
                    print("Failure to update entry")
                    
                }
            }
        }
            
        else { EntryController.shared.addEntryWith(title: title, body: body) { (success) in
            
            
            if success{
                
                print("SUCCESS creating new entry")
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                print("Failure creating new entry")
            }
            }
        }
    }
}
