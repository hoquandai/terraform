aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 165541912265.dkr.ecr.us-east-1.amazonaws.com
aws ecr create-repository \
    --repository-name sns \
    --image-scanning-configuration scanOnPush=true \
    --region us-east-1
docker tag hello-world:latest 165541912265.dkr.ecr.us-east-1.amazonaws.com/sns
docker push 165541912265.dkr.ecr.us-east-1.amazonaws.com/sns