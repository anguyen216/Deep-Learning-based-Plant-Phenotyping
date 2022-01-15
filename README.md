# ECE_542_Final_project
Final Project for ECE 542: Neural Network

This project mainly focuses on detection of pheno- typic traits such as leaf and collar count in a plant. The images of plants were manually annotated using MATLAB GUI. The data in was generated in COCO format as a JSON file. The proposed implementation is based on Mask R-CNN with ResNet101 as the backbone network.The model output is obtained as bounding box for object detection, mask, class indicating leaf or collar, confidence score and the number of leaves and collars detected along with the corresponding keypoints. The mAP values are obtained for different IoU threshold values greater than 0.5 and the loss for validation and training with respect to the number of epochs is reported. The keypoint locations and the number of leaves and collar detection is compared with the ground truth for model evaluation along with mAP scores.

More detailed description and results of the project are included in `project_report.pdf`
