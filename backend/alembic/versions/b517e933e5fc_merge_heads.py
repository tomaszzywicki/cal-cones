"""merge_heads

Revision ID: b517e933e5fc
Revises: 53f26da5d948, 84e85b43ba91
Create Date: 2026-01-09 15:58:20.485150

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b517e933e5fc'
down_revision: Union[str, Sequence[str], None] = ('53f26da5d948', '84e85b43ba91')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
