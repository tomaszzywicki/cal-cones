import json
import cv2
import numpy as np
from ultralytics import YOLO # type: ignore


class DetSegModel:
    def __init__(self, detection_model_path, meat_seg_path, fruit_seg_path, vege_seg_path,
                dairy_seg_path, nuts_seg_path, grains_seg_path, sweets_seg_path, misc_seg_path, seg_classes_path,
                seg_dict_path=None, idx_to_name_path=None):
        # Load detection model (used on full image)
        self.det_model = YOLO(detection_model_path)

        # Load segmentation models for each food group
        self.seg_models = {
            "meat": YOLO(meat_seg_path),
            "fruit": YOLO(fruit_seg_path),
            "vegetables": YOLO(vege_seg_path),
            "cheese-dairy": YOLO(dairy_seg_path),
            "nuts-seeds": YOLO(nuts_seg_path),
            "bread-pasta-grains": YOLO(grains_seg_path),
            "sweets-desserts": YOLO(sweets_seg_path),
            "miscellaneous": YOLO(misc_seg_path),
        }

        # Load class mappings (for information/logging)
        with open(seg_classes_path, "r") as f:
            self.seg_classes = json.load(f)

        # Define mapping from detection label keywords to segmentation model type
        with open(seg_dict_path, "r") as f:
            self.det_to_seg_group = json.load(f)

        if idx_to_name_path:
            with open(idx_to_name_path, "r") as f:
                self.idx_to_name = json.load(f)

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

    def run(self, image_path, conf_thresh=0.25, mask_conf_thresh=0.5, det_imgsz=800, vis=True, vis_crops=False):
        image = cv2.imread(image_path)
        if image is None:
            raise FileNotFoundError(f"Image not found: {image_path}")

        vis_img = image.copy() if vis else None
        ### DETECTION ### 
        det_results = self.det_model.predict(source=image, imgsz=det_imgsz, conf=conf_thresh, agnostic_nms=True, save=False, verbose=False)

        all_boxes = []
        final_outputs = []

        for det in det_results:
            boxes = det.boxes.xyxy.cpu().numpy()
            class_ids = det.boxes.cls.cpu().numpy()
            scores = det.boxes.conf.cpu().numpy()

            for i, box in enumerate(boxes):
                x1, y1, x2, y2 = map(int, box)
                det_class_id = int(class_ids[i])
                det_conf_score = float(scores[i])
                det_class_name = self.idx_to_name[str(det_class_id)] if hasattr(self, 'idx_to_name') else str(det_class_id)

                all_boxes.append((x1, y1, x2, y2, det_class_name, det_conf_score))
                
                # --- Find which segmentation model to use ---
                seg_group = None
                for group_name, class_list in self.det_to_seg_group.items():
                    if det_class_name in class_list:
                        seg_group = group_name
                        # print(f"Detected class '{det_class_name}' mapped to segmentation group '{seg_group}'")
                        break

                if seg_group is None:
                    print(f"No segmentation model found for class '{det_class_name}'")

                # --- Expand and crop bounding box from ORIGINAL image ---
                expanded_bbox = self._expand_bbox([x1, y1, x2, y2], image.shape)
                ex1, ey1, ex2, ey2 = expanded_bbox
                crop = image[ey1:ey2, ex1:ex2].copy()

                # Optional visualization of crops
                if vis_crops:
                    if crop.size > 0:
                        import matplotlib.pyplot as plt
                        plt.figure(figsize=(4, 4))
                        plt.imshow(cv2.cvtColor(crop, cv2.COLOR_BGR2RGB))
                        plt.title(f"Crop: {det_class_name} ({det_conf_score:.2f})")
                        plt.axis('off')
                        plt.show()
                    else:
                        print(f"Skipped empty crop for {det_class_name} at {expanded_bbox}")

                if crop.size == 0:
                    continue  # skip invalid crop

                # --- Run segmentation only if seg_group found ---
                masks_global = []
                if seg_group in self.seg_models:
                    seg_model = self.seg_models[seg_group]
                    seg_result = seg_model.predict(source=crop, conf=mask_conf_thresh, verbose=False)[0]

                    if seg_result.masks is not None:
                        for j, mask in enumerate(seg_result.masks.data):
                            mask = mask.cpu().numpy()
                            mask_resized = cv2.resize(mask, (ex2 - ex1, ey2 - ey1))
                            full_mask = np.zeros(image.shape[:2], dtype=np.uint8)
                            full_mask[ey1:ey2, ex1:ex2] = (mask_resized > mask_conf_thresh).astype(np.uint8) * 255
                            masks_global.append(full_mask)

                            # --- Get segmentation class + confidence ---
                            seg_cls_id = int(seg_result.boxes.cls[j])
                            seg_cls_conf = float(seg_result.boxes.conf[j])
                            seg_cls_name = self.seg_classes[seg_group].get(str(seg_cls_id), "unknown")
                            print(f"Detected class: '{det_class_name}', Segmented Class: '{seg_cls_name}' with confidence {seg_cls_conf:.2f}")

                            # --- Optional visualization overlay ---
                            if vis:
                                color = (0, 255, 0)
                                vis_img[full_mask > 0] = (
                                    0.5 * vis_img[full_mask > 0] + 0.5 * np.array(color)
                                ).astype(np.uint8)

                                # Label background and white text
                                label_text = f"{seg_cls_name} ({seg_cls_conf:.2f})"
                                (tw, th), base = cv2.getTextSize(label_text, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2)
                                text_x, text_y = ex1 + 5, ey1 + 25 + 22 * j
                                cv2.rectangle(vis_img, (text_x - 2, text_y - th - 4),
                                            (text_x + tw + 2, text_y + base), (0, 0, 0), -1)
                                cv2.putText(vis_img, label_text, (text_x, text_y),
                                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2, cv2.LINE_AA)
                                
                # --- Always draw bounding box and label (even if no seg model) ---
                label_text = f"{det_class_name} ({det_conf_score:.2f})"
                (text_w, text_h), baseline = cv2.getTextSize(label_text, cv2.FONT_HERSHEY_SIMPLEX, 0.7, 2)
                cv2.rectangle(vis_img, (x1, y1 - text_h - 8), (x1 + text_w + 4, y1), (0, 0, 0), -1)  # solid black background
                cv2.putText(vis_img, label_text, (x1 + 2, y1 - 5),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2, cv2.LINE_AA)

                box_color = (255, 0, 0) if seg_group else (128, 128, 128)
                cv2.rectangle(vis_img, (x1, y1), (x2, y2), box_color, 2)


                ### more detailed output
                # final_outputs.append({
                #     "det_class": det_class_name,
                #     "bbox": expanded_bbox,
                #     "seg_group": seg_group,
                #     "seg_masks": masks_global,
                #     "score": det_conf_score
                # })
                final_outputs.append((seg_cls_name, seg_cls_conf))



            # print(all_boxes)

        if vis:
            import matplotlib.pyplot as plt
            plt.figure(figsize=(10, 10))
            plt.imshow(cv2.cvtColor(vis_img, cv2.COLOR_BGR2RGB))
            plt.axis("off")
            plt.show()

        return final_outputs