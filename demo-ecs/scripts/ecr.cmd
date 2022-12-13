aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 999470467758.dkr.ecr.us-east-1.amazonaws.com
aws ecr create-repository \
    --repository-name sns \
    --image-scanning-configuration scanOnPush=true \
    --region us-east-1
docker tag hello_daiho:latest 999470467758.dkr.ecr.us-east-1.amazonaws.com/sns:latest
docker push 999470467758.dkr.ecr.us-east-1.amazonaws.com/sns:latest

curl -s "http://sns-cluster-load-balancer-1578602358.us-east-1.elb.amazonaws.com?[1-30]"