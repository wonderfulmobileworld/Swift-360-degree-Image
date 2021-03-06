//
//  Image360Controller.swift
//  Image360
//

import UIKit

private let blackFileURL = Bundle(for: Image360Controller.self).url(forResource: "black", withExtension: "jpg")!

/// ## Image360Controller
/// This controller presentes a special view to dysplay 360° panoramic image.
public class Image360Controller: UIViewController {
    /// Image 360 view which actually dysplays 360° panoramic image.
    public var imageView: Image360View {
        return image360GLController.imageView
    }
    /// Special OpenGL controller to ouput Image360View
    private let image360GLController: Image360GLController = Image360GLController()
    /// Displays current camera position.
    private var orientationView: OrientationView!

    // MARK: Inertia

    /// Inertia of pan gestures. In case inertia is enabled view of
    /// `Image360Controller` continue to rotate after pan gestures for some time.
    /// Range of value: 0...1
    public var inertia: Float {
        get {
            return _inertia
        }
        set {
            if newValue < 0 {
                _inertia = 0
            } else if newValue > 1 {
                _inertia = 1
            } else {
                _inertia = newValue
            }
        }
    }
    
    private var _inertia: Float = 0.1 {
        didSet {
            gestureController.inertia = _inertia
            motionController.inertia = _inertia
        }
    }

    /// Image presented in controller at the moment. Image need to be captured by special
    /// 360° panoramic camera or generated by special software.
    public var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    /// Set this flag `true` to hide orientation view.
    public var isOrientationViewHidden: Bool {
        get {
            return orientationView.isHidden
        }
        set {
            orientationView.isHidden = newValue
        }
    }
    
    // MARK: Gesture management
    /// If this flag is `true` then `ImageView360`-orientation could be controled with gestures.
    public var isGestureControlEnabled: Bool {
        get {
            return gestureController.isEnabled
        }
        set {
            gestureController.isEnabled = newValue
        }
    }
    
    /// Controller which rotates & scales view by handling user's gestures.
    public var gestureController: Controller = GestureController() {
        didSet {
            gestureController.imageView = imageView
            gestureController.inertia = inertia
        }
    }
    
    // MARK: Motion management
    /// If this flag is `true` then `ImageView360`-orientation could be controled with device motions.
    public var isDeviceMotionControlEnabled: Bool {
        get {
            return isAppear ? motionController.isEnabled : isMotionControllerEnabled
        }
        set {
            if isAppear {
                motionController.isEnabled = newValue
            } else {
                isMotionControllerEnabled = newValue
            }
        }
    }
    
    /// Controller which rotates & scales view by handling device's motions.
    public var motionController: Controller = MotionController() {
        didSet {
            motionController.imageView = imageView
            motionController.inertia = inertia
            if isAppear {
                isMotionControllerEnabled = motionController.isEnabled
            }
        }
    }
    
    public init() {
        isMotionControllerEnabled = motionController.isEnabled
        
        super.init(nibName: nil, bundle: nil)
        
        inertia = 0.1
        motionController.inertia = inertia
        gestureController.inertia = inertia
    }

    public required init?(coder aDecoder: NSCoder) {
        isMotionControllerEnabled = motionController.isEnabled
        
        super.init(coder: aDecoder)
        
        inertia = 0.1
        motionController.inertia = inertia
        gestureController.inertia = inertia
    }

    public override func loadView() {
        super.loadView()
        let orientationView = OrientationView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        orientationView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        orientationView.tintColor = .white
        self.orientationView = orientationView
        
        motionController.imageView = imageView
        gestureController.imageView = imageView
        imageView.orientationView = orientationView
        setBlackBackground()
        
        addChild(image360GLController)
        view.addSubview(imageView)
        image360GLController.view.frame = view.bounds
        image360GLController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        image360GLController.didMove(toParent: self)
        
        view.addSubview(orientationView)
        orientationView.frame = CGRect(origin: CGPoint(x: view.bounds.maxX - orientationView.frame.size.width - 8,
                                                       y: view.bounds.midY - orientationView.bounds.midY),
                                       size: orientationView.frame.size)
        orientationView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    }

    // MARK: Appear/Disappear
    private var isAppear = false
    /// Keeps data about motion controller enabled status while view is not appear.
    private var isMotionControllerEnabled: Bool

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.loadTexturesIfNeeded()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        motionController.isEnabled = isMotionControllerEnabled
        isAppear = true
    }

    public override func viewDidDisappear(_ animated: Bool) {
        imageView.unloadTextures()

        super.viewDidDisappear(animated)
        isMotionControllerEnabled = motionController.isEnabled
        motionController.isEnabled = false
        isAppear = false
    }

    // MARK: Helpers
    private func setBlackBackground() {
        let data = (try? Data(contentsOf: blackFileURL))!
        let image = UIImage(data: data)!
        imageView.image = image
    }
}
