//
//  ViewController.swift
//  ToDo
//
//  Created by Tuyen Le on 22.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import RealmSwift


class HomeController: UIViewController {
    
    private var todoList: [TaskType] = [TaskType]()
    
    let toDoCardIdentifier: String = "ToDoCard"
    let newCategoryCardIdentifier: String = "NewCategoryCard"

    lazy var taskTypeCollection: UICollectionView = {
        let layout: ToDoCardCollectionViewFLowLayout = ToDoCardCollectionViewFLowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.itemSize = CGSize(width: view.bounds.width/1.5, height: view.bounds.height/2.5)

        let collection: UICollectionView = UICollectionView(frame: CGRect(x: 0,
                                                    y: view.bounds.maxY - view.bounds.height/2,
                                                    width: view.bounds.width,
                                                    height: view.bounds.height/2),
                                      collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.isPagingEnabled = false
        collection.bounces = false
        collection.register(ToDoCard.self, forCellWithReuseIdentifier: toDoCardIdentifier)
        collection.register(NewCategoryCard.self, forCellWithReuseIdentifier: newCategoryCardIdentifier)

        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white

        view.addSubview(taskTypeCollection)
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        navigationController.setNavigationBarHidden(false, animated: false)
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

        todoCard.progressBar.percentage = 0
        todoCard.taskType = person.taskType[indexPath.row-1].type.rawValue
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
        try! realm.write {
            let taskType = person.taskType.filter {
                $0.type == choice
            }

            if taskType.count == 0 {
                taskTypeCollection.performBatchUpdates({
                    person.taskType.insert(newTaskType, at: 0)
                    self.taskTypeCollection.insertItems(at: [IndexPath(row: 1, section: 0)])
                }, completion: {
                    (finished: Bool) in self.taskTypeCollection.scrollToItem(at: IndexPath(row: 1, section: 0),
                                                                             at: UICollectionViewScrollPosition.centeredHorizontally,
                                                                             animated: true)
                })
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let todoCardIndex: Int = Int((collectionView.contentOffset.x - 10) / (view.bounds.width/1.5)) // 10 is space between card
        return todoCardIndex == indexPath.row ? true : false
    }
}

