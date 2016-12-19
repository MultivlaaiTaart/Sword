import Foundation
import Dispatch
import WebSockets

class Heartbeat {

  let session: WebSocket

  let interval: Int
  var sequence: [Int] = []

  let queue = DispatchQueue(label: "gg.azoy.sword.heartbeat", qos: .userInitiated)

  init(_ ws: WebSocket, interval: Int) {
    self.session = ws
    self.interval = interval
  }

  func start() {
    let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(self.interval)

    queue.asyncAfter(deadline: deadline) {
      let heartbeat: [String: Any] = ["op": OPCode.heartbeat.rawValue, "d": NSNull()]

      let data = try? JSONSerialization.data(withJSONObject: heartbeat, options: [])

      try? self.session.send(String(data: data!, encoding: .utf8)!)

      self.send()
    }
  }

  func send() {
    let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(self.interval)

    queue.asyncAfter(deadline: deadline) {
      let heartbeat = ["op": OPCode.heartbeat.rawValue, "d": self.sequence.first ?? nil]
      self.sequence.remove(at: 0)

      let data = try? JSONSerialization.data(withJSONObject: heartbeat, options: [])

      try? self.session.send(String(data: data!, encoding: .utf8)!)

      self.send()
    }
  }

}