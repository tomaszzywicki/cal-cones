import tempfile
import os
from fastapi import UploadFile
from pathlib import Path
from io import BytesIO
from PIL import Image
from sqlalchemy.orm import Session
from app.features.product.service import get_product_from_model
from app.core.logger_setup import get_logger

logger = get_logger(__name__)


async def prepare_file_for_model(image: UploadFile) -> str:
    content = await image.read()

    try:
        with Image.open(BytesIO(content)) as img:
            img.verify()
    except Exception as e:
        raise ValueError("Uploaded file is not a valid image.") from e

    suffix = image.filename and Path(image.filename).suffix or "jpg"
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)

    try:
        tmp.write(content)
        tmp.flush()
        tmp_path = tmp.name
    finally:
        tmp.close()

    return tmp_path


def cleanup_temp_file(file_path: str):
    try:
        if file_path and os.path.exists(file_path):
            os.remove(file_path)
    except Exception as e:
        raise RuntimeError(f"Failed to delete temporary file: {file_path}") from e


def process_model_output(output: list[dict]) -> list[dict] | None:
    try:
        processed_results = []
        for item in output:
            products_list = []
            i = 0
            for product in item["top5_cls_results"]:
                if i >= 3:
                    break
                products_list.append(
                    {"product": product["class_name"], "probability": product["probability"]}
                )
                i += 1

            processed_results.append(products_list)

        return processed_results
    except Exception as e:
        logger.error(f"Error during process_model_output: {e}")


def _get_product_info(db: Session, name: str):
    return get_product_from_model(db, name)
