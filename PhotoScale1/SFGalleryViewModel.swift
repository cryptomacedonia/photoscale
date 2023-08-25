//
//  SFGalleryViewModel.swift
//  PhotoScale1
//
//  Created by Igor Jovcevski on 25.8.23.
//

import Foundation
import SwiftUI
class SFGalleryViewModel : ObservableObject {
    @Published var allImages:[String] = ["image1", "image2","image3" ,"image4"]
 //   @Published var selectedImageIndex: Int? = nil
    @Published var selectedImageId: String = ""
    @Published var showTab = false
    @Published var fullImageOffset: CGSize = .zero
    @Published var backOpacity: Double = 1.0
    @Published var fullImageScale: CGFloat = 1
    func onChange(value: CGSize) {
        
        fullImageOffset = value
        
        let halfHeight = UIScreen.main.bounds.height / 2
        let progress = fullImageOffset.height / halfHeight
        withAnimation(.default) {
            backOpacity = Double(1.0 - (progress < 0 ? -progress : progress)) 
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
                showTab.toggle()
                fullImageOffset = .zero
                backOpacity = 1.0
            }
        }
    }
}
