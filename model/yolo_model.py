import os
import torch
from ultralytics import YOLO
import cv2
import matplotlib.pyplot as plt

def train_model(model_path, data_yaml, epochs, img_size, batch_size, device, train_name):
    print("[INFO] Starting training...")
    model = YOLO(model_path).to(device)
    model.train(
        data=data_yaml,
        epochs=epochs,
        imgsz=img_size,
        batch=batch_size,
        device=device,
        name=train_name
    )
    print("[INFO] Training finished.")

def predict_images(model_path, test_dir, test_results_dir,
                    conf_threshold, iou_threshold, img_size,
                    device, save=False, save_txt=False):
    
    if save or save_txt:
        os.makedirs(test_results_dir, exist_ok=True)
    print("[INFO] Starting inference...")
    
    # Load trained model
    if not os.path.exists(model_path):
        print(f"[ERROR] Model not found at {model_path}. Please train first or set MODEL_PATH manually.")
        return
    
    model = YOLO(model_path).to(device)
    
    results = model.predict(
        source=test_dir,
        conf=conf_threshold,
        device=device,
        imgsz=img_size,
        save=save,
        save_txt=save_txt,
        project=test_results_dir,
        name="inference",
        show_labels=True,
        show_conf=True,
        iou=iou_threshold
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

    if save or save_txt:
        print(f"[INFO] Inference done. Check {test_results_dir}/inference")
    else:
        print("[INFO] Inference done.")