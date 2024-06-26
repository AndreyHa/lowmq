# prepare-release.sh
#!/bin/bash
# This script prepares a release of the project.

# Check if the script is run from the root of the project.
if [ ! -f "prepare-release.sh" ]; then
    echo "This script must be run from the root of the project."
    exit 1
fi

# Check if the script is run from the main branch.
if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
    echo "This script must be run from the main branch."
    exit 1
fi

# # Make sure the working directory is clean.
if [ -n "$(git status --porcelain)" ]; then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1
fi

# Check resources/db.json file is an empty object: {}.
if [ "$(cat resources/db.json)" != "{}" ]; then
    echo "The resources/db.json file is not empty. Please empty it."
    exit 1
fi 

# Clean install the project.
npm ci

# build the project
npm run build

# leave only production dependencies
rm -rf node_modules
npm install --only=production

# Make sure release directory is clean.
if [ -d "build/Release/lowmq-latest" ]; then
    rm -rf build/Release/lowmq-latest
fi

# Create a folder for the release
mkdir build/Release/lowmq-latest

# Copy the package.json to the release folder
cp package.json build/Release/lowmq-latest

# Copy the build files to the release folder
cp -R lowmq.js build/Release/lowmq-latest

# Copy node_modules to the release folder
cp -R node_modules build/Release/lowmq-latest

# Copy resources to the release folder
cp -R resources build/Release/lowmq-latest

# Rm default files: db and tokens
rm -rf build/Release/lowmq-latest/resources/db.json
rm -rf build/Release/lowmq-latest/resources/tokens

# Create a zip file for the release
rm -f build/Release/lowmq.zip
cd build/Release
zip -rq lowmq.zip lowmq-latest


# Regenerate the node_modules folder
npm ci

# Print that the release is ready
echo "Release is ready. Please upload build/Release/lowmq.zip to the release."
