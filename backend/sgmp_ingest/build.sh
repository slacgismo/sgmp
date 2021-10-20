#!/bin/bash

echo "Removing previous build.."
rm -f sgmp_ingest.zip

echo "Packing libraries.."
cd package
zip -r ../sgmp_ingest.zip .

echo "Adding main script.."
cd ..
zip -g sgmp_ingest.zip lambda_function.py

echo "Done!"
