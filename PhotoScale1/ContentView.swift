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
    @Namespace var namespace
    init() {
        UIScrollView.appearance().bounces = false
    }
    @State var isSource = true
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(),spacing: 10), count: 3)
        ScrollView {
            ScrollViewReader { proxy in
            LazyVGrid(columns: columns, alignment: .center, spacing: 15 ,content: {
                ForEach(model.allImages.indices, id: \.self) {
                    index in
//                    VStack {
//                        Button {
//                            proxy.scrollTo("image24")
//                        } label: {
//                            Text("Test")
//                        }

                    SFThumbView(namespace: namespace, index: index).opacity(model.selectedImageId == model.allImages[index] && model.showTab ? 0.05 : 1.0).id(model.allImages[index]).matchedGeometryEffect(id: model.allImages[index], in: namespace, isSource: !model.showTab)
//                    }.id(model.allImages[index])
                    
                }
            }).padding(20).onChange(of: model.selectedImageId) { newValue in
               
                    proxy.scrollTo(newValue)
                
            }.onChange(of: model.showTab) { newValue in
                
                isSource.toggle()
            
        }
            }
        }.overlay(
            ZStack {
                if model.showTab  {
                    ImageView(namespace:namespace)
                }
            }
        ).onChange(of: model.showTab) { newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    model.opacityOfSelectedItem = model.showTab ? 0.0 : 1.0
                }
            }
        }
        
    }
}

struct ImageView: View {
    let namespace: Namespace.ID
    @EnvironmentObject var model: SFGalleryViewModel
    @GestureState var draggingOffset: CGSize = .zero
    @State var selectedImage: String? = nil
//    @State var isSource = false
    var body: some View {
        ZStack {
            Color.black.opacity(model.backOpacity).ignoresSafeArea()
            ScrollView(.init()) {
                TabView(selection: $model.selectedImageId) {
                    ForEach(model.allImages, id: \.self) {
                      image in
                        Image(image).resizable().aspectRatio(contentMode: .fit).tag(image).scaleEffect(model.selectedImageId == image ? (model.fullImageScale > 1 ? model.fullImageScale : 1) : 1).offset(model.fullImageOffset).matchedGeometryEffect(id: image, in: namespace, isSource:model.showTab  ).gesture(MagnificationGesture().onChanged({ val in
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
        }.opacity(1.0).gesture(DragGesture().updating($draggingOffset, body: { val, out, _ in
            out = val.translation
            model.onChange(value: draggingOffset)
        }).onEnded(model.onEnd(value:)))
    }
}

struct SFThumbView: View {
    @EnvironmentObject var model: SFGalleryViewModel
    let namespace: Namespace.ID
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
            }.opacity(model.allImages[index] == model.selectedImageId ? model.opacityOfSelectedItem : 1.0)
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
