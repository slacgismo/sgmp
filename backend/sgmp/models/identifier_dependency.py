from sqlalchemy import Index
from models.shared import db

class IdentifierDependency(db.Model):
    house_id = db.Column(db.Integer, db.ForeignKey('house.house_id'), nullable=False, primary_key=True)
    identifier = db.Column(db.String(256), nullable=False, primary_key=True)
    analytics_id = db.Column(db.Integer, db.ForeignKey('analytics.analytics_id'), nullable=False, primary_key=True)

    def __repr__(self):
        return '<IdentifierDependency %r %r %r>' % (self.house_id, self.identifier, self.analytics_id)