//
//  ViewController.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 26.01.2023.
//

import CollectionViewWaterfallLayout
import SnapKit
import UIKit

protocol FindPhotosViewProtocol: AnyObject {
    func reloadData()
}

final class FindPhotosViewController: UIViewController, FindPhotosViewProtocol {
    
    var presenter: FindPhotosPresenterProtocol?
    
    enum Constants {
        static let textSize: CGFloat = 20
        static let spacing: CGFloat = 8
        static let topSpacing: CGFloat = 24
        static let bottomSpacing: CGFloat = 100
        static let radius: CGFloat = 6
        static let top = 16
        static let leading = 16
        static let bottom = 56
        static let navViewHeight = 124
        static let buttonHeight = 52
    }
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(radius: Constants.radius,
                             mask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Find photos"
        label.font = UIFont.interBold(Constants.textSize)
        label.textColor = .black
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.setImage(UIImage(named: "magnifying_glass"), for: .search, state: .normal)
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        let layout = CollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = Float(Constants.spacing)
        layout.minimumInteritemSpacing = Float(Constants.spacing)
        layout.sectionInset = UIEdgeInsets(top: Constants.topSpacing,
                                           left: Constants.spacing,
                                           bottom: Constants.bottomSpacing,
                                           right: Constants.spacing)
        collectionView.collectionViewLayout = layout
        collectionView.register(classCell: PhotoCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var nextButton: MainButton = {
        let button = MainButton()
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
        
    }()
    
    private var viewDidLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayout {
            navView.addBottomShadow()
            viewDidLayout = true
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.nextButton.isHidden = self.presenter?.isHideNextButton ?? true
        }
    }
    
    private func setup() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        self.nextButton.isHidden = self.presenter?.isHideNextButton ?? true
        
        self.view.addSubview(collectionView)
        self.view.addSubview(navView)
        self.view.addSubview(nextButton)
        
        navView.addSubview(titleLabel)
        navView.addSubview(searchBar)
        
        makeConstraints()
    }
    
    @objc
    private func tappedNextButton() {
        presenter?.tappedNextButton()
    }
    
    private func makeConstraints() {
        navView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(Constants.navViewHeight)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.top)
            $0.centerX.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.top)
            $0.leading.equalToSuperview().offset(Constants.leading)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.leading)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-Constants.bottom)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }
    
}

extension FindPhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return presenter?.photoModels.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: PhotoCell.self, indexPath: indexPath)
        let image = presenter?.getImage(by: indexPath.item) ?? UIImage()
        cell.setupImage(image)
        cell.markAsSelect(presenter?.isSelectImage(by: indexPath.item) ?? false)
        return cell
    }
}

extension FindPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        presenter?.selecteImage(by: indexPath.item)
    }
}

extension FindPhotosViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let photo = presenter?.photoModels[indexPath.item]
        guard let width = photo?.width,
              let height = photo?.height else {
            return CGSize()
        }
        return CGSize(width: width, height: height)
    }
}

extension FindPhotosViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.query = searchText
    }
}
