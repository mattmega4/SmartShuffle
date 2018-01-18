//
//  MediaPlayerViewController.swift
//  SmartShuffle
//
//  Created by Matthew Howes Singleton on 1/16/18.
//  Copyright © 2018 Matthew Howes Singleton. All rights reserved.
//

import UIKit

class MediaPlayerViewController: UIViewController {
  
  
  @IBOutlet weak var albumArtImageView: UIImageView!
  @IBOutlet weak var songProgressionProgressView: UIProgressView!
  @IBOutlet weak var songTimeElapsedLabel: UILabel!
  @IBOutlet weak var songTimeRemainingLabel: UILabel!
  @IBOutlet weak var songDetailLabelsStackView: UIStackView!
  @IBOutlet weak var songNameLabel: UILabel!
  @IBOutlet weak var songArtistLabel: UILabel!
  @IBOutlet weak var songAlbumLabel: UILabel!
  @IBOutlet weak var songControlsStackView: UIStackView!
  @IBOutlet weak var reverseButton: UIButton!
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var forwardButton: UIButton!
  @IBOutlet weak var songVolumeSlider: UISlider!
  @IBOutlet weak var smartShuffleButtonsStackView: UIStackView!
  @IBOutlet weak var stayOnAlbumButton: UIButton!
  @IBOutlet weak var stayOnArtistButton: UIButton!
  @IBOutlet weak var stayOnGenreButton: UIButton!
  @IBOutlet weak var sourceStackView: UIStackView!
  @IBOutlet weak var sourceIconButton: UIButton!
  @IBOutlet weak var sourceLabelButton: UIButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.

    albumArtImageView.createRoundedCorners()
    
  }
  

  
  
  
  // MARK: - IB Actions
  
  // MARK: - Song Control Button Actions
  
  @IBAction func reverseButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func playPauseButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func forwardButtonTapped(_ sender: UIButton) {
    
  }
  
  // MARK: - Smart Shuffle Button Actions
  
  @IBAction func stayOnAlbumButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func stayOnArtistButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func stayOnGenreButtonTapped(_ sender: UIButton) {
    
  }
  
  // MARK: - Source Action
  
  @IBAction func sourceIconButtonTapped(_ sender: UIButton) {
    
  }
  
  @IBAction func sourceLabelButtonTapped(_ sender: UIButton) {
    
  }
  
  
  
  
  
  
  
}
