//
//  MediaSlideshowSlide.swift
//  MediaSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import UIKit

public protocol MediaSlideshowSlide: UIView {

    var mediaContentMode: UIView.ContentMode { get set }

    func transitionImageView() -> UIImageView

    func willBeRemoved()

    func loadMedia()

    func releaseMedia()

    func didAppear()

    func didDisappear()

    func pause()
    
    func resume()
}
