//
//  ViewController.swift
//  ContactPikerDemo
//
//  Created by iFlame on 5/25/17.
//  Copyright © 2017 iFlame. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EPPikerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTouchShowMeContactsButton(_ sender: Any) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection: true, subtitleCellType: SubtitleCellValue.email)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        self.present(navigationController, animated: true , completion : nil)
    }
    
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error: NSError) {
        print("Failed with error\(error.description)")
    }
    func epContactPiker(_: EPContactsPicker, didSelectContact contact: EPContact) {
        print("Contact\(contact.displayName()) has been selected")
    }
    func epContactPiker(_: EPContactsPicker, didCancel error: NSError) {
        print("User canceled the selection")
    }
    func epContactpiker(_: EPContactsPicker, didSelectMultipleContacts contact: [EPContact]) {
        print("The following contacts are selected")
        for contact in contact {
            print("\(contact.displayName())")
      }

   }

}

