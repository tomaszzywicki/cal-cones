import tempfile
import os
from fastapi import UploadFile
from pathlib import Path
from io import BytesIO
from PIL import Image


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
