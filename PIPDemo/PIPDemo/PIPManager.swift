//
//  PIPManager.swift
//  PIPDemo
//
//  Created by Zhen,Lintie on 2020/11/13.
//

import AVKit
import RxSwift

protocol PIPSupportable: class {
    
    var restoreObject: Any { get }
    
    var playerLayer: AVPlayerLayer { get }
    
    func onPIPWillStart()
    func onPIPStop()
    func onPIPRestore(object: Any, completionHandler: @escaping (Bool) -> Void)
    func onPIPPossible(_ isPossible: Bool)
}

class PIPManager: NSObject {
    
    static let shared = PIPManager()
    
    private(set) weak var player: PIPSupportable?
    
    var pipController: AVPictureInPictureController?
    
    var restoreObject: Any?
    
    private var disposeBag = DisposeBag()
    
    private override init() {
        super.init()
    }
    
    func addPlayer(_ player: PIPSupportable) {
        reset()
        self.player = player
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print("AVAudioSession发生错误")
        }
        
        self.pipController = AVPictureInPictureController(playerLayer: player.playerLayer)
        pipController?.delegate = self
        
        pipController?.rx.observe(Bool.self, #keyPath(AVPictureInPictureController.isPictureInPicturePossible))
        .subscribe(onNext: { [weak self] flag in
            guard let self = self else { return }
            self.player?.onPIPPossible(flag ?? false)
        })
        .disposed(by: disposeBag)
    }
    
    func removePlayer(_ player: PIPSupportable) {
        guard self.player == nil || player === self.player else {
            return
        }
        self.reset()
    }
    
    private func reset() {
        print("PIPManager reset")
        self.disposeBag = DisposeBag()
        self.player = nil
        if self.pipController?.isPictureInPictureActive == true {
            self.pipController?.stopPictureInPicture()
        }
        self.pipController = nil
    }
    
    func startPip() {
//        print("\(self.pipController?.isPictureInPicturePossible)")
        self.pipController?.startPictureInPicture()
    }
    
}

extension PIPManager: AVPictureInPictureControllerDelegate {
    /**
        @method        pictureInPictureControllerWillStartPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture will start.
     */
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//        print("pictureInPictureControllerWillStartPictureInPicture")
        self.restoreObject = player?.restoreObject
        player?.onPIPWillStart()
    }

    
    /**
        @method        pictureInPictureControllerDidStartPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture did start.
     */
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//        print("pictureInPictureControllerDidStartPictureInPicture")
    }

    
    /**
        @method        pictureInPictureController:failedToStartPictureInPictureWithError:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @param        error
                    An error describing why it failed.
        @abstract    Delegate can implement this method to be notified when Picture in Picture failed to start.
     */
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
//        print("failedToStartPictureInPictureWithError")
    }

    
    /**
        @method        pictureInPictureControllerWillStopPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture will stop.
     */
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//        print("pictureInPictureControllerWillStopPictureInPicture")
    }

    
    /**
        @method        pictureInPictureControllerDidStopPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture did stop.
     */
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//        print("pictureInPictureControllerDidStopPictureInPicture")
        player?.onPIPStop()
        self.restoreObject = nil
    }

    
    /**
        @method        pictureInPictureController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @param        completionHandler
                    The completion handler the delegate needs to call after restore.
        @abstract    Delegate can implement this method to restore the user interface before Picture in Picture stops.
     */
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
//        print("restoreUserInterfaceForPictureInPictureStopWithCompletionHandler")
        guard let restoreObject = self.restoreObject else { return }
        player?.onPIPRestore(object: restoreObject, completionHandler: completionHandler)
    }
}
