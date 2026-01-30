import json
import cv2
import numpy as np
import matplotlib.pyplot as plt
from ultralytics import YOLO

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
        return self.classification_models.get(category)
    
    def get_all_models(self):
        return self.classification_models
    
class FoodDetectionModel:
    def __init__(self, detection_model_path: str, classification_config: dict,
                 detection_id_to_name: str, det_to_cls_group: str):
        
        self.detection_model = YOLO(detection_model_path)

        self.cls_manager = ClassificationModelManager(classification_config)

        self.classification_models = self.cls_manager.get_all_models()

        with open(detection_id_to_name, 'r') as f:
            self.detection_id_to_name = json.load(f)

        self.name_to_id = {v: int(k) for k, v in self.detection_id_to_name.items()}

        with open(det_to_cls_group, 'r') as f:
            self.det_to_cls_group = json.load(f)

    def _expand_bbox(self, bbox, image_shape, scale=1.1):
        x1, y1, x2, y2 = bbox
        w, h = x2 - x1, y2 - y1
        cx, cy = x1 + w / 2, y1 + h / 2
        new_w, new_h = w * scale, h * scale

        x1n = max(0, int(cx - new_w / 2))
        y1n = max(0, int(cy - new_h / 2))
        x2n = min(image_shape[1] - 1, int(cx + new_w / 2))
        y2n = min(image_shape[0] - 1, int(cy + new_h / 2))

        return [x1n, y1n, x2n, y2n]
    
    def run(self, image_path: str, conf_threshold=0.3, det_imgsz=1024, verbose=True):
        """Run detection and classification on the input image."""
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Image at path '{image_path}' could not be loaded.")
        
        ### DETECTION ###
        det_results = self.detection_model.predict(source=image, imgsz=det_imgsz, conf=conf_threshold, agnostic_nms=True, save=False, verbose=False)

        all_boxes = []
        final_outputs = []
        classes_detected = set()

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
                        "pred_class_name": det_class_name,
                        "pred_class_id": det_class_id,
                        "bbox": [x1, y1, x2, y2],
                        "det_class_name": det_class_name,
                        "det_conf_score": det_conf_score,
                        "cls_group": None,
                        "top5_cls_results": []
                    })
                    classes_detected.add(det_class_name)
                    continue

                expanded_box = self._expand_bbox((x1, y1, x2, y2), image.shape)
                ex1, ey1, ex2, ey2 = expanded_box
                crop_img = image[ey1:ey2, ex1:ex2].copy()

                cls_model = self.classification_models.get(seg_group)
                if cls_model is None:
                    if verbose:
                        print(f"No classification model found for group '{seg_group}'. Skipping classification.")
                    
                    final_outputs.append({
                        "pred_class_name": det_class_name,
                        "pred_class_id": det_class_id,
                        "bbox": [x1, y1, x2, y2],
                        "det_class_name": det_class_name,
                        "det_conf_score": det_conf_score,
                        "cls_group": seg_group,
                        "top5_cls_results": []
                    })
                    classes_detected.add(det_class_name)
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
                new_prob = top5[0]["probability"] if top5 else det_conf_score
                class_name = top5[0]["class_name"] if top5 else det_class_name

                # Check for existing class in final outputs
                existing_index = next(
                    (i for i, item in enumerate(final_outputs) if item["pred_class_name"] == class_name),
                    None
                )

                if existing_index is None:
                    final_outputs.append({
                        "pred_class_name": class_name,
                        "pred_class_id": self.name_to_id.get(class_name, det_class_id),
                        "bbox": [x1, y1, x2, y2],
                        "det_class_name": det_class_name,
                        "det_conf_score": det_conf_score,
                        "cls_group": seg_group,
                        "top5_cls_results": top5
                    })
                else:
                    # exists — compare probability
                    existing_prob = final_outputs[existing_index]["top5_cls_results"][0]["probability"]

                    if new_prob > existing_prob:
                        # More confident prediction
                        final_outputs.pop(existing_index)
                        final_outputs.append({
                            "pred_class_name": class_name,
                            "pred_class_id": self.name_to_id.get(class_name, det_class_id),
                            "bbox": [x1, y1, x2, y2],
                            "det_class_name": det_class_name,
                            "det_conf_score": det_conf_score,
                            "cls_group": seg_group,
                            "top5_cls_results": top5
                        })
                        
        return final_outputs