//
//  ViewController.swift
//  Swingtweaks
//
//  Created by Lokesh Patil on 09/12/21.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary

class ViewController: UIViewController {
    
    let urlVideo = "http://techslides.com/demos/sample-videos/small.mp4"
    let urlAudio = "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3"
    
    @IBOutlet weak var recodeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
      var state: AGAudioRecorderState = .Ready
      var recorder: AGAudioRecorder = AGAudioRecorder(withFileName: "TempFile")

    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recodeBtn.setTitle("Recode", for: .normal)
        playBtn.setTitle("Play", for: .normal)
        recorder.delegate = self
        imagePicker.delegate = self
    }
    
    @IBAction func PlayVideo(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateTweak" ) as! CreateTweakViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func mergeVideo(_ sender: Any) {
        mergeAudioWithVideo()
    }
    
      @IBAction func recode(_ sender: UIButton) {
           recorder.doRecord()
       }

       @IBAction func play(_ sender: UIButton) {
           recorder.doPlay()
       }
    
    @IBAction func btnCameraRoll(_ sender: UIButton) {
        self.selectVideoSetup()
    }
    
   //  Create and show an alert view
    
    fileprivate func createAlertView(message: String?) {
        let messageAlertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        messageAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            messageAlertController.dismiss(animated: true, completion: nil)
        }))
        DispatchQueue.main.async { [weak self] in
            self?.present(messageAlertController, animated: true, completion: nil)
        }
    }
    
    private func mergeAudioWithVideo(){
        

        if let videoURL2 = Bundle.main.url(forResource: "videoApp", withExtension: "mov"),
    //let audioURL2 =   URL(string:recorder.fileUrl().path){
          let audioURL2 =  Bundle.main.url(forResource: "demoAudio", withExtension: "mp3") {
            LoadingView.lockView()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "SwingteaksddMMyyyyHHmmss"
            VideoGenerator.fileName =  "\(dateFormatter.string(from: Date()))"
            VideoGenerator.current.mergeVideoWithAudio(videoUrl: videoURL2, audioUrl: audioURL2) { (result) in
                LoadingView.unlockView()
                switch result {
                case .success(let url):
                    print(url)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateTweak" ) as! CreateTweakViewController
                    vc.updatedUrl = url
                    self.navigationController?.pushViewController(vc, animated: true)
                 //    self.createAlertView(message: "self.FinishMergingVideoWithAudio")
                case .failure(let error):
                    print(error)
                    self.createAlertView(message: error.localizedDescription)
                }
            }
        } else {
            self.createAlertView(message:" self.Missing Video Files")
        }
    }
}

extension ViewController: AGAudioRecorderDelegate {
    func agAudioRecorder(_ recorder: AGAudioRecorder, withStates state: AGAudioRecorderState) {
        switch state {
        case .error(let e): debugPrint(e)
        case .Failed(let s): debugPrint(s)

        case .Finish:
            recodeBtn.setTitle("Recode", for: .normal)

        case .Recording:
            recodeBtn.setTitle("Recoding Finished", for: .normal)

        case .Pause:
            playBtn.setTitle("Pause", for: .normal)

        case .Play:
            playBtn.setTitle("Play", for: .normal)

        case .Ready:
            recodeBtn.setTitle("Recode", for: .normal)
            playBtn.setTitle("Play", for: .normal)
           // refreshBtn.setTitle("Refresh", for: .normal)
        }
        debugPrint(state)
    }

    func agAudioRecorder(_ recorder: AGAudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String) {
        debugPrint(formattedString)
    }
    
    
}
extension ViewController : UIImagePickerControllerDelegate,
                           UINavigationControllerDelegate {
    func selectVideoSetup() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"Library", style:UIAlertAction.Style.default, handler:{ action in
            self.photoFromLibrary()
        }))
        //        settingsActionSheet.addAction(UIAlertAction(title:Language.shared.stringForKey(key: Message.shared.K_Camera), style:UIAlertAction.Style.default, handler:{ action in
        //            self.shootPhoto()
        //        }))
        settingsActionSheet.addAction(UIAlertAction(title: "Cancel", style:UIAlertAction.Style.cancel, handler:nil))
        present(settingsActionSheet, animated:true, completion:nil)
    }
    func photoFromLibrary() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        imagePicker.modalPresentationStyle = .popover
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print("videoUrl",videoUrl)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateTweak" ) as! CreateTweakViewController
            vc.galleryVideoUrl = "\(videoUrl)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
