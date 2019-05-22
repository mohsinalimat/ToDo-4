//
//  ViewController.swift
//  ToDo
//
//  Created by Tuyen Le on 22.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class HomeController: UIViewController {

    // MARK: - Camera action properties
    let toDoCardIdentifier: String = "ToDoCard"

    let toDoCardCollectionHeader: String = "toDoCardCollectionHeader"

    let newCategoryCardIdentifier: String = "NewCategoryCard"

    let captureSession: AVCaptureSession = AVCaptureSession()

    let stillImageOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    
    private var previousOffset: CGFloat = 0
    private var currentPage: Int = 0
    
    lazy var circleCrop: CircleCropView = {
       return CircleCropView(frame: CGRect(x: 10,
                                           y: UIScreen.main.bounds.height/2 -  UIScreen.main.bounds.height/4,
                                           width: UIScreen.main.bounds.width - 10,
                                           height: UIScreen.main.bounds.height/2))
    }()

    lazy var imageView: UIImageView = {
        return UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    }()

    lazy var cameraPreview: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
    }()

    lazy var profilePicture: UIButton = {
        let imageView = UIButton()

        if let profileImageFromRealm = person.profileImage {
            imageView.setImage(UIImage(data: profileImageFromRealm, scale: 3), for: .normal)
        } else {
            imageView.setImage(UIImage(named: "user"), for: .normal)
        }

        let image = imageView.image(for: .normal)!

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addTarget(self, action: #selector(photoOptions), for: UIControl.Event.touchUpInside)
        imageView.layer.cornerRadius = image.size.width/2
        /// shadow layer
        imageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        imageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        imageView.layer.shadowOpacity = 1.0
        imageView.layer.shadowRadius = 5
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = image.size.width/2
        return imageView
    }()

    /// view photo options
    @objc func photoOptions() {
        let alertPhotoOptions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertPhotoOptions.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: capturePhoto(action:)))
        alertPhotoOptions.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: pickImageFromLibrary(action:)))
        alertPhotoOptions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertPhotoOptions, animated: true, completion: nil)
    }

    func pickImageFromLibrary(action: UIAlertAction) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.imageExportPreset = .current
        present(imagePicker, animated: true, completion: nil)
    }

    func capturePhoto(action: UIAlertAction) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.inputs.count == 0 {
                captureSession.addInput(captureDeviceInput)
            }
        } catch let error {
            print("error unable to initialize back camera: ", error.localizedDescription)
        }

        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            captureSession.addOutput(stillImageOutput)
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)

        previewLayer.frame = view.bounds
        previewLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreview.layer.addSublayer(previewLayer)

        view.addSubview(cameraPreview)
        view.addSubview(cameraButtonView)
        view.addSubview(crossOut)

        crossOut.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        crossOut.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    lazy var capturePhotoButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "len"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = button.currentImage!.size.width/2
        button.layer.backgroundColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(captureAndSaveImage), for: .touchUpInside)
        return button
    }()

    lazy var cameraButtonView: UIView = {
        let cameraButtonView: UIView = UIView(frame: CGRect(x: 0, y: view.bounds.maxY - 120, width: view.bounds.width, height: 120))
        cameraButtonView.backgroundColor = .clear
        
        cameraButtonView.addSubview(capturePhotoButton)
        capturePhotoButton.centerXAnchor.constraint(equalTo: cameraButtonView.centerXAnchor).isActive = true
        capturePhotoButton.centerYAnchor.constraint(equalTo: cameraButtonView.centerYAnchor).isActive = true
        return cameraButtonView
    }()

    /// use for canceling image capture
    lazy var crossOut: UIButton = {
        let image: UIButton = UIButton()
        image.setImage(UIImage(named: "crossOut"), for: .normal)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.addTarget(self, action: #selector(cancelImageCapture), for: .touchUpInside)
        return image
    }()

    /// done cropping image text
    lazy var doneCropImage: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneCroppingImageAction), for: .touchUpInside)
        return button
    }()

    /// done crop image action. The actual cropping
    @objc func doneCroppingImageAction() {
        guard let _ = imageView.image else { return }

        let targetSize = profilePicture.bounds.size

        guard let cropImage = circleCrop.cropImage(imageView, targetSize),
            let cropImagePngData = cropImage.pngData() else { return }
        
        profilePicture.layer.cornerRadius = cropImage.size.width/2
        profilePicture.setImage(cropImage, for: .normal)

        do {
            try realm.write {
                person.profileImage = cropImagePngData
            }
        } catch let error {
            print(error.localizedDescription)
        }


        cancelImageView()
    }

    lazy var toDoCardLayout: ToDoCardCollectionViewFLowLayout = {
        let layout: ToDoCardCollectionViewFLowLayout = ToDoCardCollectionViewFLowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.itemSize = CGSize(width: view.bounds.width/1.5, height: view.bounds.height/2.5)
        
        return layout
    }()

    @objc func cancelImageCapture() {
        captureSession.stopRunning()
        captureSession.removeOutput(stillImageOutput)
        doneCropImage.removeFromSuperview()
        cameraButtonView.removeFromSuperview()
        crossOut.removeFromSuperview()
        cameraPreview.removeFromSuperview()
    }

    @objc func cancelImageView() {
        doneCropImage.removeFromSuperview()
        crossOut.removeFromSuperview()
        imageView.removeFromSuperview()
        circleCrop.removeFromSuperview()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc func captureAndSaveImage() {
        let photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    lazy var taskTypeCollection: UICollectionView = {
        let collection: UICollectionView = UICollectionView(frame: CGRect(x: 0,
                                                                          y: view.bounds.maxY - view.bounds.height/2,
                                                                          width: view.bounds.width,
                                                                          height: view.bounds.height/2),
                                                            collectionViewLayout: toDoCardLayout)

        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.isPagingEnabled = false
        collection.bounces = false
        collection.register(ToDoCard.self, forCellWithReuseIdentifier: toDoCardIdentifier)
        collection.register(NewCategoryCard.self, forCellWithReuseIdentifier: newCategoryCardIdentifier)

        return collection
    }()

    fileprivate func monthInString(_ month: Int) -> String {
        switch month {
        case 1: return "January"
        case 2: return "Feburary"
        case 3: return "March"
        case 4: return "April"
        case 5: return "May"
        case 6: return "June"
        case 7: return "July"
        case 8: return "August"
        case 9: return "September"
        case 10: return "October"
        case 11: return "November"
        case 12: return "December"
        default: fatalError("Invalid month")
        }
    }

    var totalTaskToDoToday: Int {
        let currentDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        var totalTaskToDoToday = 0
        for taskType in person.taskType {
            let tasksToDo = taskType.tasks.filter {
                let taskDate = Calendar.current.dateComponents([.year, .month, .day], from: $0.date!)
                return taskDate.day! == currentDate.day! && taskDate.month! == currentDate.month! && taskDate.year! == currentDate.year!
            }

            totalTaskToDoToday += tasksToDo.count
        }

        return totalTaskToDoToday
    }

    lazy var taskReminderLabel: UILabel = {
        let tasksToDo = totalTaskToDoToday
        let label = UILabel(frame: CGRect(x: view.bounds.width/8,
                                          y: view.bounds.height/4,
                                          width: view.bounds.width - view.bounds.width/8,
                                          height: 40))
        label.font = UIFont(name: "AvenirNext-Bold", size: 12)
        label.textColor = .white
        label.numberOfLines = 2

        return label
    }()
    
    lazy var quoteLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: self.view.bounds.width/8,
                                          y: self.view.bounds.height/3.8,
                                          width: self.view.bounds.width - self.view.bounds.width/8,
                                          height: 100))
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 10)
        label.textColor = .white
        label.numberOfLines = 5
        return label
    }()
    
    var gradientColor: [[Any]] {
        return [
            [UIColor(red: 0.45, green: 0.58, blue: 0.87, alpha: 1.0).cgColor, UIColor(red: 0.51, green: 0.85, blue: 0.87, alpha: 1.0).cgColor],
            [UIColor(red: 0.97, green: 0.63, blue: 0.35, alpha: 1.0).cgColor, UIColor(red: 0.96, green: 0.45, blue: 0.42, alpha: 1.0).cgColor],
            [UIColor(red: 0.54, green: 0.29, blue: 0.40, alpha: 1.0).cgColor, UIColor(red: 0.87, green: 0.40, blue: 0.54, alpha: 1.0).cgColor],
            [UIColor(red: 0.68, green: 0.69, blue: 0.91, alpha: 1.0).cgColor, UIColor(red: 0.56, green: 0.34, blue: 0.83, alpha: 1.0).cgColor],
            [UIColor(red: 0.13, green: 0.38, blue: 0.40, alpha: 1.0).cgColor, UIColor(red: 0.22, green: 0.53, blue: 0.41, alpha: 1.0).cgColor],
            [UIColor(red: 0.46, green: 0.53, blue: 0.23, alpha: 1.0).cgColor, UIColor(red: 0.67, green: 0.73, blue: 0.68, alpha: 1.0).cgColor]
        ]
    }
    
    lazy var backgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = gradientColor[0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        return gradientLayer
    }()
    
    lazy var nagigationBarGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [gradientColor[0][0]]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        return gradientLayer
    }()
    
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // gradient background color
        view.layer.addSublayer(backgroundGradientLayer)

        // home screen title and navigation bar gradient
        title = "TO DO"
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "AvenirNext-DemiBold", size: 12)!, .foregroundColor: UIColor.gray]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(getImageFrom(gradientLayer: nagigationBarGradientLayer), for: .default)

        // current date label above todo type carousel card
        let currentDateComponent: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let currentDate: String = "\(monthInString(currentDateComponent.month!)) \(currentDateComponent.day!), \(currentDateComponent.year!)"
        let currentDateLabel: UILabel = UILabel()

        currentDateLabel.attributedText = NSMutableAttributedString().boldWhite("Today : ").normalWhite(currentDate)
        currentDateLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(currentDateLabel)

        currentDateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width/8).isActive = true
        currentDateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        view.addSubview(taskTypeCollection)
        view.addSubview(profilePicture)

        profilePicture.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width/8).isActive = true
        profilePicture.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height/8).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get random quote of the day
        Network.getQuoteOfDay { quote in
            self.quoteLabel.text = quote
            if self.quoteLabel.superview == nil {
                self.view.addSubview(self.quoteLabel)
            }
        }
        // update tasks to do today
        let tasksToDo = totalTaskToDoToday
        let firstName = person.firstName ?? ""
        
        if taskReminderLabel.superview == nil {
            view.addSubview(taskReminderLabel)
        }

        if tasksToDo == 0 {
            taskReminderLabel.text = "Hello, \(firstName). \nThere are no more tasks left to do."
        } else {
            taskReminderLabel.text = "Hello, \(firstName). \nYou have \(totalTaskToDoToday) tasks to do today."
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let todoCardIndex: Int = Int((taskTypeCollection.contentOffset.x - 10) / (view.bounds.width/1.5))
        navigationController?.delegate = self
        taskTypeCollection.reloadItems(at: [IndexPath(row: todoCardIndex, section: 0)])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeController: UIImagePickerControllerDelegate {
    /// pick image from photo library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            guard let pickedImageFromLibrary = info[.originalImage] as? UIImage else { return }
            let targetSize = self.profilePicture.frame.size

            guard let cropImage = self.circleCrop.cropImage(pickedImageFromLibrary, targetSize),
                  let cropImagePngData = cropImage.pngData() else { return }
            self.profilePicture.layer.cornerRadius = cropImage.size.width/2
            self.profilePicture.setImage(cropImage, for: .normal)

            do {
                try realm.write {
                    person.profileImage = cropImagePngData
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
    }
}

extension HomeController: AVCapturePhotoCaptureDelegate {
    /// crop image or cancel after photo capture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let unmanage = photo.cgImageRepresentation()

        if let image = unmanage?.takeUnretainedValue() {
            let newCaptureImage = UIImage(cgImage: image, scale: 1, orientation: .right)
            imageView.image = newCaptureImage

            navigationController?.setNavigationBarHidden(true, animated: false)

            cancelImageCapture()

            view.addSubview(imageView)
            view.addSubview(circleCrop)

            crossOut.addTarget(self, action: #selector(cancelImageView), for: .touchUpInside)
            view.addSubview(crossOut)
            view.addSubview(doneCropImage)

            crossOut.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
            crossOut.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true

            doneCropImage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
            doneCropImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        }
    }
}

extension HomeController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let _ = toVC as? ToDoViewController else { return nil }
        return ToDoCardPresentAnimator(navigationBarMaxY: navigationController.navigationBar.frame.maxY, todoCardIndex: currentPage)
    }
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
       return UIEdgeInsets(top: 0, left: view.bounds.width/8, bottom: 0, right: view.bounds.width/4)
    }
}

