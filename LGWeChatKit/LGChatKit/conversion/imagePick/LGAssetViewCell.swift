//
//  LGAssetViewCell.swift
//  LGWeChatKit
//
//  Created by jamy on 10/28/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import PhotosUI

class LGAssetViewCell: UICollectionViewCell {
    
    var viewModel: LGAssetViewModel? {
        didSet {
            viewModel?.image.observe {
                [unowned self] in
                if self.imageView.hidden {
                    self.imageView.hidden = false
                    self.livePhotoView.hidden = true
                }
                self.imageView.image = $0
            }
            
            viewModel?.livePhoto.observe {
                [unowned self] in
                if $0.size.height != 0 {
                    self.imageView.hidden = true
                    self.livePhotoView.hidden = false
                    self.livePhotoView.livePhoto = $0
                }
            }
            
            viewModel?.asset.observe {
                [unowned self] in
                if $0.mediaType == .Video {
                    self.playIndicator?.hidden = false
                } else {
                    self.playIndicator?.hidden = true
                }
            }
        }
    }
    
    var imageView: UIImageView!
    var livePhotoView: PHLivePhotoView!
    var playLayer: AVPlayerLayer?
    var playIndicator: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        contentView.addSubview(imageView)
        
        playIndicator = UIImageView(frame: CGRectMake(0, 0, 40, 40))
        playIndicator?.center = contentView.center
        playIndicator?.image = UIImage(named: "MessageVideoPlay")
        contentView.addSubview(playIndicator!)
        playIndicator?.hidden = true
        
        livePhotoView = PHLivePhotoView()
        livePhotoView.hidden = true
        contentView.addSubview(livePhotoView)
        
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: livePhotoView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: livePhotoView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: livePhotoView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: livePhotoView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopPlayer()
    }
    
    func stopPlayer() {
        if let player = self.playLayer {
            player.player?.pause()
            player.removeFromSuperlayer()
        }
        playLayer = nil
    }
    
    func playLivePhoto() {
        if livePhotoView.livePhoto != nil {
            livePhotoView.startPlaybackWithStyle(.Full)
        } else if playLayer != nil {
            playLayer?.player?.play()
        } else {
            PHImageManager.defaultManager().requestAVAssetForVideo((viewModel?.asset.value)!, options: nil, resultHandler: { (asset, audioMix, _:[NSObject : AnyObject]?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.playLayer == nil {
                        let viewLayer = self.layer
                        let playItem = AVPlayerItem(asset: asset!)
                        playItem.audioMix = audioMix
                        let player = AVPlayer(playerItem: playItem)
                        let avPlayerLayer = AVPlayerLayer(player: player)
                        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                        avPlayerLayer.frame = CGRectMake(0, 0, viewLayer.bounds.width, viewLayer.bounds.height)
                        viewLayer.addSublayer(avPlayerLayer)
                        self.playLayer = avPlayerLayer
                        self.playLayer?.player?.play()
                    }
                })
            })
        }
    }
    
}
