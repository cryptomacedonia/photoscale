//
//  SFGalleryViewModel.swift
//  PhotoScale1
//
//  Created by Igor Jovcevski on 25.8.23.
//

import Foundation
import SwiftUI
class SFGalleryViewModel : ObservableObject {
   
    @Published var allImages:[String] = ["image1", "image2","image3" ,"image4","image5", "image6","image7" ,"image8","image9", "image10","image11" ,"image12","image13", "image14","image15" ,"image16","image17", "image18","image19" ,"image20","image21", "image22","image23" ,"image24"]
 //   @Published var selectedImageIndex: Int? = nil
    @Published var selectedImageId: String = ""
    @Published var showTab = false
    @Published var fullImageOffset: CGSize = .zero
    @Published var backOpacity: Double = 1.0
    @Published var fullImageScale: CGFloat = 1
    @Published var opacityOfSelectedItem: Double = 1.0
    @Published var selectedItemFrame: CGRect = .zero
 
    @Published var currentTabViewImageDefaultFrame: CGRect = .zero
    func onChange(value: CGSize) {
        DispatchQueue.main.async { [self] in
            fullImageOffset = value
        }
        let halfHeight = UIScreen.main.bounds.height / 2
        let progress = fullImageOffset.height / halfHeight
        DispatchQueue.main.async { [self] in
            withAnimation(.default) {
                backOpacity = Double(1.0 - (progress < 0 ? -progress : progress))
            }
        }
    }
    func onEnd(value: DragGesture.Value) {
        withAnimation(.easeInOut) {
            var translation = value.translation.height
            if translation < 0 {
                translation = -translation
            }
            if translation < 250 {
                fullImageOffset = .zero
                backOpacity = 1.0
            } else {
                withAnimation {
                    showTab = false
//                    fullImageScale = 0.3

                   // fullImageOffset = .zero
                }
                
//                fullImageOffset = .zero
//                backOpacity = 1.0
            }
        }
    }
}
