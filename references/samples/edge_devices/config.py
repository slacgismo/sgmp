
# Pubsub Config
ENDPOINT = "ahj7dwf3rk9hf-ats.iot.us-west-1.amazonaws.com"
CLIENT_ID = "HouseB"
CLIENT_ID_CONTROL = "DER_Controller"
CLIENT_ID_WEB = "Web_User"
PATH_TO_CERT = "certs/batt_sonnen-certificate.pem.crt"
PATH_TO_KEY = "certs/batt_sonnen-private.pem.key"
PATH_TO_ROOT = "certs/AmazonRootCA1.pem"
# TOPIC_PUBLISH = "gismolab-battery-sonnen"
TOPIC_PUBLISH_SONNEN = "gismolab/battery/66358/data"
TOPIC_PUBLISH_EGAUGE = "gismolab/monitoring/47571/data"
TOPIC_CONTROL = "gismolab-battery-sonnen"

# Sonnen info
# Add TOU endpoint and its configuration
URL_BATT_INFO = "http://198.129.119.220:8080/api/battery"
URL_STATUS = "http://198.129.119.220:8080/api/v1/status"
URL_MANUAL_MODE = 'http://198.129.119.220:8080/api/setting/?EM_OperatingMode=1' # (Change mode to manual mode)
URL_SELF_CONS = 'http://198.129.119.220:8080/api/setting/?EM_OperatingMode=8' # (Change mode to self consumption mode)
URL_BACKUP = 'http://198.129.119.220:8080/api/setting/?EM_OperatingMode=7' # (Change mode to backup mode)
URL_BATT_SETPOINT = 'http://198.129.119.220:8080/api/v1/setpoint/'
HEADERS_SONNEN = {}
PAYLOAD_SONNEN = {}