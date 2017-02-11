//
//  Events.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Foundation

// MARK: - Event

enum Event : Int {
    /// The default event, represents nothing
    case none
    
    /// The music player has connected
    case connect
    
    /// The music player has disconnected
    case disconnect
    
    /// The music database has been updated
    case database
    
    /// The current queue has been modified
    case queue
    
    /// The music player has been started, stopped or seeked
    case player
    
    /// The volume has been changed
    case volume
    
    /// An option like repeat, random, crossfade, etc. was modified
    case options
}

// MARK: - EventManager

class EventManager {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var subscribers : [EventSubscriber] {
        return _subscribers;
    };
    
    // MARK: Private properties
    
    private var _subscribers : [EventSubscriber] = [];
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    func add(subscriber : EventSubscriber) {
        Logger.log("EventManager: Subscribing to events \"\(subscriber.subscriptions)\" with \(subscriber)");
        
        self._subscribers.append(subscriber);
    }
    
    func remove(subscriber : EventSubscriber) {
        var removalIndex : Int = -1;
        
        for(currentIndex, currentSubscriber) in self._subscribers.enumerated() {
            if(currentSubscriber.uuid == subscriber.uuid) {
                removalIndex = currentIndex;
            }
        }
        
        if(removalIndex != -1) {
            Logger.log("EventManager: Removing event subscriber \(subscriber)");
            
            self._subscribers.remove(at: removalIndex);
        }
        else {
            Logger.log("EventManager: Failed to remove event subscriber \(subscriber), was not subscribed");
        }
    }
    
    func emit(event : Event) {
        Logger.log("EventManager: Emitting event Event.\(event)");
        
        for(_, currentSubscriber) in self.subscribers.enumerated() {
            if(currentSubscriber.subscriptions.contains(event)) {
                currentSubscriber.perform(event: event);
            }
        }
    }
}


// MARK: - EventSubscriber

class EventSubscriber: NSObject {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var subscriptions : [Event] = [];
    var handler : ((Event) -> ())? = nil;
    var uuid : String = NSUUID().uuidString;
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Performs this subscription(called when the subscribed event fires), should be passed the event that fired it
    ///
    /// - Parameter event: The event to say triggered the subscriber
    func perform(event : Event) {
        self.handler?(event);
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(events : [Event], performer : ((Event) -> ())?) {
        self.subscriptions = events;
        self.handler = performer;
        self.uuid = NSUUID().uuidString;
    }
    
    override init() {
        super.init();
        
        self.subscriptions = [];
        self.handler = nil;
        self.uuid = NSUUID().uuidString;
    }
}
