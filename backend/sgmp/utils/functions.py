from flask import jsonify

def err_json(message):
    return jsonify({'status': 'error', 'message': message})

def get_obj_path(obj, path):
    if path in obj:
        return obj[path]
    
    path = path.split('.')
    cursor = obj
    for component in path:
        if isinstance(cursor, list):
            component = int(component)
            if component >= len(cursor):
                return None
            cursor = cursor[component]
            continue
        
        if component not in cursor:
            return None
        cursor = cursor[component]

    return cursor