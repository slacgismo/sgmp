from models.shared import db

class IdentifierView(db.Model):
    house_id = db.Column(db.Integer, db.ForeignKey('house.house_id'), nullable=False, primary_key=True)
    identifier = db.Column(db.String(256), nullable=False, primary_key=True)
    view_name = db.Column(db.String(256), nullable=False)

    def __repr__(self):
        return '<IdentifierView %r %r %r>' % (self.house_id, self.identifier, self.view_name)