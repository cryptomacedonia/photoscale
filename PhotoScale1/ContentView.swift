//
//  ContentView.swift
//  PhotoScale1
//
//  Created by Igor Jovcevski on 25.8.23.
//

import SwiftUI

struct ContentView: View {
    @State  var model = SFGalleryViewModel()
   
    var body: some View {
        GridView().frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading).environmentObject(model)
    }
}

struct GridView: View {
    @EnvironmentObject var model: SFGalleryViewModel
    init() {
        UIScrollView.appearance().bounces = false
    }
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(),spacing: 10), count: 3)
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 15 ,content: {
                ForEach(model.allImages.indices, id: \.self) {
                    index in
                    SFThumbView(index: index)
                }
            }).padding(20)
        }.overlay(
            ZStack {
                if model.showTab  {
                    ImageView().onAppear {
                        print(model.selectedImageId)
                    }
                }
            }
        )
        
    }
}

struct ImageView: View {
    @EnvironmentObject var model: SFGalleryViewModel
    @GestureState var draggingOffset: CGSize = .zero
    @State var selectedImage: String? = nil
    var body: some View {
        ZStack {
            Color.black.opacity(model.backOpacity).ignoresSafeArea()
            ScrollView(.init()) {
                TabView(selection: $model.selectedImageId) {
                    ForEach(model.allImages, id: \.self) {
                      image in
                        Image(image).resizable().aspectRatio(contentMode: .fit).tag(image).scaleEffect(model.selectedImageId == image ? (model.fullImageScale > 1 ? model.fullImageScale : 1) : 1).offset(model.fullImageOffset).gesture(MagnificationGesture().onChanged({ val in
                            model.fullImageScale = val
                        }).onEnded({ _ in
                            withAnimation(.spring()) {
                                model.fullImageScale = 1
                            }
                        }).simultaneously(with: TapGesture(count: 2).onEnded({
                            withAnimation {
                                model.fullImageScale  = model.fullImageScale > 1 ? 1 : 4
                            }
                        })))               }
                }.onAppear {
                   
                }.tabViewStyle(PageTabViewStyle()).overlay(
                    Button(action: {
                        withAnimation(.default) {
                            model.showTab.toggle()
                        }
                    }, label: {
                        Image(systemName: "xmark").foregroundColor(.white).padding().background(Color.white.opacity(0.2)).clipShape(Circle())
                    }).padding(10).padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top).opacity(model.backOpacity)
                    , alignment: .topTrailing )
            }.ignoresSafeArea().transition(.move(edge: .bottom))
        }.gesture(DragGesture().updating($draggingOffset, body: { val, out, _ in
            out = val.translation
            model.onChange(value: draggingOffset)
        }).onEnded(model.onEnd(value:)))
    }
}

struct SFThumbView: View {
    @EnvironmentObject var model: SFGalleryViewModel
    var index: Int
    var body: some View {
        Button {
            withAnimation {
                model.selectedImageId = model.allImages[index]
                model.fullImageOffset = .zero
                model.backOpacity = 1.0
                model.showTab = true
            }
        } label: {
            ZStack {
                Image(model.allImages[index]).resizable().aspectRatio(contentMode: .fill).frame(width: getRect().width / 3.7, height: getRect().width / 3.7).cornerRadius(6.0)
            }
        }

       
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: SFGalleryViewModel())
    }
}

extension View {
    func getRect() -> CGRect {
       return  UIScreen.main.bounds
    }
}
