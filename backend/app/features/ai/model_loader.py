from AI.FoodDetection import FoodDetectionModel


YOLO_PATH = "app/AI/models/classification_models/YOLO/"

clsModelsDict = {
    "meat": f"{YOLO_PATH}/meat.pt",
    "vegetable": f"{YOLO_PATH}/vegetable.pt",
    "fruit": f"{YOLO_PATH}/fruit.pt",
    "cheese-dairy": f"{YOLO_PATH}/cheese-dairy.pt",
    "bread-pasta-grains": f"{YOLO_PATH}/bread-pasta-grains.pt",
    "nuts-seeds": f"{YOLO_PATH}/nuts-seeds.pt",
    "misc": f"{YOLO_PATH}/misc.pt",
}


model = FoodDetectionModel(
    detection_model_path="app/AI/models/detection_models/detection.pt",
    classification_config=clsModelsDict,
    detection_id_to_name="dicts/detect_classes_v4.json",
    det_to_cls_group="dicts/det_to_cls_groups.json",
)
