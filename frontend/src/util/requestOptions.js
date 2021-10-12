// https://github.com/cornflourblue/vue-role-based-authorization-example/blob/master/src/_helpers/request-options.js
export default {
    get() {
        return {
            method: 'GET',
            ...headers()
        };
    },
    post(body) {
        return {
            method: 'POST',
            ...headers(),
            body: JSON.stringify(body)
        };
    },
    put(body) {
        return {
            method: 'PUT',
            ...headers(),
            body: JSON.stringify(body)
        };
    },
    delete() {
        return {
            method: 'DELETE',
            ...headers()
        };
    }
}

function headers() {
    // restriction: only handles single user at one time
    const authHeader = localStorage.token ? { 'Authorization': 'Bearer ' + localStorage.token } : {}
    return {
        headers: {
            ...authHeader,
            'Content-Type': 'application/json'
        }
    }
}