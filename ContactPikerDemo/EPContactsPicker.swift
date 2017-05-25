//
//  EPContactsPicker.swift
//  ContactPikerDemo
//
//  Created by iFlame on 5/25/17.
//  Copyright © 2017 iFlame. All rights reserved.
//

import UIKit
import Contacts

public protocol EPPikerDelegate {
    func epContactPicker(_ : EPContactsPicker, didContactFetchFailed error: NSError)
    func epContactPiker(_ : EPContactsPicker , didCancel error : NSError)
    func epContactPiker(_ : EPContactsPicker, didSelectContact contact : EPContact)
    func epContactpiker(_ : EPContactsPicker, didSelectMultipleContacts contact : [EPContact])
    
}

public extension EPPikerDelegate {
    func epContactPicker(_ : EPContactsPicker, didContactFetchFailed error: NSError) { }
    func epContactPiker(_ : EPContactsPicker , didCancel error : NSError) { }
    func epContactPiker(_ : EPContactsPicker, didSelectContact contact : EPContact) { }
    func epContactpiker(_ : EPContactsPicker, didSelectMultipleContacts contact : [EPContact]) { }
    
}

typealias ContactsHandler = (_ contacts : [CNContact] , _ error : NSError? ) -> Void

public enum SubtitleCellValue {
    case phoneNumber
    case email
    case birthday
    case organization
}


 open class EPContactsPicker: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate{
    
    open var contactDelegate : EPPikerDelegate?
    var contactsStore: CNContactStore?
    var resultSearchController = UISearchController()
    var orderedContacts = [String: [CNContact]]()
    var sortedContactKeys = [String]()
    var selectedContacts = [EPContact]()
    var filteredContacts = [CNContact]()
    var subtitleCellValue = SubtitleCellValue.phoneNumber
    var multiSelectEnabled: Bool = false

    override open  func viewDidLoad() {
        super.viewDidLoad()
        self.title = EPGlobalConstants.Strings.contactTitel
        
        registerContactCell()
        initializeBarButtons()
        initializeSearchBar()
        reloadContacts()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func initializeSearchBar() {
        self.resultSearchController = ( {
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
    }
    func initializeBarButtons(){
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(onTouchDoneButton))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if multiSelectEnabled {
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(onTouchDoneButton))
            self.navigationItem.rightBarButtonItem = doneButton
        }
    }
    fileprivate func registerContactCell() {
        let podBundel = Bundle(for: self.classForCoder)
        if let bundelURL = podBundel.url(forResource: EPGlobalConstants.Strings.BumdelIdentifier, withExtension: "Bundel") {
            if let bundel = Bundle(url: bundelURL) {
                
                let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: bundel)
                tableView.register(cellNib, forCellReuseIdentifier: "Cell")
            }
            else
            {
                assertionFailure("Could Not load Bundel")
            }
        }
        else
        {
            let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: "Cell")
        }
        
    }
        
        
        
    override open  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    convenience public init(delegate : EPPikerDelegate?){
        self.init(delegate: delegate, multiSelection: false)
    }
    convenience public init(delegate: EPPikerDelegate?, multiSelection : Bool) {
        self.init(style : .plain)
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
    }
    
    convenience public init(delegate: EPPikerDelegate?, multiSelection: Bool, subtitleCellType: SubtitleCellValue){
        self.init(style: .plain)
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
        subtitleCellValue = subtitleCellType
    }
    open func reloadContacts() {
        getContacts({ (contacts , error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    
                    self.tableView.reloadData()
                })
            }
        })
    
    }
        
        func getContacts(_ comletion: @escaping ContactsHandler) {
            if contactsStore == nil {
                contactsStore = CNContactStore()
            }
            let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo:[NSLocalizedDescriptionKey: "No Contact Access"])
            switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
            case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
                
                
                let  productName = Bundle.main.infoDictionary!["CFBundelName"]!
                
                let alert = UIAlertController(title: "Unable to acess Contact", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                    self.contactDelegate?.epContactPicker(self, didContactFetchFailed: error)
                    comletion([], error)
                    self.dismiss(animated: true, completion: nil)
                    
                })
                alert.addAction(okAction)
                self.dismiss(animated: true, completion: nil)
            case CNAuthorizationStatus.notDetermined:
                
                contactsStore?.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
                    
                    if(!granted) {
                        DispatchQueue.main.async(execute: { () -> Void in  comletion([], error! as NSError?)
                        })
                    }
                
            
                    else {
                        self.getContacts(comletion)
                    
                }
        })
                
            case CNAuthorizationStatus.authorized:
                
                var contactArray = [CNContact]()
                
                let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKey())
                
                do {
                    try contactsStore?.enumerateContacts(with:contactFetchRequest, usingBlock:{ (contact, stop) -> Void in
                        
                        contactArray.append(contact)
                        
                        var key: String = "#"
                        
                        if let firstLetter = contact.givenName[0..<1] , firstLetter.containAlphabets(){
                            key = firstLetter.uppercased()
                        
                        }
                        var contacts = [CNContact]()
                        
                        if let segretedContact = self.orderedContacts[key] {
                            contacts = segretedContact
                        }
                        contacts.append(contact)
                        self.orderedContacts[key] = contacts
                    
                    })
                    self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if   self.sortedContactKeys.first == "#" {
                        self.sortedContactKeys.removeFirst()
                        self.sortedContactKeys.append("#")
                    }
                    comletion(contactArray, nil)
                    
                    
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
    }
    
    func allowedContactKey() -> [CNKeyDescriptor] {
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
        
    }

    // MARK: - Table view data source

    override open  func numberOfSections(in tableView: UITableView) -> Int {
        if resultSearchController.isActive{
            return 1
        }
        
        return sortedContactKeys.count
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive{
            return filteredContacts.count
        }
        if let contactForSection = orderedContacts[sortedContactKeys[section]] {
            return contactForSection.count
        }
        return 0
    }

    
    override open  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EPContactCell

       cell.accessoryType = UITableViewCellAccessoryType.none
        let contact : EPContact
        if resultSearchController.isActive{
            contact = EPContact(contact: filteredContacts[(indexPath as NSIndexPath).row])
        } else {
            guard let contactsForSection = orderedContacts[sortedContactKeys[(indexPath as NSIndexPath).section]] else {
                assertionFailure()
                return UITableViewCell()
            }
            
            contact = EPContact(contact: contactsForSection[(indexPath as NSIndexPath).row])
        }
        
        if multiSelectEnabled  && selectedContacts.contains(where: { $0.contactId == contact.contactId }) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        cell.updateContactsinUI(contact, indexpath: indexPath, subtitleType: subtitleCellValue)
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! EPContactCell
        let selectedContact =  cell.contact!
        if multiSelectEnabled {
            //Keeps track of enable=ing and disabling contacts
            if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
                cell.accessoryType = UITableViewCellAccessoryType.none
                selectedContacts = selectedContacts.filter(){
                    return selectedContact.contactId != $0.contactId
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                selectedContacts.append(selectedContact)
            }
        }
        else {
            //Single selection code
            resultSearchController.isActive = false
            self.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    self.contactDelegate?.epContactPiker(self, didSelectContact: selectedContact)
                }
            })
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if resultSearchController.isActive { return 0 }
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top , animated: false)
        return sortedContactKeys.index(of: title)!
    }
    
    override  open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if resultSearchController.isActive { return nil }
        return sortedContactKeys
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.isActive { return nil }
        return sortedContactKeys[section]
    }
    
    // MARK: - Button Actions
    
    func onTouchCancelButton() {
        contactDelegate?.epContactPicker(self, didContactFetchFailed: NSError(domain: "EPContactPickerErrorDomain", code: 2, userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
        dismiss(animated: true, completion: nil)
    }
    
    func onTouchDoneButton() {
        contactDelegate?.epContactpiker(self, didSelectMultipleContacts: selectedContacts)
       
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Search Actions
    
    open func updateSearchResults(for searchController: UISearchController)
    {
        if let searchText = resultSearchController.searchBar.text , searchController.isActive {
            
            let predicate: NSPredicate
            if searchText.characters.count > 0 {
                predicate = CNContact.predicateForContacts(matchingName: searchText)
            } else {
                predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactsStore!.defaultContainerIdentifier())
            }
            
            let store = CNContactStore()
            do {
                filteredContacts = try store.unifiedContacts(matching: predicate,
                                                             keysToFetch: allowedContactKey())
                //print("\(filteredContacts.count) count")
                
                self.tableView.reloadData()
                
            }
            catch {
                print("Error!")
            }
        }
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
}
