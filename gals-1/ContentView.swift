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
                Image("tmb-games")
                    .frame(maxWidth: .infinity, alignment:.top)
                Spacer()
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
