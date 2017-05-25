//
//  EPContactCell.swift
//  ContactPikerDemo
//
//  Created by iFlame on 5/25/17.
//  Copyright © 2017 iFlame. All rights reserved.
//

import UIKit

class EPContactCell: UITableViewCell {
    @IBOutlet weak var contactTextLabel: UILabel!
    @IBOutlet weak var contactDetailTextLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactInitialLabel: UILabel!
    @IBOutlet weak var contactContainerView: UIView!
    
    var contact : EPContact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.none
        contactContainerView.layer.masksToBounds = true
        contactContainerView.layer.cornerRadius = contactContainerView.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateInitialsColorForIndexPath(_ indexpath: IndexPath) {
        let colorArray = [EPGlobalConstants.Colors.amethystColor,EPGlobalConstants.Colors.asbestosColor,EPGlobalConstants.Colors.emeraIdColor,EPGlobalConstants.Colors.peterRiverColor,EPGlobalConstants.Colors.pomegranateColor,EPGlobalConstants.Colors.pumpkinColor,EPGlobalConstants.Colors.sunflowerColor]
        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
        contactInitialLabel.backgroundColor = colorArray[randomValue]
        
    }
    func updateContactsinUI( _ contact : EPContact, indexpath: IndexPath,subtitleType: SubtitleCellValue) {
        self.contact = contact
        self.contactDetailTextLabel.text = contact.displayName()
        updateSubtitleBasedonType(subtitleType, contact: contact)
        if contact.thumbnailProfileImage != nil {
            self.contactImageView.image = contact.thumbnailProfileImage
            self.contactImageView.isHidden = false
            self.contactInitialLabel.isHidden = true
        }else {
            self.contactInitialLabel.text = contact.contactInitials()
            updateInitialsColorForIndexPath(indexpath)
            self.contactImageView.isHidden = true
            self.contactInitialLabel.isHidden = false
        }
        
    }
        
        
        
        func updateSubtitleBasedonType(_ subtitleType: SubtitleCellValue, contact : EPContact) {
        
        switch subtitleType {
        case SubtitleCellValue.phoneNumber:
            let phoneNumberCount = contact.phoneNumbers.count
           
          if  phoneNumberCount == 1 {
                self.contactDetailTextLabel.text = EPGlobalConstants.Strings.phoneNumberNotAvailable
            }
        case SubtitleCellValue.email :
            let emailCount = contact.emails.count
            
            if emailCount > 1 {
                self.contactDetailTextLabel.text = "\(contact.emails[0].email)"
            }
            else if emailCount > 1 {
                self.contactDetailTextLabel.text = "\(contact.emails[0].email) and \(contact.emails.count-1) more"
            }
            else {
                self.contactDetailTextLabel.text = EPGlobalConstants.Strings.imailNotAvailable
            }
        case SubtitleCellValue.birthday:
            self.contactDetailTextLabel.text = contact.birthdatString
        case SubtitleCellValue.organization:
            self.contactDetailTextLabel.text = contact.company
        }
    }
    
}
