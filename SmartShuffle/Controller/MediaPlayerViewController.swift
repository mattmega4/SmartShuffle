//
//  MediaPlayerViewController.swift
//  SmartShuffle
//
//  Created by Matthew Howes Singleton on 1/16/18.
//  Copyright © 2018 Matthew Howes Singleton. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


class MediaPlayerViewController: UIViewController {
  
  @IBOutlet weak var albumArtImageView: UIImageView!
  @IBOutlet weak var songProgressView: UIProgressView!
  @IBOutlet weak var songTimePlayedLabel: UILabel!
  @IBOutlet weak var songTimeRemainingLabel: UILabel!
  @IBOutlet weak var songNameLabel: UILabel!
  @IBOutlet weak var songArtistLabel: UILabel!
  @IBOutlet weak var songAlbumLabel: UILabel!
  @IBOutlet weak var rewindSongButton: UIButton!
  @IBOutlet weak var playPauseSongButton: UIButton!
  @IBOutlet weak var forwardSongButton: UIButton!
  @IBOutlet weak var volumeLessIconImageView: UIImageView!
  @IBOutlet weak var songVolumeSlider: UISlider!
  @IBOutlet weak var volumeMoreIconImageView: UIImageView!
  @IBOutlet weak var audioSourceStackView: UIStackView!
  @IBOutlet weak var audioSourceIconButton: UIButton!
  @IBOutlet weak var audioSourceLabelButton: UIButton!
  @IBOutlet weak var albumLockIconButton: UIButton!
  @IBOutlet weak var albumLockLabelButton: UIButton!
  @IBOutlet weak var artistLockIconButton: UIButton!
  @IBOutlet weak var artistLockLabelButton: UIButton!
  @IBOutlet weak var genreLockIconButton: UIButton!
  @IBOutlet weak var genreLockLabelButton: UIButton!
  
  var isPlaying = false
  var newSongs = [MPMediaItem]()
  var playedSongs = [MPMediaItem]()
  var currentSong: MPMediaItem?
  let mediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    albumArtImageView.createRoundedCorners()
    setUpAudioPlayerAndGetSongsShuffled()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // prev button disabled if no prev song
  }
  
  func setUpAudioPlayerAndGetSongsShuffled() {
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    try? AVAudioSession.sharedInstance().setActive(true)
    MediaManager.shared.getAllSongs { (songs) in
      guard let theSongs = songs else {
        return
      }
      self.newSongs = theSongs
      self.mediaPlayer.setQueue(with: MPMediaItemCollection(items: self.newSongs))
      self.mediaPlayer.shuffleMode = .songs
    }
  }
  
  
  func getCurrentlyPlayedInfo() {
  
    if let songTitle = mediaPlayer.nowPlayingItem?.title {
      songNameLabel.text = songTitle
    } else {
      songNameLabel.text = ""
    }
    
    if let songArtist = mediaPlayer.nowPlayingItem?.artist {
      songArtistLabel.text = songArtist
    } else {
      songArtistLabel.text = ""
    }
    
    if let songAlbum = mediaPlayer.nowPlayingItem?.albumTitle {
      songAlbumLabel.text = songAlbum
    } else {
      songAlbumLabel.text = ""
    }
    
    if let artwork = mediaPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 400, height: 400)) {
      self.albumArtImageView.image = artwork
    } else {
      self.albumArtImageView.image = #imageLiteral(resourceName: "testAlbumCover")
    }
  }
  
  
  
  
  // MARK: - IB Actions
  
  // MARK: - Song Control Button Actions
  
  @IBAction func rewindSongButtonTapped(_ sender: UIButton) {
    mediaPlayer.skipToPreviousItem()
    getCurrentlyPlayedInfo()
  }
  
  
  @IBAction func forwardSongButtonTapped(_ sender: UIButton) {
    mediaPlayer.skipToNextItem()
    getCurrentlyPlayedInfo()
  }
  
  @IBAction func playPauseSongButtonTapped(_ sender: UIButton) {
    isPlaying = !isPlaying
    sender.isSelected = isPlaying
    isPlaying ? mediaPlayer.play() : mediaPlayer.pause()
    getCurrentlyPlayedInfo()
  }
  
  
  // MARK: - Audio Source Action
  
  @IBAction func audioSourceButtonTapped(_ sender: UIButton) {
    
  }
  
  // MARK: - Smart Shuffle Button Actions
  
  @IBAction func albumLockButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func artistLockButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func genreLockButtonTapped(_ sender: UIButton) {
    
  }
  
  
}

// check if song ended to update title etc

//func play(url: NSURL) {
//  let item = AVPlayerItem(URL: url)
//
//  NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
//
//  let player = AVPlayer(playerItem: item)
//  player.play()
//}
//
//func playerDidFinishPlaying(note: NSNotification) {
//  // Your code here
//}
////Don't forget to remove the observer when you're done (or in deinit)!




extension MediaPlayerViewController: AVAudioPlayerDelegate {
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    print("error")
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    print("finished playing")
  }
}
