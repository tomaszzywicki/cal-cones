"""
YOLOv11 Training & Inference Script
-------------------------------------------
Usage:
1. Training:
    python yolo_model.py train
2. Inference:
    python yolo_model.py predict
"""

import os
import sys
import torch
from ultralytics import YOLO
import cv2
import matplotlib.pyplot as plt

# ===========================
# SETTINGS
# ===========================
# Paths (edit these)
YOLO_MODEL_PATH = "data/dataset_v3/yolo11s.pt"     # Pretrained model for training
DATA_YAML = "dataset/yolo_det.yaml"           # Dataset config
TRAIN_NAME = "yolo_detS_v3"                        # Folder name for training outputs
EPOCHS = 50
IMG_SIZE = 640
BATCH_SIZE = 16

TEST_DIR = "hot_pics"                     # Folder with images for inference
TEST_RESULTS_DIR = "test_pics_results"        # Folder to save inference results
CONF_THRESHOLD = 0.25
IOU_THRESHOLD = 0.75

# ===========================
# DEVICE SELECTION
# ===========================
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"[INFO] Using device: {device}")

# ===========================
# FUNCTIONS
# ===========================
def train_model():
    print("[INFO] Starting training...")
    model = YOLO(YOLO_MODEL_PATH).to(device)
    model.train(
        data=DATA_YAML,
        epochs=EPOCHS,
        imgsz=IMG_SIZE,
        batch=BATCH_SIZE,
        device=device,
        name=TRAIN_NAME
    )
    print("[INFO] Training finished.")


def predict_images():
    os.makedirs(TEST_RESULTS_DIR, exist_ok=True)
    print("[INFO] Starting inference...")
    
    # Load trained model
    model_path = os.path.join("runs", "train", TRAIN_NAME, "weights", "best.pt")
    if not os.path.exists(model_path):
        print(f"[ERROR] Model not found at {model_path}. Please train first or set MODEL_PATH manually.")
        return
    
    model = YOLO(model_path).to(device)
    
    results = model.predict(
        source=TEST_DIR,
        conf=CONF_THRESHOLD,
        device=device,
        imgsz=IMG_SIZE,
        save=False,              # Save images? Change to True if needed
        save_txt=False,          # Save YOLO labels? Change to True if needed
        project=TEST_RESULTS_DIR,
        name="inference",
        show_labels=True,
        show_conf=True,
        iou=IOU_THRESHOLD
    )
    
    # Show results
    for result in results:
        img_bgr = result.plot()
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        plt.figure(figsize=(10,10))
        plt.imshow(img_rgb)
        plt.axis('off')
        plt.title("Detected objects")
        plt.show()
    
    print(f"[INFO] Inference done. Check {TEST_RESULTS_DIR}/inference")


# ===========================
# MAIN
# ===========================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: yolo_model.py [train|predict]")
        sys.exit(1)

    mode = sys.argv[1].lower()
    if mode == "train":
        train_model()
    elif mode == "predict":
        predict_images()
    else:
        print("Unknown mode. Use 'train' or 'predict'.")
