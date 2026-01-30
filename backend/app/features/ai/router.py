from typing import List
from fastapi import APIRouter, status, HTTPException, UploadFile, Depends
from sqlalchemy.orm import Session

from app.features.ai.schemas import AIResponse
from app.core.dependencies import get_db

from .model_loader import model
from .service import prepare_file_for_model, cleanup_temp_file, process_model_output
from app.config import CONF_THRESHOLD, DET_IMGSZ

from app.core.logger_setup import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/detect", status_code=status.HTTP_200_OK)
async def detect_products(image: UploadFile, db=Depends(get_db)):
    tmp_path = None
    try:
        tmp_path = await prepare_file_for_model(image)

        results = model.run(tmp_path, conf_threshold=CONF_THRESHOLD, det_imgsz=DET_IMGSZ, verbose=False)
        results = process_model_output(results, db)
        return results

    except ValueError as ve:
        logger.error(f"ValueError during detection: {ve}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(ve))
    except Exception as e:
        logger.error(f"Unexpected error during detection: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")
    finally:
        if tmp_path:
            cleanup_temp_file(tmp_path)
