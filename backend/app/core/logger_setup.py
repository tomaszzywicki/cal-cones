import logging
from logging import Logger, getLogger, Formatter
from rich.logging import RichHandler
from rich.console import Console
from typing import Optional, Literal

LOG_FMT = "%(message)s - %(pathname)s:%(lineno)d"
DATE_FMT = "%Y-%m-%d %H:%M:%S"


def get_logger(name: Optional[str] = None, level=logging.INFO) -> Logger:
    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.propagate = False

    if not logger.handlers:
        console = Console(force_terminal=True, color_system="auto")
        handler = RichHandler(
            level=level,
            rich_tracebacks=True,
            console=console,
            show_time=True,
            show_path=True,
        )
        formatter = Formatter(datefmt=DATE_FMT, fmt=LOG_FMT)
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        pass

    return logger
