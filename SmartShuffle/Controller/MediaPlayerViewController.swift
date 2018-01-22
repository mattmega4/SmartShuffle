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
import MBProgressHUD


class MediaPlayerViewController: UIViewController {
  
  @IBOutlet weak var albumArtImageView: UIImageView!
  @IBOutlet weak var songProgressView: UIProgressView!
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
  
  @IBOutlet weak var volumeView: UIView!
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
  let mediaPlayer = MPMusicPlayerApplicationController.systemMusicPlayer
  var songTimer: Timer?
  var firstLaunch = true
  var lastPlayedItem: MPMediaItem?
  var volumeControlView = MPVolumeView()
  var lockStatus = -1 // 0 artist 1 album 2 genre 3 all
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mediaPlayer.beginGeneratingPlaybackNotifications()
    NotificationCenter.default.addObserver(self, selector: #selector(songChanged(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    albumArtImageView.createRoundedCorners()
    setUpAudioPlayerAndGetSongsShuffled()
    clearSongInfo()
    songProgressSlider.addTarget(self, action: #selector(playbackSlider(_:)), for: .valueChanged)
    volumeControlView.showsVolumeSlider = true
  }
  
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    mediaPlayer.endGeneratingPlaybackNotifications()
//  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if volumeView.subviews.count == 0 {
      let myVolumeView = MPVolumeView(frame: volumeView.bounds)
      volumeView.addSubview(myVolumeView)
    }
  }
  
  @objc func playbackSlider(_ slider: UISlider) {
    if slider == songProgressSlider {
      mediaPlayer.currentPlaybackTime = Double(slider.value)
    }
  }
  
  @objc func songChanged(_ notification: Notification) {
    print("\(mediaPlayer.nowPlayingItem?.genre ?? "")")
    songProgressSlider.maximumValue = Float(mediaPlayer.nowPlayingItem?.playbackDuration ?? 0)
    songProgressSlider.minimumValue = 0
    songProgressSlider.value = 0
    songProgressView.progress = 0
    songTimePlayedLabel.text = getTimeElapsed()
    songTimeRemainingLabel.text = getTimeRemaining()
    //print("\(mediaPlayer.indexOfNowPlayingItem)")
    if !firstLaunch {
      getCurrentlyPlayedInfo()
      //rewindSongButton.isEnabled = true
    } else {
      firstLaunch = false
      //rewindSongButton.isEnabled = false
    }
    rewindSongButton.isEnabled = mediaPlayer.indexOfNowPlayingItem != 0
    guard let currentItem = lastPlayedItem else {
      return
    }
    if !playedSongs.contains(currentItem) {
      playedSongs.append(currentItem)
    }
    if lockStatus == 2 {
      lockStatus = -1
     
      let genreQuery = MediaManager.shared.getSongsWithCurrentGenreFor(item: currentItem)
      //genreQuery.items
      mediaPlayer.setQueue(with: genreQuery)
      //self.mediaPlayer.setQueue(with: MPMediaItemCollection(items: self.newSongs))
      self.mediaPlayer.shuffleMode = .songs
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
      MBProgressHUD.hide(for: self.view, animated: true)
        self.mediaPlayer.play()
      })
    }
    if lockStatus == 3 {
      lockStatus = -1
      setUpAudioPlayerAndGetSongsShuffled()
    }
    
  }
  
  func clearSongInfo() {
    albumArtImageView.image = #imageLiteral(resourceName: "testAlbumCover")
    songNameLabel.text = ""
    songArtistLabel.text = ""
    songAlbumLabel.text = ""
  }

  
  func setUpAudioPlayerAndGetSongsShuffled() {
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    try? AVAudioSession.sharedInstance().setActive(true)
    MBProgressHUD.showAdded(to: view, animated: true)
    MediaManager.shared.getAllSongs { (songs) in
      guard let theSongs = songs else {
        return
      }
      self.newSongs = theSongs.filter({ (item) -> Bool in
        return !self.playedSongs.contains(item)
      })
      self.mediaPlayer.setQueue(with: MPMediaItemCollection(items: self.newSongs))
      self.mediaPlayer.shuffleMode = .songs
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
        MBProgressHUD.hide(for: self.view, animated: true)
      })
    }
  }
  
  func getTimeRemaining() -> String {
    let secondsRemaining = songProgressSlider.maximumValue - songProgressSlider.value
    let minutes = Int(secondsRemaining / 60)
    let seconds = String(format: "%02d", Int(secondsRemaining - Float(60  * minutes)))
    return "\(minutes):\(seconds)"
  }
  
  func getTimeElapsed() -> String {
    let secondsElapsed = songProgressSlider.value
    let minutes = Int(secondsElapsed / 60)
    let seconds = String(format: "%02d", Int(secondsElapsed - Float(60  * minutes)))
    return "\(minutes):\(seconds)"
  }
  
  func updateCurrentPlaybackTime() {
    let elapsedTime = mediaPlayer.currentPlaybackTime
    songProgressSlider.value = Float(elapsedTime)
    songProgressView.progress = Float(elapsedTime / Double(songProgressSlider.maximumValue))
    songTimePlayedLabel.text = getTimeElapsed()
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
    
    //DispatchQueue.global().async {
      self.isPlaying ? self.mediaPlayer.play() : self.mediaPlayer.pause()
    //}
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
  
  @IBAction func volumeSliderDragged(_ sender: UISlider) {
    
  }
  
  
  
  @IBAction func audioSourceButtonTapped(_ sender: UIButton) {
    
  }
  
  // MARK: - Smart Shuffle Button Actions
  
  @IBAction func albumLockButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func artistLockButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func genreLockButtonTapped(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    genreLockLabelButton.titleLabel?.font = sender.isSelected ? UIFont.boldSystemFont(ofSize: 15) : UIFont.systemFont(ofSize: 15)
     
    if !sender.isSelected {
      lockStatus = 3
      return
    }
    lastPlayedItem = mediaPlayer.nowPlayingItem
    lockStatus = 2
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
