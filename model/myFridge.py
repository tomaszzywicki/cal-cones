import cv2
import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple
import json
from ultralytics import YOLO

class ContourBoxDetector:
    """
    Optimized contour detector for separated objects with clean backgrounds.
    Uses Otsu's thresholding for automatic background separation.
    """

    def __init__(self, 
                 min_area_ratio=0.002,
                 containment_threshold=0.7,
                 max_aspect_ratio=8.0,
                 visualize=True,
                 edge_margin=5,
                 morph_kernel_size=5,
                 morph_close_iterations=2,
                 morph_open_iterations=1,
                 min_contour_area=500,
                 use_canny=False,
                 canny_low=30,
                 canny_high=100):
        self.min_area_ratio = min_area_ratio
        self.containment_threshold = containment_threshold
        self.max_aspect_ratio = max_aspect_ratio
        self.visualize = visualize
        self.edge_margin = edge_margin
        self.morph_kernel_size = morph_kernel_size
        self.morph_close_iterations = morph_close_iterations
        self.morph_open_iterations = morph_open_iterations
        self.min_contour_area = min_contour_area
        self.use_canny = use_canny
        self.canny_low = canny_low
        self.canny_high = canny_high

    @staticmethod
    def box_area(box: Tuple[int,int,int,int]) -> int:
        x1, y1, x2, y2 = box
        return max(0, x2 - x1) * max(0, y2 - y1)

    @staticmethod
    def intersection(boxA, boxB):
        x1 = max(boxA[0], boxB[0])
        y1 = max(boxA[1], boxB[1])
        x2 = min(boxA[2], boxB[2])
        y2 = min(boxA[3], boxB[3])
        if x1 < x2 and y1 < y2:
            return (x1, y1, x2, y2)
        return None

    @classmethod
    def containment_ratio(cls, small_box, large_box) -> float:
        inter = cls.intersection(small_box, large_box)
        if inter is None:
            return 0
        return cls.box_area(inter) / cls.box_area(small_box)

    @staticmethod
    def min_area_for_image(image_shape, ratio: float) -> float:
        h, w = image_shape[:2]
        return h * w * ratio

    def is_edge_box(self, box: Tuple[int,int,int,int], image_shape) -> bool:
        """Check if box touches image edges (likely background)."""
        h, w = image_shape[:2]
        x1, y1, x2, y2 = box
        margin = self.edge_margin
        
        return (x1 <= margin or y1 <= margin or 
                x2 >= w - margin or y2 >= h - margin)

    def filter_small_boxes(self, boxes: List[Tuple[int,int,int,int]], image_shape) -> List[Tuple[int,int,int,int]]:
        min_area = self.min_area_for_image(image_shape, self.min_area_ratio)
        max_area = image_shape[0] * image_shape[1] * 0.95  # Ignore boxes >95% of image
        
        filtered = []
        for b in boxes:
            area = self.box_area(b)
            if min_area <= area <= max_area and not self.is_edge_box(b, image_shape):
                filtered.append(b)
        return filtered

    def remove_subsumed_boxes(self, boxes: List[Tuple[int,int,int,int]]) -> List[Tuple[int,int,int,int]]:
        if not boxes:
            return []
        
        # Sort by area (largest first)
        boxes_sorted = sorted(boxes, key=lambda b: self.box_area(b), reverse=True)
        keep = []
        
        for i, box in enumerate(boxes_sorted):
            is_contained = False
            for kept_box in keep:
                if self.containment_ratio(box, kept_box) >= self.containment_threshold:
                    is_contained = True
                    break
            if not is_contained:
                keep.append(box)
        
        return keep

    def postprocess_boxes(self, boxes: List[Tuple[int,int,int,int]], image_shape) -> List[Tuple[int,int,int,int]]:
        boxes = self.filter_small_boxes(boxes, image_shape)
        boxes = self.remove_subsumed_boxes(boxes)
        return boxes

    def detect(self, image_path: str) -> List[Tuple[int,int,int,int]]:
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Cannot load image: {image_path}")

        original_shape = image.shape
        
        # Resize for faster processing if image is large
        h, w = image.shape[:2]
        max_dim = 1280
        if max(h, w) > max_dim:
            scale = max_dim / max(h, w)
            image = cv2.resize(image, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA)
            scale_back = 1 / scale
        else:
            scale_back = 1.0

        # Convert to grayscale
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Light Gaussian blur to reduce noise
        gray = cv2.GaussianBlur(gray, (5, 5), 0)
        
        # Choose between Otsu's thresholding or Canny edge detection
        if self.use_canny:
            # Canny edge detection (better for finding edges)
            binary = cv2.Canny(gray, self.canny_low, self.canny_high)
            binary = cv2.dilate(binary, np.ones((3, 3), np.uint8), iterations=2)
        else:
            # Otsu's thresholding (better for solid objects)
            _, binary = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
        
        # Morphological operations to clean up
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, 
                                          (self.morph_kernel_size, self.morph_kernel_size))
        binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel, 
                                 iterations=self.morph_close_iterations)
        binary = cv2.morphologyEx(binary, cv2.MORPH_OPEN, kernel, 
                                 iterations=self.morph_open_iterations)
        
        # Remove small noise
        binary = cv2.erode(binary, np.ones((3, 3), np.uint8), iterations=1)
        binary = cv2.dilate(binary, np.ones((3, 3), np.uint8), iterations=1)

        # Find contours
        contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        boxes = []
        for cnt in contours:
            # Skip tiny contours
            area = cv2.contourArea(cnt)
            if area < self.min_contour_area:
                continue
            
            # Get bounding box
            x, y, w, h = cv2.boundingRect(cnt)
            
            # Filter by aspect ratio
            if min(w, h) == 0 or max(w, h) / min(w, h) > self.max_aspect_ratio:
                continue
            
            # Scale back to original size
            if scale_back != 1.0:
                x = int(x * scale_back)
                y = int(y * scale_back)
                w = int(w * scale_back)
                h = int(h * scale_back)
            
            boxes.append((x, y, x + w, y + h))

        # Postprocess with original image dimensions
        boxes = self.postprocess_boxes(boxes, original_shape)

        if self.visualize:
            # Load original image for visualization
            vis = cv2.imread(image_path)
            for i, (x1, y1, x2, y2) in enumerate(boxes):
                cv2.rectangle(vis, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(vis, f"#{i+1}", (x1, max(0, y1-10)), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
            plt.figure(figsize=(12, 8))
            plt.imshow(cv2.cvtColor(vis, cv2.COLOR_BGR2RGB))
            plt.axis("off")
            plt.title(f"Detected boxes ({len(boxes)})")
            plt.show()

        return boxes

class ClassificationModelManager:
    """
    Manages multiple classification models for different food categories."""
    def __init__(self, classification_paths: dict):
        self.classification_models = {}
        for category, path in classification_paths.items():
            try:
                self.classification_models[category] = YOLO(path)
            except Exception as e:
                print(f"Error loading model for category '{category}': {e}")
                self.classification_models[category] = None
        
    def get_model(self, category: str):
        """Returns a specific classification model based on the category."""
        return self.classification_models.get(category)
    
    def get_all_models(self):
        """Returns all classification models. (dictionary)"""
        return self.classification_models
    
class MyFridgeModel:
    def __init__(self, detector: ContourBoxDetector,
                 detection_model_path: str, classification_config: dict,
                 detection_id_to_name: str, det_to_cls_group: str):
        
        self.detector = detector
        
        self.detection_model = YOLO(detection_model_path)

        self.cls_manager = ClassificationModelManager(classification_config)

        self.classification_models = self.cls_manager.get_all_models()

        with open(detection_id_to_name, 'r') as f:
            self.detection_id_to_name = json.load(f)

        with open(det_to_cls_group, 'r') as f:
            self.det_to_cls_group = json.load(f)

    def _expand_bbox(self, bbox, image_shape, scale=1.1):
        """Expand bounding box slightly while staying within image bounds."""
        x1, y1, x2, y2 = bbox
        w, h = x2 - x1, y2 - y1
        cx, cy = x1 + w / 2, y1 + h / 2
        new_w, new_h = w * scale, h * scale

        x1n = max(0, int(cx - new_w / 2))
        y1n = max(0, int(cy - new_h / 2))
        x2n = min(image_shape[1] - 1, int(cx + new_w / 2))
        y2n = min(image_shape[0] - 1, int(cy + new_h / 2))

        return [x1n, y1n, x2n, y2n]
    
    def run(self, image_path: str, conf_threshold=0.3, det_imgsz=640,
            vis=False, vis_crops=False, verbose=True):
        """Run detection and classification on the input image."""
        image = cv2.imread(image_path)
        ### DETECTOR ### 
        roi_boxes = self.detector.detect(image_path)
        print(len(roi_boxes), "ROIs detected.")
        for box in roi_boxes:
            # print(f"Detected ROI Box: {box}")
            expanded_box = self._expand_bbox(box, cv2.imread(image_path).shape, scale=1.3)
            ex1, ey1, ex2, ey2 = expanded_box
            image = cv2.imread(image_path)
            crop_image = image[ey1:ey2, ex1:ex2].copy()

            image = crop_image
            if image is None:
                raise ValueError(f"Image at path '{image_path}' could not be loaded.")
            
            vis_img = image.copy() if vis else None

            ### DETECTION ###
            det_results = self.detection_model.predict(source=image, imgsz=det_imgsz, conf=conf_threshold, agnostic_nms=True, save=False, verbose=False)

            all_boxes = []
            final_outputs = []

            if vis:
                img_bgr = det_results[0].plot()
                img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
                plt.figure(figsize=(8, 8))
                plt.imshow(img_rgb)
                plt.axis('off')
                plt.show()

            ### CLASSIFICATION ###

            for det in det_results:
                boxes = det.boxes.xyxy.cpu().numpy()
                class_ids = det.boxes.cls.cpu().numpy()
                scores = det.boxes.conf.cpu().numpy()

                for i, box in enumerate(boxes):
                    x1, y1, x2, y2 = map(int, box)
                    det_class_id = int(class_ids[i])
                    det_conf_score = float(scores[i])
                    det_class_name = self.detection_id_to_name[str(det_class_id)]

                    all_boxes.append((x1, y1, x2, y2, det_class_name, det_conf_score))

                    # --- Find which segmentation model to use ---
                    seg_group = None
                    for group_name, class_list in self.det_to_cls_group.items():
                        if det_class_name in class_list:
                            seg_group = group_name
                            if verbose:
                                print(f"Detection '{det_class_name}' mapped to classification group '{seg_group}'")
                            break
                    if seg_group is None:
                        if verbose:
                            print(f"No classification group found for detection '{det_class_name}'. Skipping classification.")
                        
                        final_outputs.append({
                            "bbox": [x1, y1, x2, y2],
                            "det_class_name": det_class_name,
                            "det_conf_score": det_conf_score,
                            "cls_group": None,
                            "top5_cls_results": []
                        })
                        continue

                    expanded_box = self._expand_bbox((x1, y1, x2, y2), image.shape)
                    ex1, ey1, ex2, ey2 = expanded_box
                    crop_img = image[ey1:ey2, ex1:ex2].copy()

                    cls_model = self.classification_models.get(seg_group)
                    if cls_model is None:
                        if verbose:
                            print(f"No classification model found for group '{seg_group}'. Skipping classification.")
                        
                        final_outputs.append({
                            "bbox": [x1, y1, x2, y2],
                            "det_class_name": det_class_name,
                            "det_conf_score": det_conf_score,
                            "cls_group": seg_group,
                            "top5_cls_results": []
                        })
                        continue

                    cls_results = cls_model.predict(source=crop_img, verbose=False)

                    ## Process classification results
                    top5 = []
                    if cls_results and cls_results[0].probs is not None:
                        cls_res = cls_results[0]

                        names = cls_res.names
                        top5cls_ids = cls_res.probs.top5
                        top5probs = cls_res.probs.top5conf

                        for idx, prob in zip(top5cls_ids, top5probs):
                            top5.append({
                                "class_name": names[idx],
                                "probability": float(prob)
                            })
                    final_outputs.append({
                        "bbox": [x1, y1, x2, y2],
                        "det_class_name": det_class_name,
                        "det_conf_score": det_conf_score,
                        "cls_group": seg_group,
                        "top5_cls_results": top5
                    })

                    if vis_crops:
                        for cls_res in cls_results:
                            im_array = cls_res.plot()
                            img_rgb = cv2.cvtColor(im_array, cv2.COLOR_BGR2RGB)
                            plt.figure(figsize=(6, 6))
                            plt.imshow(img_rgb)
                            plt.axis('off')
                            plt.show()

        return final_outputs