import SwiftUI
import AVFoundation

// MARK: - SwiftUI wrapper

struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onImageCaptured = onImageCaptured
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// MARK: - UIKit Camera Controller

class CameraViewController: UIViewController {

    var onImageCaptured: ((UIImage) -> Void)?

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkPermissionAndSetup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning { session.stopRunning() }
    }

    // MARK: Permission

    private func checkPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.setupCamera() } else { self?.showPermissionDenied() }
                }
            }
        default:
            showPermissionDenied()
        }
    }

    // MARK: Camera Setup

    private func setupCamera() {
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at: 0)
        previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }

        DispatchQueue.main.async { self.addCaptureUI() }
    }

    // MARK: UI

    private func addCaptureUI() {
        // Viewfinder guide
        let guide = LabelFrameGuideView()
        guide.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guide)
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: view.topAnchor),
            guide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            guide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Capture button
        let captureBtn = CaptureButton()
        captureBtn.translatesAutoresizingMaskIntoConstraints = false
        captureBtn.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureBtn)
        NSLayoutConstraint.activate([
            captureBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -30),
            captureBtn.widthAnchor.constraint(equalToConstant: 72),
            captureBtn.heightAnchor.constraint(equalToConstant: 72)
        ])

        // Cancel button
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 17)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelBtn)
        NSLayoutConstraint.activate([
            cancelBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 10)
        ])

        // Instruction label
        let hint = UILabel()
        hint.text = "Position the care label inside the frame"
        hint.textColor = .white
        hint.font = .systemFont(ofSize: 14, weight: .medium)
        hint.textAlignment = .center
        hint.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hint)
        NSLayoutConstraint.activate([
            hint.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hint.bottomAnchor.constraint(equalTo: captureBtn.topAnchor, constant: -20)
        ])
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func cancel() {
        dismiss(animated: true)
    }

    // MARK: Permission Denied UI

    private func showPermissionDenied() {
        let label = UILabel()
        label.text = "Camera access is required to scan laundry labels.\n\nPlease enable it in Settings."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        let settingsBtn = UIButton(type: .system)
        settingsBtn.setTitle("Open Settings", for: .normal)
        settingsBtn.translatesAutoresizingMaskIntoConstraints = false
        settingsBtn.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        view.addSubview(settingsBtn)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            settingsBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsBtn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
    }

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Photo Capture Delegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard
            error == nil,
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else { return }

        onImageCaptured?(image)
    }
}

// MARK: - Viewfinder Guide Overlay

final class LabelFrameGuideView: UIView {
    override init(frame: CGRect) { super.init(frame: frame); backgroundColor = .clear }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func draw(_ rect: CGRect) {
        let inset: CGFloat = 32
        let w = rect.width - 2 * inset
        let guideRect = CGRect(x: inset,
                               y: rect.midY - w * 0.38,
                               width: w,
                               height: w * 0.75)

        // Dimmed surround
        let dimPath = UIBezierPath(rect: rect)
        let cutout  = UIBezierPath(roundedRect: guideRect, cornerRadius: 10)
        dimPath.append(cutout)
        dimPath.usesEvenOddFillRule = true
        UIColor.black.withAlphaComponent(0.45).setFill()
        dimPath.fill()

        // Corner brackets
        let len: CGFloat = 22
        let lw:  CGFloat = 3
        UIColor.white.setStroke()

        let corners: [(CGPoint, CGPoint, CGPoint)] = [
            // top-left
            (CGPoint(x: guideRect.minX, y: guideRect.minY + len),
             CGPoint(x: guideRect.minX, y: guideRect.minY),
             CGPoint(x: guideRect.minX + len, y: guideRect.minY)),
            // top-right
            (CGPoint(x: guideRect.maxX - len, y: guideRect.minY),
             CGPoint(x: guideRect.maxX, y: guideRect.minY),
             CGPoint(x: guideRect.maxX, y: guideRect.minY + len)),
            // bottom-right
            (CGPoint(x: guideRect.maxX, y: guideRect.maxY - len),
             CGPoint(x: guideRect.maxX, y: guideRect.maxY),
             CGPoint(x: guideRect.maxX - len, y: guideRect.maxY)),
            // bottom-left
            (CGPoint(x: guideRect.minX + len, y: guideRect.maxY),
             CGPoint(x: guideRect.minX, y: guideRect.maxY),
             CGPoint(x: guideRect.minX, y: guideRect.maxY - len))
        ]

        for (p1, p2, p3) in corners {
            let path = UIBezierPath()
            path.lineWidth = lw
            path.lineCapStyle = .round
            path.move(to: p1)
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.stroke()
        }
    }
}

// MARK: - Shutter Button

final class CaptureButton: UIButton {
    override init(frame: CGRect) { super.init(frame: frame); backgroundColor = .clear }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func draw(_ rect: CGRect) {
        let outer = UIBezierPath(ovalIn: rect.insetBy(dx: 3, dy: 3))
        UIColor.white.setStroke()
        outer.lineWidth = 3
        outer.stroke()

        let inner = UIBezierPath(ovalIn: rect.insetBy(dx: 9, dy: 9))
        UIColor.white.setFill()
        inner.fill()
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.65 : 1.0 }
    }
}
