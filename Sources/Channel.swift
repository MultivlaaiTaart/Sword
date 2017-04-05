//
//  Channel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Generic Channel structure
public protocol Channel {

  // MARK: Properties

  /// Parent class
  weak var sword: Sword? { get }

  /// The id of the channel
  var id: String { get }

  /// The last message's id
  var lastMessageId: String? { get }

  /// Collection of messages mapped by message id
  var messages: [String: Message] { get }

}

public extension Channel {

  // MARK: Functions

  /**
   Adds a reaction (unicode or custom emoji) to message

   - parameter reaction: Unicode or custom emoji reaction
   - parameter messageId: Message to add reaction to
  */
  public func add(reaction: String, to messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createReaction(self.id, messageId, reaction), method: "PUT") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /// Deletes the current channel, whether it be a DMChannel or GuildChannel
  public func delete(then completion: @escaping (RequestError?, Channel?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteChannel(self.id), method: "DELETE") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let data = data as! [String: Any]
        if data["is_private"] != nil {
          completion(nil, DMChannel(self.sword!, data))
        }else {
          completion(nil, GuildChannel(self.sword!, data))
        }
      }
    }
  }

  /**
   Deletes a message from this channel

   - parameter messageId: Message to delete
  */
  public func delete(message messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteMessage(self.id, messageId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Bulk deletes messages

   - parameter messages: Array of message ids to delete
  */
  public func delete(messages: [String], then completion: @escaping (RequestError?) -> () = {_ in}) {
    for message in messages {
      let oldestMessage = (Date().timeIntervalSince1970 - 1421280000000) * 4194304
      guard let messageId = Double(message) else {
        completion(.unknown)
        return
      }
      if messageId < oldestMessage {
        completion(.unknown)
      }
    }

    self.sword!.requester.request(self.sword!.endpoints.bulkDeleteMessages(self.id), body: messages.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Deletes a pinned message from this channel

   - parameter messageId: Pinned message to delete
  */
  public func delete(pinnedMessage messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deletePinnedChannelMessage(self.id, messageId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Deletes a reaction from message by user

   - parameter reaction: Unicode or custom emoji to delete
   - parameter messageId: Message to delete reaction from
   - parameter userId: If nil, deletes bot's reaction from, else delete a reaction from user
  */
  public func delete(reaction: String, from messageId: String, by userId: String? = nil, then completion: @escaping (RequestError?) -> () = {_ in}) {
    var url = ""
    if userId != nil {
      url = self.sword!.endpoints.deleteUserReaction(self.id, messageId, reaction, userId!)
    }else {
      url = self.sword!.endpoints.deleteOwnReaction(self.id, messageId, reaction)
    }

    self.sword!.requester.request(url, method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Edits a message's content

   - parameter messageId: Message to edit
   - parameter content: Text to change message to
  */
  public func edit(message messageId: String, to content: String, then completion: @escaping (RequestError?, Message?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.editMessage(self.id, messageId), body: ["content": content].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Message(self.sword!, data as! [String: Any]))
      }
    }
  }

  /**
   Gets an array of users who used reaction from message

   - parameter reaction: Unicode or custom emoji to get
   - parameter messageId: Message to get reaction users from
  */
  public func get(reaction: String, from messageId: String, then completion: @escaping (RequestError?, [User]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getReactions(self.id, messageId, reaction)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self.sword!, user))
        }

        completion(nil, returnUsers)
      }
    }
  }

  /// Get Pinned messages for this channel
  public func getPinnedMessages(then completion: @escaping (RequestError?, [Message]?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.getPinnedMessages(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self.sword!, message))
        }

        completion(nil, returnMessages)
      }
    }
  }

  /**
   Pins a message to this channel

   - parameter messageId: Message to pin
  */
  public func pin(_ messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.addPinnedChannelMessage(self.id, messageId), method: "PUT") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Sends a message to channel

   - parameter message: Message to send
  */
  public func send(_ message: Any, then completion: @escaping (RequestError?, Message?) -> () = {_ in}) {
    self.sword!.send(message, to: self.id) { error, msg in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, msg)
      }
    }
  }

}
