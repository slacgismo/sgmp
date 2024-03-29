"""Initial migration.

Revision ID: 1e0b7b8ffdb3
Revises: 
Create Date: 2021-10-05 17:29:52.416425

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '1e0b7b8ffdb3'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('analytics',
    sa.Column('analytics_id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=256), nullable=False),
    sa.Column('description', sa.Text(), nullable=False),
    sa.Column('formula', sa.Text(), nullable=False),
    sa.PrimaryKeyConstraint('analytics_id')
    )
    op.create_table('device',
    sa.Column('device_id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=256), nullable=False),
    sa.Column('description', sa.Text(), nullable=False),
    sa.Column('type', sa.String(length=256), nullable=False),
    sa.Column('config', sa.Text(), nullable=False),
    sa.PrimaryKeyConstraint('device_id')
    )
    op.create_index(op.f('ix_device_name'), 'device', ['name'], unique=False)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index(op.f('ix_device_name'), table_name='device')
    op.drop_table('device')
    op.drop_table('analytics')
    # ### end Alembic commands ###
