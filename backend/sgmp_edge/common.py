class ReadResult:
    def __init__(self):
        self.events = []
        self.readings = []

class Event:
    def __init__(self, timestamp, type, data):
        self.timestamp = timestamp
        self.type = type
        self.data = data

class Reading:
    def __init__(self, timestamp, data):
        self.timestamp = timestamp
        self.data = data