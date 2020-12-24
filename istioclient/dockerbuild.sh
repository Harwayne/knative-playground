set -e -o

docker build -t harwayne/istioclient .
docker push harwayne/istioclient

