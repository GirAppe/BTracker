import AVFoundation

public protocol BackgroundKeeper {
    func start()
    func stop()
    func keep(for time: TimeInterval)
    func every(_  time: TimeInterval, perform handler: @escaping () -> Void)
    func stopHandler()
}

public class Background: NSObject {
    private var player: AVPlayer?
    private var shutdownTimer: Timer?
    private var handlerTimer: Timer?
    private let stopper = #selector(stopTrigger)
    private let trigger = #selector(handlerTrigger)
    private var handler: (() -> Void)?

    // MARK: - Lifecycle
    public override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        } catch {
            fatalError("Audio session error: \(String(describing: error))")
        }

        super.init()
    }

    // MARK: - Actions
    public func start() {
        shutdownTimer?.invalidate()

        let bundle = Bundle(for: Background.self)
        guard let url = bundle.url(forResource: "silence", withExtension: "m4a") else {
            fatalError("Sound of silence is gone!")
        }
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        player?.actionAtItemEnd = .none
        player?.play()
    }

    public func stop() {
        shutdownTimer?.invalidate()
        handlerTimer?.invalidate()

        let bundle = Bundle(for: Background.self)
        guard let url = bundle.url(forResource: "silence", withExtension: "m4a") else {
            fatalError("Sound of silence is gone!")
        }
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        player?.actionAtItemEnd = .pause
        player?.play()
    }

    public func keep(for time: TimeInterval) {
        start()
        shutdownTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: stopper, userInfo: nil, repeats: false)
    }

    public func every(_  time: TimeInterval, perform handler: @escaping () -> Void) {
        handlerTimer?.invalidate()
        self.handler = handler
        handlerTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: trigger, userInfo: nil, repeats: true)
    }

    public func stopHandler() {
        handlerTimer?.invalidate()
    }

    // MARK: - Helpers
    @objc private func stopTrigger() {
        stop()
    }

    @objc private func handlerTrigger() {
        handler?()
    }
}
