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
        cameraButtonView.removeFromSuperview()
        crossOut.removeFromSuperview()
        cameraPreview.removeFromSuperview()
    }

    @objc func cancelImageView() {
        crossOut.removeFromSuperview()
        imageView.removeFromSuperview()
        circleCrop.removeFromSuperview()
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
                                          width: self.view.bounds.width - self.view.bounds.width/8,
                                          height: 20))
        label.font = UIFont(name: "AvenirNext-Bold", size: 12)
        label.textColor = .gray

        if tasksToDo == 0 {
            label.text = "There are no more tasks left to do."
        } else {
            label.text = "You have \(totalTaskToDoToday) tasks to do today."
        }
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // add total tasks to do today
        view.addSubview(taskReminderLabel)

        // get random quote of the day
        Network.getQuoteOfDay { quote in
            let quoteLabel = UILabel(frame: CGRect(x: self.view.bounds.width/8,
                                                   y: self.view.bounds.height/4,
                                                   width: self.view.bounds.width - self.view.bounds.width/8,
                                                   height: 100))
            quoteLabel.text = quote
            quoteLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 10)
            quoteLabel.textColor = .gray
            quoteLabel.numberOfLines = 5
            self.view.addSubview(quoteLabel)
        }

        // home screen title
        title = "TO DO"
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "AvenirNext-DemiBold", size: 12)!, .foregroundColor: UIColor.gray]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white

        // current date label above todo type carousel card
        let currentDateComponent: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let currentDate: String = "\(monthInString(currentDateComponent.month!)) \(currentDateComponent.day!), \(currentDateComponent.year!)"
        let currentDateLabel: UILabel = UILabel()

        currentDateLabel.attributedText = NSMutableAttributedString().boldGray("Today : ").normal(currentDate)
        currentDateLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(currentDateLabel)

        currentDateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width/8).isActive = true
        currentDateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        view.addSubview(taskTypeCollection)
        view.addSubview(profilePicture)

        profilePicture.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.bounds.width/8).isActive = true
        profilePicture.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height/8).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        let todoCardIndex: Int = Int((taskTypeCollection.contentOffset.x - 10) / (view.bounds.width/1.5))
        let tasksToDo = totalTaskToDoToday
        navigationController?.delegate = self
        taskTypeCollection.reloadItems(at: [IndexPath(row: todoCardIndex, section: 0)])

        if tasksToDo > 0 {
            taskReminderLabel.text = "You have \(totalTaskToDoToday) tasks to do today."
        }
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
        let todoCardIndex: Int = Int((taskTypeCollection.contentOffset.x - 10) / (view.bounds.width/1.5))
        return ToDoCardPresentAnimator(navigationBarMaxY: navigationController.navigationBar.frame.maxY, todoCardIndex: todoCardIndex)
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
        let todoCardIndex: Int = Int((collectionView.contentOffset.x - 10) / (view.bounds.width/1.5)) // 10 is space between card
        return todoCardIndex == indexPath.row
    }
}

