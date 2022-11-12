README.md
SSM:
	- https://github.com/mludvig/aws-ssm-tools/blob/master/sample-templates/terraform/ecs.tf
	- https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#plugin-version-history

aws ecs execute-command --cluster sns-cluster \
    --task 15241373ef2e47e8a5a789804f968712 \
    --container sns-cluster \
    --interactive \
    --command "/bin/sh"

curl https://vpc-daiho-sns-dev-opensearch-rl4r347marg4fzcr55oijy24ke.us-east-1.es.amazonaws.com -u "master:Master_1_2_3"

curl -XPUT -u "master:Master_1_2_3" 'https://vpc-daiho-sns-dev-opensearch-rl4r347marg4fzcr55oijy24ke.us-east-1.es.amazonaws.com/movies/_doc/1' -d '{"director": "Burton, Tim", "genre": ["Comedy","Sci-Fi"], "year": 1996, "actor": ["Jack Nicholson","Pierce Brosnan","Sarah Jessica Parker"], "title": "Mars Attacks!"}' -H 'Content-Type: application/json'

curl -XGET -u "master:Master_1_2_3" 'https://vpc-daiho-sns-dev-opensearch-rl4r347marg4fzcr55oijy24ke.us-east-1.es.amazonaws.com/movies/_search?pretty=true'

curl -XGET -u "master:Master_1_2_3" 'https://vpc-daiho-sns-dev-opensearch-rl4r347marg4fzcr55oijy24ke.us-east-1.es.amazonaws.com/_plugins/_security/api/roles/?pretty=true'

curl -XGET u "master:Master_1_2_3" 'https://vpc-daiho-sns-dev-opensearch-rl4r347marg4fzcr55oijy24ke.us-east-1.es.amazonaws.com/_plugins/_security/api/roles?pretty=true'


curl -XPUT -u "daiho:DaiHo_123" 'https://vpc-daiho-sns-dev-opensearch-rl4r347marg4fzcr55oijy24ke.us-east-1.es.amazonaws.com/_plugins/_security/api/internalusers/daiho' -d '{"password":"DaiHo_123","opendistro_security_roles":["readall"],"attributes":{"attribute1":"value1","attribute2":"value2"}}' -H 'Content-Type: application/json'

DaiHo_123

curl -XGET -u "daiho:DaiHo_123" 'https://vpc-daiho-sns-dev-opensearch-rl4r347marg4fzcr55oijy24ke.us-east-1.es.amazonaws.com/movies/_search?pretty=true'