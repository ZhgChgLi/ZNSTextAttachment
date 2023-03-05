//
//  MixedViewController.swift
//  ZNSTextAttachment-Demo
//
//  Created by https://zhgchg.li on 2023/3/5.
//

import UIKit
import ZNSTextAttachment

class MixedViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: ZNSTextAttachmentLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let attachment = ZNSTextAttachmentPlaceholder(imageURL: URL(string: "https://zhgchg.li/assets/a5643de271e4/1*A0yXupXW9-F9ZWe4gp2ObA.jpeg")!, placeholderImage: UIImage(systemName: "viewfinder.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal))
        
        let data = TestData.generate(with: attachment)
        
        attachment.dataSource = self
        attachment.delegate = self
        
        textView.attributedText = data
        label.attributedText = data
    }
}

extension MixedViewController: ZNSTextAttachmentDataSource {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachmentPlaceholder, loadImageURL imageURL: URL, completion: @escaping (Data) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: URL(string: imageURL.absoluteString+"?q=\(UUID().uuidString)")!) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            completion(data)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dataTask.resume()
        }
    }
}


extension MixedViewController: ZNSTextAttachmentDelegate {
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachmentPlaceholder) {
        //
    }
}
