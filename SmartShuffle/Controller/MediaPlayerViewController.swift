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
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    try? AVAudioSession.sharedInstance().setActive(true)
    // Do any additional setup after loading the view.
    
    albumArtImageView.createRoundedCorners()
    MediaManager.shared.getAllSongs { (songs) in
      guard let theSongs = songs else {
        return
      }
      
      self.newSongs = theSongs
      self.mediaPlayer.setQueue(with: MPMediaItemCollection(items: self.newSongs))
      
      self.mediaPlayer.shuffleMode = .songs
      }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // prev button disabled if no prev song
  }
  
  func playNext() {
    mediaPlayer.skipToNextItem()
    if let artwork = mediaPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 400, height: 400)) {
      self.albumArtImageView.image = artwork
    }
    /*player = nil
    let index = Int(arc4random_uniform(UInt32(newSongs.count)))
    let song = newSongs[index]
    self.currentSong = song
    isPlaying ? play(item: song) : pause(item: song)
    newSongs.remove(at: index)*/
  }
  
  func playPrevious() {
    
    /*player?.stop()
    player = nil
    //let index = Int(arc4random_uniform(UInt32(newSongs.count)))
    let song = playedSongs.last
    self.currentSong = song
    if let theSong = song {
      isPlaying ? play(item: theSong) : pause(item: theSong)
    }*/
  }
  

  
  
  
  
  
  // MARK: - IB Actions
  
  // MARK: - Song Control Button Actions
  
  @IBAction func rewindSongButtonTapped(_ sender: UIButton) {
    mediaPlayer.skipToPreviousItem()
    if let artwork = mediaPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 400, height: 400)) {
      self.albumArtImageView.image = artwork
    }
    else {
      self.albumArtImageView.image = #imageLiteral(resourceName: "testAlbumCover")
    }
    print("\(mediaPlayer.nowPlayingItem?.title)")
  }
  
  @IBAction func playPauseSongButtonTapped(_ sender: UIButton) {
    isPlaying = !isPlaying
    sender.isSelected = isPlaying
    isPlaying ? mediaPlayer.play() : mediaPlayer.pause()
    if let artwork = mediaPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 400, height: 400)) {
      self.albumArtImageView.image = artwork
    }
    else {
      self.albumArtImageView.image = #imageLiteral(resourceName: "testAlbumCover")
    }
    print("\(mediaPlayer.nowPlayingItem?.title)")
    /*if let song = currentSong {
      isPlaying ? play(item: song) : pause(item: song)
    }
    else {
      let index = Int(arc4random_uniform(UInt32(newSongs.count)))
      let song = newSongs[index]
      self.currentSong = song
      isPlaying ? play(item: song) : pause(item: song)
      newSongs.remove(at: index)
    }*/
    
  }
  
  func play(item: MPMediaItem) {
    /*print("\(item.title)")
    if let thePlayer = player {
      thePlayer.play()
    }
    else {*/
      
    
      mediaPlayer.play()
      
     /* if let url = item.assetURL {
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
      }
      else if let url = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
      }
      else {
        print("klgjadsklgj")
      }
    }*/
  }
  
 /* func pause(item: MPMediaItem) {
    //player?.pause()
  }*/
  
  
  @IBAction func forwardSongButtonTapped(_ sender: UIButton) {
    mediaPlayer.skipToNextItem()
    
    if let artwork = mediaPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 400, height: 400)) {
      self.albumArtImageView.image = artwork
    }
    else {
      self.albumArtImageView.image = #imageLiteral(resourceName: "testAlbumCover")
    }
    print("\(mediaPlayer.nowPlayingItem?.title)")
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
