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
import VideoEditor

class ViewController: UIViewController {
    
    var frames:[UIImage] = []
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
    }
    
    @IBAction func PlayVideo(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateTweak" ) as! CreateTweakViewController
        guard let path = Bundle.main.path(forResource: "videoApp", ofType: "mov") else {
            return
        }
        let videoURL = NSURL(fileURLWithPath: path)
        vc.videoUrl = videoURL as URL
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCameraRoll(_ sender: UIButton) {
        self.selectVideoSetup()
    }
}

extension ViewController : UIImagePickerControllerDelegate,
                           UINavigationControllerDelegate {
    func selectVideoSetup() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"Library", style:UIAlertAction.Style.default, handler:{ action in
            self.photoFromLibrary()
        }))
        //    settingsActionSheet.addAction(UIAlertAction(title:Language.shared.stringForKey(key: Message.shared.K_Camera), style:UIAlertAction.Style.default, handler:{ action in
        //      self.shootPhoto()
        //    }))
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
            vc.videoUrl = videoUrl
            self.navigationController?.pushViewController(vc, animated: true)
        }
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
