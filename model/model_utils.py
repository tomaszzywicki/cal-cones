import matplotlib.pyplot as plt
import matplotlib.patches as patches
import random

def visualize_detections(img_path, label_path, id_to_name_dict):
    # Load image
    img = plt.imread(img_path)
    img_height, img_width = img.shape[:2]

    # Create figure (large, no axes)
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.imshow(img)
    ax.axis("off")

    # Load labels
    with open(label_path, 'r', encoding='utf-8') as f:
        lines = [l.strip() for l in f.readlines() if l.strip()]

    # Generate consistent random colors for each class
    color_map = {}
    for cid in id_to_name_dict.keys():
        random.seed(cid)  # ensures consistent colors between runs
        color_map[cid] = (random.random(), random.random(), random.random())

    for line in lines:
        parts = line.split()
        if len(parts) != 5:
            continue

        class_id = parts[0]
        x_center = float(parts[1]) * img_width
        y_center = float(parts[2]) * img_height
        width = float(parts[3]) * img_width
        height = float(parts[4]) * img_height

        # Convert YOLO center format to top-left corner
        x_min = x_center - width / 2
        y_min = y_center - height / 2

        # Draw bounding box
        color = color_map.get(class_id, (1, 0, 0))
        rect = patches.Rectangle(
            (x_min, y_min),
            width,
            height,
            linewidth=2,
            edgecolor=color,
            facecolor=(color[0], color[1], color[2], 0.2)  # semi-transparent fill
        )
        ax.add_patch(rect)

        # Add class label
        class_name = id_to_name_dict.get(class_id, f"id:{class_id}")
        ax.text(
            x_min,
            y_min - 5,
            class_name,
            color="white",
            fontsize=10,
            weight="bold",
            bbox=dict(facecolor=color, alpha=0.7, edgecolor='none', pad=2)
        )

    ax.set_title(f"{img_path}", fontsize=16)
    plt.tight_layout(pad=0)
    plt.show()