extension HomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let newCategoryCard = collectionView.dequeueReusableCell(withReuseIdentifier: newCategoryCardIdentifier, for: indexPath) as? NewCategoryCard,
            let todoCard = collectionView.dequeueReusableCell(withReuseIdentifier: toDoCardIdentifier, for: indexPath) as? ToDoCard else { return UICollectionViewCell() }

        if indexPath.row == 0 {
            return newCategoryCard
        }

        let taskType: Type = person.taskType[indexPath.row-1].type
        let percentage: Int = person.taskType[indexPath.row-1].percentage
        let taskCount: Int = person.taskType[indexPath.row-1].tasks.count

        todoCard.taskType = taskType.rawValue
        todoCard.numOfTask = taskCount
        todoCard.progressBar.setPercentage(percentage, animated: false)

        return todoCard
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return person.taskType.count == 0 ? 1 : person.taskType.count + 1 // Plus 1 because we need to include "Add Category" Card
    }
}

extension HomeController: UICollectionViewDelegate {
    var todoCardWidth: CGFloat {
        return view.bounds.width / 1.5 + 10
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if previousOffset > scrollView.contentOffset.x && velocity.x < 0 { // left slide
            currentPage = max(currentPage - 1, 0)
        } else if previousOffset < scrollView.contentOffset.x && velocity.x > 0 { // right slide
            currentPage = currentPage + 1
        }
        previousOffset = todoCardWidth * CGFloat(currentPage)
        backgroundGradientLayer.colors = gradientColor[currentPage]
        nagigationBarGradientLayer.colors = [gradientColor[currentPage][0]]
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width/1.5, height: view.bounds.height/2.5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for view in view.subviews {
            if let _ = view as? CategoryTextField {
                return  // prevent from adding multiple CategoryTextField on tap
            }
        }

        if indexPath.row == 0 {
            let categoryTextField: CategoryTextField = CategoryTextField()
            categoryTextField.categoryChoice = saveTaskType // notify category choice to update taskTypeCollection for insertion
            view.addSubview(categoryTextField)
        } else {
             performSegue(withIdentifier: "ToDo", sender: nil)
        }
    }
    
