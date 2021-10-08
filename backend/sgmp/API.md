# API docs

This a very first draft of the API specification. We should move it into other solutions such as Swagger after the API are more mature.

## User & Role

The idea is to make the API appear to the frontend as platform-agnostic as possible. We can possibly move the backend user storage between AWS Cognito or a local MySQL database or any other identity provider.

### `/api/user/list`

Lists all users.

Sample response:
```
{
    "status": "ok",
    "users": [
        {
            "email": "chihweif@andrew.cmu.edu",
            "name": "Chih-Wei Fang",
            "role": ["admin"],
            "created date": "Fri, 01 Oct 2021 21:43:22 GMT"
        },
        {
            "email": "yingdonc@andrew.cmu.edu",
            "name": "Yingdong Chen",
            "role": ["visitor"],
            "created date": "Fri, 01 Oct 2021 21:43:22 GMT"
        }
    ]
}
```
### `/api/user/create`

Creates a new user. The role must exist in the system and the email must be unique. The system will send an email with a temporary password to the user.

Sample request:
```
{
    "email": "yingdonc@andrew.cmu.edu",
    "name: "yingdong chen"
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/user/login`

Validate the user's identification.

Sample request:
```
{
    "email": "yingdonc@andrew.cmu.edu",
    "passowrd": "Aa123456!"
}
```

Sample response:
```
{
    "status": "ok"
    "accesstoken": "xxxxxxxxx"
}
```

### `/api/user/changePassword`

Change user's  password

Sample request:
```
{
    "email": "yingdonc@andrew.cmu.edu",
    "password": "Aa123456!"
}
```
Sample response:
```
{
    "status" "ok"
}
```

### `/api/user/update`

Updates the data of an user. Must specify the email to identify the user. Other fields are optional, only the updated fields are required.

Sample request, finds the user with email `chihweif@andrew.cmu.edu` and sets its name and role:
```
{
    "email": "chihweif@andrew.cmu.edu",
    "name": "Chih-Wei Fang",
    "role": "admin"
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/user/delete`

Deletes a user by the email.

Sample request:
```
{
    "email": "chihweif@andrew.cmu.edu"
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/role/list`

Lists all roles.

Sample response:
```
{
    "status": "ok",
    "roles": [
        "admin",
        "researcher",
        "visitor"
    ]
}
```

### `/api/role/create`

Creates a new role. The role name must not exist in the system.

Sample request:
```
{
    "role": "new_role"
}
```

Sample response:
```
{
    "status": "ok"
}
```


### `/api/role/delete`

Deletes a role. There must be no user with that role.

Sample request:
```
{
    "role": "new_role"
}
```

Sample response:
```
{
    "status": "ok"
}

 if there is still some users belonging to the role, the role will not be deleted, and 
 it will reply a status with error message
{
    "status": "some users still in list"
}
```
## Data

We have two types of data. The first is raw readings from the device itself. Another one is analytics, which is defined by the user. The user can define an analytics by specifying the formula, for example if they have a eGauge with 4 current transformers on the load line, the user can make a `total_load` analytics with the formula being `egague.0 + egauge.1 + egauge.2 + egague.3`. All of the device configurations are pushed to the edge device. The edge device will make periodical readings from the devices using the configuration and publish to IoT core. To save disk space the analytics will only be performed when the data is read.

### `/api/data/read`

Reads data from a given time period. Device means raw readings from a device, analytics means user-defined analytics data.

Sample request:
```
{
    "start_time": 1632499200000,
    "end_time": 1632502800000,
    "type": "device",
    "device_id": 12345
}
```

```
{
    "start_time": 1632499200000,
    "end_time": 1632502800000,
    "type": "analytics",
    "analytics_id": 12345
}
```

Sample response for device (returns all readings, format defined by device type):
```
{
    "status": "ok",
    "data": [
        {
            "timestamp": 1632499200000,
            "data": {
                "battery_level": 10,
                "battery_temp": 75
            }
        },
        {
            "timestamp": 1632499201000,
            "data": {
                "battery_level": 12,
                "battery_temp": 75
            }
        }
        {
            "timestamp": 1632499202000,
            "data": {
                "battery_level": 14,
                "battery_temp": 76
            }
        }
    ]
}
```

Sample response for analytics (returns the calculation result):
```
{
    "status": "ok",
    "data": [
        {
            "timestamp": 1632499200000,
            "data": 1.0
        },
        {
            "timestamp": 1632499201000,
            "data": 2.0
        }
        {
            "timestamp": 1632499202000,
            "data": 3.0
        }
    ]
}
```

### `/api/device/list`

Lists all device.

Sample response:
```
{
    "status": "ok",
    "devices": [
        {
            "device_id": 12345,
            "name": "sonnen",
            "description": "Sonnen controller inside the house"
        }
    ]
}
```

### `/api/device/create`

Creates a device. The device type should be specified. The config field is a JSON object and its format is defined by the device type. The device name is unique and can only contain alphabets, numbers and underscore, and cannot start with a number. The device ID will be assigned by the database automatically.

Sample request:
```
{
    "name": "sonnen",
    "description": "Sonnen controller inside the house",
    "type": "sonnen",
    "config": {
        "ip": "1.2.3.4",
        "username": "user",
        "password": "password"
    }
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/device/update`

Updates the config of a device. To ensure consistency of data the type of the device cannot be changed.

Sample request:
```
{
    "name": "sonnen",
    "description": "Sonnen controller inside the house",
    "config": {
        "ip": "1.2.3.4",
        "username": "user",
        "password": "password"
    }
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/device/delete`

Deletes a device.

Sample request:
```
{
    "name": "sonnen"
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/analytics/create`

Creates an analytics. The name must be unique.

Sample request:
```
{
    "name": "total_load",
    "description": "Total load, measured from the eGauge",
    "formula": "egauge.0 + egauge.1 + egauge.2 + egauge.3"
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/analytics/update`

Updates an analytics.

Sample request:
```
{
    "name": "total_load",
    "description": "Total load, measured from Sonnen",
    "formula": "sonnen.load"
}
```

Sample response:
```
{
    "status": "ok"
}
```

### `/api/analytics/delete`

Delete an analytics.

Sample request:
```
{
    "name": "total_load"
}
```

Sample response:
```
{
    "status": "ok"
}
```
