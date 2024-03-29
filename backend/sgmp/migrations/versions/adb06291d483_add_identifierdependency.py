"""Add IdentifierDependency.

Revision ID: adb06291d483
Revises: 05476c7997eb
Create Date: 2021-10-28 15:41:25.930282

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'adb06291d483'
down_revision = '05476c7997eb'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('identifier_dependency',
    sa.Column('house_id', sa.Integer(), nullable=False),
    sa.Column('identifier', sa.String(length=256), nullable=False),
    sa.Column('analytics_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['analytics_id'], ['analytics.analytics_id'], ),
    sa.ForeignKeyConstraint(['house_id'], ['house.house_id'], ),
    sa.PrimaryKeyConstraint('house_id', 'identifier', 'analytics_id')
    )
    op.add_column('analytics', sa.Column('house_id', sa.Integer(), nullable=False))
    op.drop_index('ix_analytics_name', table_name='analytics')
    op.create_index('house_id_name', 'analytics', ['house_id', 'name'], unique=False)
    op.create_foreign_key(None, 'analytics', 'house', ['house_id'], ['house_id'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, 'analytics', type_='foreignkey')
    op.drop_index('house_id_name', table_name='analytics')
    op.create_index('ix_analytics_name', 'analytics', ['name'], unique=False)
    op.drop_column('analytics', 'house_id')
    op.drop_table('identifier_dependency')
    # ### end Alembic commands ###
