import Foundation
import WatchConnectivity

class SyncManager: NSObject, WCSessionDelegate {
    weak var manager: StopwatchManager?
    private var session: WCSession?
    private(set) var isSyncing = false

    func activate() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    func sendState(_ stopwatches: [Stopwatch]) {
        guard !isSyncing,
              let session,
              session.activationState == .activated else { return }

        let snapshots = stopwatches.map { $0.snapshot() }
        guard let data = try? JSONEncoder().encode(snapshots) else { return }
        let payload: [String: Any] = ["stopwatches": data]

        try? session.updateApplicationContext(payload)

        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { _ in }
        }
    }

    private func handleIncoming(_ payload: [String: Any]) {
        guard let data = payload["stopwatches"] as? Data,
              let snapshots = try? JSONDecoder().decode([StopwatchSnapshot].self, from: data) else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self, let manager = self.manager else { return }
            self.isSyncing = true
            manager.applySnapshots(snapshots)
            // Delay clearing the flag so async Combine callbacks from apply don't echo back
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isSyncing = false
            }
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if activationState == .activated, !session.receivedApplicationContext.isEmpty {
            handleIncoming(session.receivedApplicationContext)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleIncoming(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        handleIncoming(applicationContext)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
