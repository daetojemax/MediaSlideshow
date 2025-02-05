import AVFoundation
import AVKit
import Foundation

open class AVSource: NSObject, MediaSource {
    public enum Playback: Equatable {
        case play // will be muted when playback controls are hidden
        case paused
    }
    private let onAppear: Playback
    private let asset: AVAsset
    private lazy var item = AVPlayerItem(asset: asset)
    private lazy var player = AVPlayer(playerItem: item)
    private var rate: Float?
    private var start: Double = 0

    public init(asset: AVAsset, onAppear: Playback) {
        self.asset = asset
        self.onAppear = onAppear
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item)
    }

    public convenience init(url: URL, onAppear: Playback, rate: Float? = nil, start: Double = 0) {
        self.init(asset: AVAsset(url: url), onAppear: onAppear)
        self.rate = rate
        self.start = start
    }

    open func slide(in slideshow: MediaSlideshow) -> MediaSlideshowSlide {
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.showsPlaybackControls = false
        player.seek(to: CMTime(seconds: start, preferredTimescale: 600))
        if #available(iOS 16.0, *) {
            playerController.allowsVideoFrameAnalysis = false
        }
        let slide = AVPlayerSlide(
            playerController: playerController,
            mediaContentMode: slideshow.contentScaleMode)
        slide.delegate = self
        return slide
    }

    @objc
    open func playerItemDidPlayToEndTime(notification: Notification) {
        player.seek(to: .zero)
    }
}

extension AVSource: AVPlayerSlideDelegate {
    open func slideDidAppear(_ slide: AVPlayerSlide) {
        switch onAppear {
        case .play:
            player.play()
            if let rate {
                player.rate = rate
            }
            player.isMuted = true
        case .paused:
            player.pause()
        }
    }

    open func slideDidDisappear(_ slide: AVPlayerSlide) {
        player.pause()
    }

    open func currentThumbnail(_ slide: AVPlayerSlide) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let imageRef = try? generator.copyCGImage(at: player.currentTime(), actualTime: nil) {
            return UIImage(cgImage: imageRef)
        }
        return nil
    }
}
