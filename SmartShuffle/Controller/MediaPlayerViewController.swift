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

  @IBOutlet weak var songProgressSlider: UISlider!
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
  var songTimer: Timer?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mediaPlayer.beginGeneratingPlaybackNotifications()
    // Do any additional setup after loading the view.
    NotificationCenter.default.addObserver(self, selector: #selector(songChanged(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    albumArtImageView.createRoundedCorners()
    setUpAudioPlayerAndGetSongsShuffled()
    
  }
  
  
  @objc func songChanged(_ notification: Notification) {
    songProgressSlider.maximumValue = Float(mediaPlayer.nowPlayingItem?.playbackDuration ?? 0)
    songProgressSlider.minimumValue = 0
    songProgressSlider.value = 0
//    songProgressSlider.minimumTrackTintColor = .white
    songTimePlayedLabel.text = getTimeElapsed()
    songTimeRemainingLabel.text = getTimeRemaining()
    getCurrentlyPlayedInfo()
  }
  
  func showUpdatedProgress() {
    
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
  
  func getTimeRemaining() -> String {
    let secondsRemaining = songProgressSlider.maximumValue - songProgressSlider.value
    let minutes = Int(secondsRemaining / 60)
    let seconds = Int (secondsRemaining - Float(60  * minutes))
    return "\(minutes):\(seconds)"
  }
  
  func getTimeElapsed() -> String {
    let secondsElapsed = songProgressSlider.value
    let minutes = Int(secondsElapsed / 60)
    let seconds = Int (secondsElapsed - Float(60  * minutes))
    return "\(minutes):\(seconds)"
  }
  
  func updateCurrentPlaybackTime() {
    let elapsedTime = mediaPlayer.currentPlaybackTime
    songProgressSlider.value = Float(elapsedTime)
    songTimePlayedLabel.text = getTimeElapsed()
//    songProgressSlider.minimumTrackTintColor = .blue
    songTimeRemainingLabel.text = getTimeRemaining()
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
  
  @IBAction func songProgressSliderDragged(_ sender: UISlider) {
    mediaPlayer.currentPlaybackTime = Double(sender.value)
  }
  
  // MARK: - Slider Action
  
  
  
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
    if isPlaying {
      songTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
        self.updateCurrentPlaybackTime()
      })
    }
    else {
      songTimer?.invalidate()
    }
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





extension MediaPlayerViewController: AVAudioPlayerDelegate {
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    print("error")
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    print("finished playing")
    
  }
}
