//
//  NCViewerImageCommon.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 04/03/2020.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class NCViewerImageCommon: NSObject {
    @objc static let shared: NCViewerImageCommon = {
        let instance = NCViewerImageCommon()
        return instance
    }()
    
    static var offOutlineAudio: UIImage?
    static var offOutlineVideo: UIImage?
    static var offOutlineImage: UIImage?

    override init() {
        NCViewerImageCommon.offOutlineAudio = CCGraphics.changeThemingColorImage(UIImage.init(named: "offOutlineAudio"), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width, color: NCBrandColor.sharedInstance.brand)
        NCViewerImageCommon.offOutlineVideo = CCGraphics.changeThemingColorImage(UIImage.init(named: "offOutlineVideo"), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width, color: NCBrandColor.sharedInstance.brand)
        NCViewerImageCommon.offOutlineImage = CCGraphics.changeThemingColorImage(UIImage.init(named: "offOutlineImage"), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width, color: NCBrandColor.sharedInstance.brand)
    }
    
    
    func getMetadatasDatasource(metadata: tableMetadata?, metadatas: [tableMetadata],favoriteDatasorce: Bool, mediaDatasorce: Bool, offLineDatasource: Bool) -> [tableMetadata]? {
        guard let metadata = metadata else { return nil }
        if favoriteDatasorce {
            let metadatas = NCManageDatabase.sharedInstance.getMetadatasViewer(predicate: NSPredicate(format: "account == %@ AND favorite == 1 AND (typeFile == %@ || typeFile == %@ || typeFile == %@)", metadata.account, k_metadataTypeFile_image, k_metadataTypeFile_video, k_metadataTypeFile_audio), sorted: CCUtility.getOrderSettings(), ascending: CCUtility.getAscendingSettings())
            if metadatas == nil {
                return [metadata]
            }
        } else if mediaDatasorce {
            return metadatas
        } else if offLineDatasource {
            var datasourceSorted = ""
            var datasourceAscending = true
            (_, datasourceSorted, datasourceAscending, _, _) = NCUtility.sharedInstance.getLayoutForView(key: k_layout_view_offline)
            if let files = NCManageDatabase.sharedInstance.getTableLocalFiles(predicate: NSPredicate(format: "account == %@ AND offline == true", metadata.account), sorted: datasourceSorted, ascending: datasourceAscending) {
                var ocIds = [String]()
                for file: tableLocalFile in files {
                    ocIds.append(file.ocId)
                }
                return NCManageDatabase.sharedInstance.getMetadatasViewer(predicate: NSPredicate(format: "account == %@ AND ocId IN %@ AND (typeFile == %@ || typeFile == %@ || typeFile == %@)", metadata.account, ocIds, k_metadataTypeFile_image, k_metadataTypeFile_video, k_metadataTypeFile_audio), sorted: datasourceSorted, ascending: datasourceAscending)
            }
        } else {
            return NCManageDatabase.sharedInstance.getMetadatasViewer(predicate: NSPredicate(format: "account == %@ AND serverUrl == %@ AND (typeFile == %@ || typeFile == %@ || typeFile == %@)", metadata.account, metadata.serverUrl, k_metadataTypeFile_image, k_metadataTypeFile_video, k_metadataTypeFile_audio), sorted: CCUtility.getOrderSettings(), ascending: CCUtility.getAscendingSettings())
        }
        
        return nil
    }
    
    func getThumbnailImage(metadata: tableMetadata) -> UIImage? {
        
        if CCUtility.fileProviderStorageIconExists(metadata.ocId, fileNameView: metadata.fileNameView) {
            let imagePath = CCUtility.getDirectoryProviderStorageIconOcId(metadata.ocId, fileNameView: metadata.fileNameView)!
            return UIImage.init(contentsOfFile: imagePath)
        }
        
        return nil
    }
    
    func getImage(metadata: tableMetadata) -> UIImage? {
        
        var image: UIImage?
        
        if CCUtility.fileProviderStorageSize(metadata.ocId, fileNameView: metadata.fileNameView) > 0 && metadata.typeFile == k_metadataTypeFile_image {
           
            let imagePath = CCUtility.getDirectoryProviderStorageOcId(metadata.ocId, fileNameView: metadata.fileNameView)!
            let ext = CCUtility.getExtension(metadata.fileNameView)
            if ext == "GIF" { image = UIImage.animatedImage(withAnimatedGIFURL: URL(fileURLWithPath: imagePath)) }
            else { image = UIImage.init(contentsOfFile: imagePath) }
        }
        
        return image
    }
    
    func imageChangeSizeView(viewerImageViewController: NCViewerImageViewController?, size: CGSize, metadata: tableMetadata?) {
        guard let viewerImageViewController = viewerImageViewController else { return }
        
        var image: UIImage?
        var contentViewSaved : NCViewerImageContentView?
        for contentView in viewerImageViewController.contentViews {
            if contentView.position == 0 && contentView.isLoading == false {
                image = contentView.image
                contentViewSaved = contentView
                if metadata != nil , let thumbnailImage = self.getThumbnailImage(metadata: metadata!) {
                    contentView.image = thumbnailImage
                } else {
                    contentView.image = nil
                }
            }
        }
        
        DispatchQueue.main.async {
            viewerImageViewController.changeInViewSize(to: size)
            if image != nil {
                contentViewSaved?.image = image
            }
        }
    }

    func getImageOffOutline(frame: CGRect, type: String) -> UIImage {
        
        if type == k_metadataTypeFile_video {
            return NCViewerImageCommon.offOutlineVideo!
        }
        
        if type == k_metadataTypeFile_audio {
            return NCViewerImageCommon.offOutlineAudio!
        }
        
        return NCViewerImageCommon.offOutlineImage!
    }
}