set -e

# Build image
docker build -t capbuilder .

# Remove previous container, create new one
docker rm -f builder
docker run -d --name builder capbuilder sleep infinity

# Move project files to container
docker cp . builder:/workdir/

# Remove local/cached files
docker exec -it builder rm -rf android
# docker exec -it builder rm -rf dist

# Build static page
docker exec -it builder npm install --include dev
# docker exec -it builder npm run build

# Prepare gradle build folder
set +e
docker exec -it builder bash -c "yes | npx cap add android"
set -e
# Build .apk
docker exec -it builder bash -c "cd android && gradle build"

# Copy output folder to local directory
rm -rf apk
sleep 1
docker cp builder:/workdir/android/app/build/outputs/apk apk
