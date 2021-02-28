//
//  Extensions.swift
//  ArcBlock_Code_Test
//
//  Created by HanLiu on 2021/2/27.
//

import UIKit

extension UIImageView {
    func hl_setImage(url: String, completion: ((UIImage) -> UIImage)?) {
        HTTPClient.shared.downloadImage(imageUrlStr: url) { (result) in
            switch result {
            case .success(let image):
                if let completion = completion {
                    let outputImage = completion(image)
                    DispatchQueue.main.async {
                        self.image = outputImage
                    }
                } else {
                    DispatchQueue.main.async {
                        //if use resizeImage function,
                        //Memory use: 13.9MB
                        //if not use
                        //Memory use: 50.7MB
                        let resizedImage = resizeImage(originalImage: image, for: self.frame.size)
                        self.image = resizedImage
                    }
                }
            case .failure(let error):
                debugPrint("\(error)")
            }
        }
    }
}

/// 使用UIKit：UIGraphicsImageRenderer
///
/// - Parameters:
///   - url: 图片存储地址 / 直接使用原始图originalImage（通过data转换为UIImage）
///   - size: 输出的图片大小
/// - Returns: UIImage
func resizeImage(originalImage: UIImage, for size:CGSize) -> UIImage? {
    let render = UIGraphicsImageRenderer(size: size)
    return render.image(actions: { (context) in
        originalImage.draw(in: CGRect(origin: .zero, size: size))
        //image.draw(in: CGRect(origin: .zero, size: size), blendMode: CGBlendMode.normal, alpha: 1.0)
    })
}


extension CGFloat {
    static var one: CGFloat = 1.0
    static var six: CGFloat = 6.0
    static var sixteen: CGFloat = 16.0

}

extension UIView {
    func constraint(in view: UIView, top: CGFloat = .zero, bottom: CGFloat = .zero, leading: CGFloat = .zero, trailing: CGFloat = .zero) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing),
        ])
    }
}
