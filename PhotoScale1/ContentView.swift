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
    @State var isSource = true
    var body: some View {
        let columns = Array(repeating: GridItem(.fixed(self.getRect().width/3.7),spacing: 10), count: 3)
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

                    SFThumbView( index: index).opacity(model.selectedImageId == model.allImages[index] && model.showTab ? 0.05 : 1.0).id(model.allImages[index]).frame(height: getRect().width/3.7)
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
                    ImageView()
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
                      //  GeometryReader { geometry in
                            VStack {
                                Spacer()
                              
                                    Image(image).resizable().aspectRatio(contentMode: .fit)
                                       
                                        .aspectRatio(contentMode: .fit).tag(image).scaleEffect(model.selectedImageId == image ? (model.fullImageScale > 1 || model.fullImageScale < 1  ? model.fullImageScale : 1) : 1).offset(model.fullImageOffset).gesture(MagnificationGesture(
                                        ).onChanged({ val in
                                            model.fullImageScale = val
                                        }).onEnded({ _ in
                                            withAnimation(.spring()) {
                                                model.fullImageScale = 1
                                            }
                                        }).simultaneously(with: TapGesture(count: 2).onEnded({
                                            withAnimation {
                                                model.fullImageScale  = model.fullImageScale > 1 ? 1 : 4
                                            }
                                        }))).readSize(onChange: { size in
                                            print(size)
                                        })
                                    
                                
                                Spacer()
                            }
                            
                       // }
                        
                    }
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

    var index: Int
    var body: some View {
        GeometryReader { geometry in
            Button {
                withAnimation {
                    model.selectedImageId = model.allImages[index]
                    model.fullImageOffset = .zero
                    model.backOpacity = 1.0
                    model.selectedItemFrame =  geometry.frame(in: .global)
                    model.showTab = true
                }
            } label: {
                ZStack {
                    Image(model.allImages[index]).resizable().aspectRatio(contentMode: .fill).frame(width:geometry.size.width,height:geometry.size.height).cornerRadius(6.0)
                }.clipped().opacity(model.allImages[index] == model.selectedImageId ? model.opacityOfSelectedItem : 1.0)
            }.onAppear {
              //  print (geometry.frame(in: .global))
               
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

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
