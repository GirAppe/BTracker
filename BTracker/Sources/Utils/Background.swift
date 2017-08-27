import AVFoundation

public class Background: NSObject {
    private var player: AVPlayer?
    private var shutdownTimer: Timer?

    public override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        } catch {
            fatalError("Audio session error: \(String(describing: error))")
        }

        super.init()
    }

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
        shutdownTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(stop), userInfo: nil, repeats: false)
    }
}
