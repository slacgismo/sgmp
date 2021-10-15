from models.shared import db
from sqlalchemy.orm import relationship

class House(db.Model):
    house_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(256), nullable=False)
    description = db.Column(db.Text(), nullable=False)
    devices = relationship('Device')

    def __repr__(self):
        return '<House %r %r>' % (self.house_id, self.name)