# SGMP API Specifications
## Serving
You can use `redoc-cli` to serve the API specs dynamically. First install the package:

    npm install -g redoc-cli

Now start the server:

    redoc-cli serve --watch swagger.yaml

The server will start at port 8080. It will watch for file changes, so after a file is updated, you can refresh the browser to see the results.