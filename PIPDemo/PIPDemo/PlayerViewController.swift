//
//  PlayerViewController.swift
//  PIPDemo
//
//  Created by Zhen,Lintie on 2020/11/13.
//

import UIKit
import AVKit
import SnapKit
import RxSwift

class PlayerViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let playerView: PlayerView
    
    lazy var openPipButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        if #available(iOS 14.0, *), AVPictureInPictureController.isPictureInPictureSupported() {
            button.setImage(AVPictureInPictureController.pictureInPictureButtonStartImage, for: .normal)
        } else {
            button.setTitle("不支持画中画", for: .normal)
            button.isEnabled = false
        }
        return button
    }()
    
    deinit {
        print("PlayerViewController - deinit")
        PIPManager.shared.removePlayer(self)
    }
    
    init(url: String) {
        playerView = PlayerView(url: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if AVPictureInPictureController.isPictureInPictureSupported() {
            openPipButton.rx.tap.subscribe(onNext: {
                PIPManager.shared.startPip()
            })
            .disposed(by: disposeBag)
            PIPManager.shared.addPlayer(self)
            
        }
        playerView.player?.play()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        view.addSubview(playerView)
        playerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(9.0/16.0*view.frame.width)
        }
        
        view.addSubview(openPipButton)
        openPipButton.snp.makeConstraints {
            $0.top.equalTo(playerView.snp_bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
        }
    }
    
    private var lastPresentingViewController: UIViewController?
    
}

extension PlayerViewController: PIPSupportable {
    
    var restoreObject: Any {
        self
    }
    
    var playerLayer: AVPlayerLayer {
        playerView.playerLayer
    }
    
    func onPIPWillStart() {
        lastPresentingViewController = presentingViewController
        dismiss(animated: false, completion: nil)
    }
    
    func onPIPStop() {
        
    }
    
    func onPIPRestore(object: Any, completionHandler: @escaping (Bool) -> Void) {
        lastPresentingViewController?.present(self, animated: false, completion: nil)
        completionHandler(true)
    }
    
    func onPIPPossible(_ isPossible: Bool) {
        openPipButton.isEnabled = isPossible
    }
    
}

class PlayerView: UIView {
    
    weak var player: CustomPlayer?
    
    let playerLayer: CustomPlayerLayer
    
    deinit {
        print("PlayerView - deinit")
        player?.replaceCurrentItem(with: nil)
    }
    
    init(url: String) {
        self.player = CustomPlayer(url: URL(string: url)!)
        self.playerLayer = CustomPlayerLayer()
        playerLayer.player = player
        super.init(frame: .zero)
        backgroundColor = .black
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
}

// iOS 14 Bug：AVPictureInPicture 释放后，AVPlayer 没有被释放，导致内存泄露
// https://openradar.appspot.com/FB8561088
class CustomPlayer: AVPlayer {
    
    deinit {
        print("CustomPlayer - deinit")
    }
    
}

class CustomPlayerLayer: AVPlayerLayer {
    
    deinit {
        print("CustomPlayerLayer - deinit")
    }
    
}
