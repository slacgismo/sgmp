from sqlalchemy import Index
from models.shared import db

class Analytics(db.Model):
    __table_args__ = (Index('house_id_name', 'house_id', 'name'),)
    analytics_id = db.Column(db.Integer, primary_key=True)
    house_id = db.Column(db.Integer, db.ForeignKey('house.house_id'), nullable=False)
    name = db.Column(db.String(256), nullable=False)
    description = db.Column(db.Text(), nullable=False)
    formula = db.Column(db.Text(), nullable=False)

    def __repr__(self):
        return '<Analytics %r %r %r>' % (self.analytics_id, self.house_id, self.name)