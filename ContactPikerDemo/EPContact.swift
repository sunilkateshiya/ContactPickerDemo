//
//  EPContact.swift
//  ContactPikerDemo
//
//  Created by iFlame on 5/25/17.
//  Copyright © 2017 iFlame. All rights reserved.
//

import UIKit
import Contacts

open class EPContact {
    
    open var firstName: String
    open var lastName: String
    open var company: String
    open var thumbnailProfileImage: UIImage?
    open var profileImage: UIImage?
    open var birthday: Date?
    open var birthdatString: String?
    open var contactId: String?
    open var phoneNumbers = [(phoneNumber: String, phoneLabel: String)]()
    open var emails = [(email: String, emailLabel: String)]()
    
   public init (contact : CNContact){
    firstName = contact.givenName
    lastName = contact.familyName
    company = contact.organizationName
    
    if let thumbnailImageData = contact.thumbnailImageData {
        thumbnailProfileImage = UIImage(data: thumbnailImageData)
    }
    if let imageData = contact.imageData {
        
        profileImage = UIImage(data: imageData)
    }
    if let birthdayDate = contact.birthday {
        birthday = Calendar(identifier: Calendar.Identifier.gregorian).date(from: birthdayDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = EPGlobalConstants.Strings.birthdayDateFormat
        birthdatString = dateFormatter.string(from: birthday!)
    }
    for phoneNumber in contact.phoneNumbers {
        guard let phoneLabel = phoneNumber.label else {continue}
        let phone = phoneNumber.value.stringValue
        
        phoneNumbers.append((phone,phoneLabel))
        
        }
    for emailAddress in contact.emailAddresses {
        guard let emailLabel = emailAddress.label else { continue }
        let email = emailAddress.value as String
        
        emails.append((email,emailLabel))
        
        
    }
    
    
}

    open func displayName() -> String {
        return firstName + " " + lastName
}
    open func contactInitials() -> String{
        var initials = String()
        if let firstNameFirstChar = lastName.characters.first {
            initials.append(firstNameFirstChar)
        }
        if let lastNameFirstChar = lastName.characters.first {
            initials.append(lastNameFirstChar)
        }
        return initials
 }
    
}

