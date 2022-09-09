## RUN THIS ON THE SERVER
# 3 - Deploy the echo-python demo application to a Docker container on the lab VM instance, SERVER , using docker to redirect inbound HTTP traffic to the echo-python application via an Endpoints API ESP runtime container.
################

# Create a docker network and use it to redirect inbound traffic sent to the external IP address of the lab server on port 80 to the Endpoints API ESP container.
sudo docker network create --driver bridge esp_net


# Use the gcr.io/google-samples/echo-python:1.0 image for the backend application.
sudo docker run --detach --name=echo --net=esp_net gcr.io/google-samples/echo-python:1.0


# Use the gcr.io/endpoints-release/endpoints-runtime:1 image for the ESP container.
sudo docker run \
    --name=esp \
    --detach \
    --publish=80:8080 \
    --net=esp_net \
    gcr.io/endpoints-release/endpoints-runtime:1 \
    --service=SERVICE_NAME \
    --rollout_strategy=managed \
    --backend=echo:8080

