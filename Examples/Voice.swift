import Sword

let bot = Shield(token: "Super secret token here")

bot.register("join") { msg, args in
  guard let member = msg.member, let guild = member.guild else {
    msg.reply(with: "Command only usable in group channels")
    return
  }

  guard let voicestate = guild.voiceStates[member.user.id] else {
    msg.reply(with: "User is not in voice channel.")
    return
  }

  bot.join(voiceChannel: voicestate.channelId) { connection in
    connection.play(Youtube("https://www.youtube.com/watch?v=dQw4w9WgXcQ"))
  }
}

bot.register("leave") { msg, args in
  guard let member = msg.member, let guild = member.guild else {
    msg.reply(with: "Command only usable in group channels")
    return
  }

  guard let voicestate = guild.voiceStates[member.user.id] else {
    msg.reply(with: "User is not in voice channel.")
    return
  }

  bot.leave(voiceChannel: voicestate.channelId)
}

bot.connect()
