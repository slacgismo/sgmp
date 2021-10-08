from models.shared import db

class Analytics(db.Model):
    analytics_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(256), nullable=False, index=True)
    description = db.Column(db.Text(), nullable=False)
    formula = db.Column(db.Text(), nullable=False)

    def __repr__(self):
        return '<Analytics %r %r>' % (self.analytics_id, self.name)