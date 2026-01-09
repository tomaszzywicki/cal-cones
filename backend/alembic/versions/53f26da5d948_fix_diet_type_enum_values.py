"""fix_diet_type_enum_values

Revision ID: 53f26da5d948
Revises: ca210ea8e74b
Create Date: 2026-01-09 15:48:57.820316

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "53f26da5d948"
down_revision: Union[str, Sequence[str], None] = "ca210ea8e74b"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Zmień kolumnę na VARCHAR tymczasowo
    op.execute("ALTER TABLE users ALTER COLUMN diet_type TYPE VARCHAR USING diet_type::text")

    # 2. Usuń stary enum
    op.execute("DROP TYPE IF EXISTS diettypeenum")

    # 3. Stwórz nowy enum z poprawnymi wartościami
    op.execute("CREATE TYPE diettypeenum AS ENUM ('BALANCED', 'LOW_CARB', 'LOW_FAT')")

    # 4. Zmień kolumnę z powrotem na enum
    # Ustaw domyślną wartość dla starych wartości które już nie istnieją
    op.execute(
        """
        UPDATE users 
        SET diet_type = 'BALANCED' 
        WHERE diet_type NOT IN ('BALANCED', 'LOW_CARB', 'LOW_FAT')
           OR diet_type IS NULL
    """
    )

    op.execute("ALTER TABLE users ALTER COLUMN diet_type TYPE diettypeenum USING diet_type::diettypeenum")


def downgrade() -> None:
    # Przywróć stary enum (jeśli chcesz cofnąć)
    op.execute("ALTER TABLE users ALTER COLUMN diet_type TYPE VARCHAR USING diet_type::text")
    op.execute("DROP TYPE IF EXISTS diettypeenum")
    op.execute("CREATE TYPE diettypeenum AS ENUM ('CUSTOM', 'KETO', 'ENUDRANCE', 'MUSCLE_GAIN', 'BALANCED')")
    op.execute("ALTER TABLE users ALTER COLUMN diet_type TYPE diettypeenum USING diet_type::diettypeenum")
