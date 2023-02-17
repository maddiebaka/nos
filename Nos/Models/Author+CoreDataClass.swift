//
//  Author+CoreDataClass.swift
//  Nos
//
//  Created by Matthew Lorentz on 1/31/23.
//
//

import Foundation
import CoreData

@objc(Author)
public class Author: NosManagedObject {
    var npubString: String? {
        guard let hex = hexadecimalPublicKey else {
            return nil
        }
        
        let publicKey = PublicKey(hex: hex)
        return publicKey?.npub
    }
    
    var displayName: String {
        name ?? npubString ?? hexadecimalPublicKey ?? "error"
    }
    
    var isPopulated: Bool {
        let hasName = (name != nil)
        let hasAbout = (about != nil)
        let hasPhoto = (profilePhotoURL != nil)
        
        return hasName || hasAbout || hasPhoto
    }
    
    class func findOrCreate(by pubKey: HexadecimalString, context: NSManagedObjectContext) throws -> Author {
        let fetchRequest = NSFetchRequest<Author>(entityName: String(describing: Author.self))
        fetchRequest.predicate = NSPredicate(format: "hexadecimalPublicKey = %@", pubKey)
        fetchRequest.fetchLimit = 1
        if let author = try context.fetch(fetchRequest).first {
            return author
        } else {
            let author = Author(context: context)
            author.hexadecimalPublicKey = pubKey
            return author
        }
    }
}