    func saveTaskType(choice: Type) {
        let newTaskType: TaskType = TaskType(type: choice)
        toDoCardLayout.newToDoCard = true

        let taskType = person.taskType.filter { $0.type == choice }

        if taskType.count == 0 {
            taskTypeCollection.performBatchUpdates({
                addTaskType(newTaskType)
                self.taskTypeCollection.insertItems(at: [IndexPath(row: 1, section: 0)])
            }, completion: {
                (finished: Bool) in
                let newContentOffset: CGPoint = CGPoint(x: self.view.bounds.width/1.5 + 10,
                                                        y: self.taskTypeCollection.contentOffset.y)
                self.currentPage = 1
                self.backgroundGradientLayer.colors = self.gradientColor[self.currentPage]
                self.nagigationBarGradientLayer.colors = [self.gradientColor[self.currentPage][0]]
                self.previousOffset = self.todoCardWidth * CGFloat(self.currentPage)
                self.taskTypeCollection.scrollToItem(at: IndexPath(row: 1, section: 0),
                                                        at: UICollectionView.ScrollPosition.centeredHorizontally,
                                                        animated: true)
                self.taskTypeCollection.setContentOffset(newContentOffset, animated: true)
            })
        }
    }
    
    fileprivate func addTaskType(_ type: TaskType) {
        do {
            try realm.write {
                person.taskType.insert(type, at: 0)
            }
        } catch let error {
            print("cannot add new task type: ", error)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return currentPage == indexPath.row
    }
}

