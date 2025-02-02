//
//  EventReference+CoreDataClass.swift
//  Nos
//
//  Created by Shane Bielefeld on 2/22/23.
//

import Foundation
import CoreData

/// Tag markers for event references that describe what type of reference this is. 
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md)
enum EventReferenceMarker: String {
    
    /// Marks the event being replied to.
    case reply
    
    /// Marks the event at the root of the reply chain. 
    case root
    
    /// Marks a quoted or reposted event.
    case mention
}

@objc(EventReference)
public class EventReference: NosManagedObject {
    
    var jsonRepresentation: [String] {
        ["e", referencedEvent?.identifier ?? "", recommendedRelayUrl ?? "", marker ?? ""]
    }
    
    var type: EventReferenceMarker? {
        marker.unwrap { EventReferenceMarker(rawValue: $0) }
    }
    
    /// Retreives all the EventReferences whose referencing Event has been deleted.
    static func orphanedRequest() -> NSFetchRequest<EventReference> {
        let fetchRequest = NSFetchRequest<EventReference>(entityName: "EventReference")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \EventReference.eventId, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "referencingEvent = nil")
        return fetchRequest
    }
    
    convenience init(jsonTag: [String], context: NSManagedObjectContext) throws {
        guard jsonTag[safe: 0] == "e",
            let eventID = jsonTag[safe: 1] else {
            throw EventError.invalidETag(jsonTag)
        }
        self.init(context: context)
        referencedEvent = try Event.findOrCreateStubBy(id: eventID, context: context)
        eventId = eventID
        recommendedRelayUrl = jsonTag[safe: 2]
        marker = jsonTag[safe: 3]
    }
}
