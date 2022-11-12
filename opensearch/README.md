## Notes

### Access Policy for Fine-grained access control with internal user database
- references:
  https://docs.amazonaws.cn/en_us/opensearch-service/latest/developerguide/fgac-walkthrough-basic.html

### Advance Security Options
  - Fine-grained access control requires OpenSearch or Elasticsearch 6.7 or later. It also requires HTTPS for all traffic to the domain, Encryption of data at rest, and node-to-node encryption. After you enable fine-grained access control, you can't disable it.

  - You must enable node-to-node encryption to use advanced security options.
  - You must enable EnforceHTTPS in the domain endpoint options to use advanced security.
  - Set AnonymousAuthEnabled to true to enable the migration period with fine-grained access control
  - Cannot enable anonymous auth during domain creation.

ssh -i ~/Downloads/opensearch_11.pem ec2-user@54.156.40.92 -N -L 9200:vpc-daiho-sns-dev-opensearch.us-east-1.es.amazonaws.com:443