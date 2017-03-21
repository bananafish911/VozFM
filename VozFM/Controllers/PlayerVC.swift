//
//  PlayerVC.swift
//  VozFM
//
//  Created by Victor on 10/29/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import UIKit
import AVFoundation

import Alamofire
import Kingfisher

import RxSwift
import RxCocoa

class PlayerVC: UIViewController, UITableViewDelegate {
    
    // MARK: - Properties
    
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint! {
        didSet {
            headerHeightConstraint.constant = headerDefaultHeight
        }
    }
    let headerDefaultHeight: CGFloat = 320.0
    
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var songLbl: UILabel!
    
    @IBOutlet weak var playStopButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTracksObserver()
        setupPlayerStateObserver()
        
        setupTableView()
        
        Player.shared.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - RX setup
    
    private func setupPlayerStateObserver() {
        Player.shared.state.asObservable()
            .subscribe(onNext: { [weak self] (state) in
                if state == .playing {
                    self?.playStopButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                } else {
                    self?.playStopButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private func setupTracksObserver() {
        Player.shared.recentTracks.asObservable()
            .subscribe(onNext: { [weak self] (tracks) in
                guard let strongSelf = self else { return }
                
                strongSelf.tableView.reloadData()
                
                if let recentTrack = tracks.first {
                    strongSelf.artistLbl.text = recentTrack.artist
                    strongSelf.songLbl.text = recentTrack.title
                    
                    recentTrack.image.asObservable()
                        .bindTo(strongSelf.artworkView.rx.image(transitionType: kCATransitionFade))
                        .addDisposableTo(strongSelf.disposeBag)
                }
                
            })
            .addDisposableTo(disposeBag)
    }
    
    private func setupTableView() {
        
        tableView.delegate = self // for UIScrollViewDelegate
        
        Player.shared.recentTracks.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: "RecentTracksCell", cellType: RecentTracksCell.self)) { [weak self] (row, track, cell) in
                guard let strongSelf = self else { return }
                
                cell.isUserInteractionEnabled = false
                cell.mainLabel.text = track.title
                cell.secondaryLabel.text = track.artist
                
                track.image.asObservable()
                    .bindTo(cell.artworkImageView.rx.image(transitionType: kCATransitionFade))
                    .addDisposableTo(strongSelf.disposeBag)
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(Track.self)
            .subscribe(onNext: { (selectedTrack) in
                debugPrint("selected \(selectedTrack)")
            })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions

    @IBAction func menuButtonTap(_ sender: UIButton) {
        let aboutVC = Constants.Storyboards.main.instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @IBAction func playStopButtonTap(_ sender: UIButton) {
        let player = Player.shared
        if player.state.value == .playing {
            player.pause()
        } else {
            player.play()
        }
        
        // haptic feedback
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Fallback on earlier versions
        }
    }
    
}

extension PlayerVC: UIScrollViewDelegate {
    
    // MARK: UIScrollViewDelegate and StickyHeader
    
    func animateHeader() {
        self.headerHeightConstraint.constant = headerDefaultHeight
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            headerHeightConstraint.constant += abs(scrollView.contentOffset.y)
        }
            
        else if scrollView.contentOffset.y > 0 && headerHeightConstraint.constant >= headerDefaultHeight {
            headerHeightConstraint.constant -= scrollView.contentOffset.y / 100
            
            if headerHeightConstraint.constant < headerDefaultHeight {
                headerHeightConstraint.constant = headerDefaultHeight
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if headerHeightConstraint.constant > headerDefaultHeight {
            animateHeader()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if headerHeightConstraint.constant > headerDefaultHeight {
            animateHeader()
        }
    }
    
}
