//
//  ContentView.swift
//  gals-1
//
//  Created by Grace
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        CameraView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    var body: some View {
        
        //camera preview
        ZStack{
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            VStack {
                Image("overlay").resizable()
            }
            VStack {
                Image("intro")
                    .frame(maxWidth: .infinity, alignment:.top)
                    .padding(.vertical, 24)
                
                Spacer()
                
                Text("Place the character on the platform screen into this shape.")
                    .font(Font.custom("gt-walsheim-web", size: 18, relativeTo: .title))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: 300, alignment:.bottom)
                    .padding(24)
            }
    
            
        }
        .onAppear(perform: {
            camera.check()
        })
        
    }
    
}


class CameraModel: ObservableObject {
        
    @Published var isTaken = false;
    @Published var session = AVCaptureSession();
    @Published var alert = false;
    @Published var output = AVCapturePhotoOutput();
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    func check(){
        
        // first checking for camera permission
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status{
                    self.setUp()
                    return
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
        
    }
    
    func setUp() {
        
        do {
            self.session.beginConfiguration()
            
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
}

struct CameraPreview: UIViewRepresentable {
 
    @ObservedObject var camera: CameraModel;
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
