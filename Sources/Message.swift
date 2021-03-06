//
//  Message.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Message Type
public struct Message {

  // MARK: Properties

  /// Array of Attachment structs that was sent with the message
  public internal(set) var attachments: [Attachment] = []

  /// User struct of the author (not returned if webhook)
  public let author: User?

  /// Content of the message
  public let content: String

  /// Channel struct of the message
  public let channel: Channel

  /// If message was edited, this is the time it happened
  public let editedTimestamp: Date?

  /// Array of embeds sent with message
  public internal(set) var embeds: [Embed] = []

  /// Message ID
  public let id: String

  /// Whether or not this message mentioned everyone
  public let isEveryoneMentioned: Bool

  /// Whether or not this message is pinned in it's channel
  public let isPinned: Bool

  /// Whether or not this messaged was ttsed
  public let isTts: Bool

  /// Member struct for message
  public private(set) var member: Member?

  /// Array of Users that were mentioned
  public internal(set) var mentions: [User] = []

  /// Array of Roles that were mentioned
  public internal(set) var mentionedRoles: [Role] = []

  /// Array of reactions with message
  public internal(set) var reactions: [[String: Any]] = []

  /// Time when message was sent
  public let timestamp: Date

  /// If message was sent by webhook, this is that webhook's ID
  public let webhookId: String?

  // MARK: Initializer

  /**
   Creates Message struct

   - parameter sword: Parent class to get guilds from
   - parameter json: JSON representable as a dictionary
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    let attachments = json["attachments"] as! [[String: Any]]
    for attachment in attachments {
      self.attachments.append(Attachment(attachment))
    }

    if json["webhook_id"] == nil {
      self.author = User(sword, json["author"] as! [String: Any])
    }else {
      self.author = nil
    }

    self.content = json["content"] as! String

    let guild = sword.getGuild(for: json["channel_id"] as! String)
    if guild != nil {
      self.channel = guild!.channels[json["channel_id"] as! String]!
    }else {
      self.channel = DMChannel(sword, ["id": json["channel_id"] as! String])
    }

    if let editedTimestamp = json["edited_timestamp"] as? String {
      self.editedTimestamp = editedTimestamp.date
    }else {
      self.editedTimestamp = nil
    }

    let embeds = json["embeds"] as! [[String: Any]]
    for embed in embeds {
      self.embeds.append(Embed(embed))
    }

    self.id = json["id"] as! String

    if json["webhook_id"] == nil {
      for (_, guild) in sword.guilds {
        if guild.channels[self.channel.id] != nil {
          self.member = guild.members[self.author!.id]
          break
        }
      }
    }else {
      self.member = nil
    }

    self.isEveryoneMentioned = json["mention_everyone"] as! Bool

    let mentions = json["mentions"] as! [[String: Any]]
    for mention in mentions {
      self.mentions.append(User(sword, mention))
    }

    let mentionedRoles = json["mention_roles"] as! [String]
    for mentionedRole in mentionedRoles {
      self.mentionedRoles.append((self.channel as! GuildChannel).guild!.roles[mentionedRole]!)
    }

    if let reactions = json["reactions"] as? [[String: Any]] {
      self.reactions = reactions
    }
    self.isPinned = json["pinned"] as! Bool
    self.timestamp = (json["timestamp"] as! String).date
    self.isTts = json["tts"] as! Bool
    self.webhookId = json["webhook_id"] as? String
  }

  // MARK: Functions

  /**
   Adds a reaction to self

   - parameter reaction: Either unicode or custom emoji to add to this message
  */
  public func add(reaction: String, completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.add(reaction: reaction, to: self.id, completion: completion)
  }

  /// Deletes self
  public func delete(completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.delete(message: self.id, completion: completion)
  }

  /**
   Deletes reaction from self

   - parameter reaction: Either unicode or custom emoji reaction to remove
   - parameter userId: If nil, delete from self else delete from userId
  */
  public func delete(reaction: String, from userId: String? = nil, completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.delete(reaction: reaction, from: self.id, by: userId ?? nil, completion: completion)
  }

  /// Deletes all reactions from self
  public func deleteReactions(completion: @escaping (RequestError?) -> () = {_ in}) {
    guard let channel = self.channel as? GuildChannel else {
      return
    }

    channel.deleteReactions(from: self.id, completion: completion)
  }

  /**
   Edit self's content

   - parameter content: Content to edit from self
  */
  public func edit(to content: String, completion: @escaping (RequestError?, Message?) -> () = {_ in}) {
    self.channel.edit(message: self.id, to: content, completion: completion)
  }

  /**
   Get array of users from reaction

   - parameter reaction: Either unicode or custom emoji reaction to get users from
  */
  public func get(reaction: String, completion: @escaping (RequestError?, [User]?) -> ()) {
    self.channel.get(reaction: reaction, from: self.id, completion: completion)
  }

  /// Pins self
  public func pin(completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.pin(self.id, completion: completion)
  }

  /**
   Replies to message (alias to bot.send(_:to:)...)
  */
  public func reply(with message: String, completion: @escaping (RequestError?, Message?) -> () = {_ in}) {
    self.channel.send(message) { error, msg in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, msg)
      }
    }
  }

}

/// Attachment Type
public struct Attachment {

  // MARK: Properties

  /// The filename for this Attachment
  public let filename: String

  /// Height of image (if image)
  public let height: Int?

  /// ID of attachment
  public let id: String

  /// The proxied URL for this attachment
  public let proxyUrl: String

  /// Size of the file in bytes
  public let size: Int

  /// The original URL of the attachment
  public let url: String

  /// Width of image (if image)
  public let width: Int?

  // MARK: Initializer

  /**
   Creates an Attachment struct

   - parameter json: JSON to decode into Attachment struct
  */
  init(_ json: [String: Any]) {
    self.filename = json["filename"] as! String
    self.height = json["height"] as? Int
    self.id = json["id"] as! String
    self.proxyUrl = json["proxy_url"] as! String
    self.size = json["size"] as! Int
    self.url = json["url"] as! String
    self.width = json["width"] as? Int
  }

}

/// Embed Type
public struct Embed {

  // MARK: Properties

  /// Author dictionary from embed
  public let author: [String: Any]?

  /// Side panel color of embed
  public let color: Int?

  /// Description of the embed
  public let description: String?

  /// Fields for the embed
  public let fields: [[String: Any]]?

  /// Footer dictionary from embed
  public let footer: [String: Any]?

  /// Image data from embed
  public let image: [String: Any]?

  /// Provider from embed
  public let provider: [String: Any]?

  /// Thumbnail data from embed
  public let thumbnail: [String: Any]?

  /// Title of the embed
  public let title: String?

  /// Type of embed
  public let type: String

  /// URL of the embed
  public let url: String?

  /// Video data from embed
  public let video: [String: Any]?

  // MARK: Initializer

  /**
   Creates Embed struct

   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.author = json["author"] as? [String: Any]
    self.color = json["color"] as? Int
    self.description = json["description"] as? String
    self.fields = json["fields"] as? [[String: Any]]
    self.footer = json["footer"] as? [String: Any]
    self.image = json["image"] as? [String: Any]
    self.provider = json["provider"] as? [String: Any]
    self.thumbnail = json["thumbnail"] as? [String: Any]
    self.title = json["title"] as? String
    self.type = json["type"] as! String
    self.url = json["url"] as? String
    self.video = json["video"] as? [String: Any]
  }

}
