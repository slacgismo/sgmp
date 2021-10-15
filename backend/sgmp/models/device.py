from models.shared import db

class Device(db.Model):
    device_id = db.Column(db.Integer, primary_key=True)
    house_id = db.Column(db.Integer, db.ForeignKey('house.house_id'))
    name = db.Column(db.String(256), nullable=False, index=True)
    description = db.Column(db.Text(), nullable=False)
    type = db.Column(db.String(256), nullable=False)
    config = db.Column(db.Text(), nullable=False)

    def __repr__(self):
        return '<Device %r %r>' % (self.device_id, self.name)