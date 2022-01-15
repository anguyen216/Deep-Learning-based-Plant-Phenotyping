"""
Data loading code for plant COCO annotations.
Adapted from the code cited below
- matterport_maskrcnn_2017
- title: Mask R-CNN for object detection and instance segmentation on Keras and TensorFlow
- author: Waleed Abdulla
- year: 2017
- publisher: Github
- journal: Github repository
- howpublished: https://github.com/matterport/Mask_RCNN

Adapted by Anh Nguyen
"""
import numpy as np
from skimage import io
import os
import sys
from pycocotools.coco import COCO
from pycocotools.coco import mask as maskUtils


# Root directory of the project
RCNN_DIR = os.path.abspath("./Mask_RCNN_master/")
IMAGE_DIR = "../data_resized"


# import mask RCNN
sys.path.append(RCNN_DIR)
from mrcnn.confit import Config
from mrcnn import utils

class PlantDataset(utils.Dataset):
    """
    Loading plant annotation data from COCO annotation
    The dataset consists of soybean plant images
    Annotation file includes annotation for leaf tip and plant collar
    """

    def load_plants(self, coco_path):
        """
        Load plant annotation from COCO.json file.
        Will load the entire data from the coco.json file
        User will have to split the annotation before hand
        Input:
        - path: path to the COCO annotation file
        """

        # Add all 2 classes
        self.add_class("plant", 1, "leaf")
        self.add_class("plant", 2, "collar")

        coco = COCO(coco_path)
        # Load all images from the coco.json file
        image_ids = list(coco.imgs.keys())
        # get path to all images
        image_paths = [IMAGE_DIR + coco.imgs[i]['file_name'] for i in image_ids]

        # Add images
        # all images have been resize to 224x224
        for idx, id in enumerate(image_ids):
            self.add_image("plant", image_id=id,
                           path=image_paths[idx],
                           width=224, height=224,
                           annotations=coco.loadAnns(coco.getAnnIds(imgIds=[id],
                                                                    catIds=[1,2],
                                                                    iscrowd=None)))


    def load_keypoints(self, image_id):
        """
        Load instance masks for the given image
        Outputs:
        - masks: A bool array of shape[height, width, instance count] with 
                 one mask per instance
        - class_ids: a 1D array of class IDs of the instance mask
        """

        keypoints = []
        instance_masks = []
        class_ids = []
        annotations = self.image_info[image_id]["annotations"]
        for ann in annotations:
            class_id = self.map_source_class_id("coco.{}".format(ann['category_id']))
            if class_id:
                m = self.annToMask(ann, 224, 224)
                if m.max() < 1: continue
                instance_masks.append(m)
                class_ids.append(class_id)
                # load keypoints
                kp = ann["keypoints"]
                kp = np.reshape(kp, (-1,2))
                keypoints.append(kp)

        # pack instance masks into an array
        if class_ids:
            mask = np.stack(instance_masks, axis=2)
            class_ids = np.array(class_ids, dtype=np.int32)
            keypoints = np.array(keypoints, dtype=np.int32)
        return keypoints, mask, class_ids


    # The following two functions are from pycocotools with a few changes
    def annToRLE(self, ann, height, width):
        """
        Convert annotation which can be polygons, uncompressed RLE to RLE
        output: binary mask (2D numpy array)
        """
        segm = ann['segmentation']
        if isinstance(segm, list):
            # polygon - a single object might consiste of multiple parts
            # merge all parts into one mask rle code
            rles = maskUtils.frPyObjects(segm, height, width)
            rle = maskUtils.merge(rles)
        elif isinstance(segm['counts'], list):
            rle = maskUtils.frPyObjects(segm, height, width)
        else:
            rle = ann['segmentation']
        return rle

    def annToMask(self, ann, height, width):
        """
        Convert annotation which can be polygons, uncompressed RLE, or RLE to 
        binary mask
        Output: binary mask (2D numpy array)
        """
        rle = self.annToRLE(ann, height, width)
        m = maskUtils.decode(rle)
        return m
