{
  "widgets": [
    %{ for service_name in service_names ~}
    {
      "type": "metric",
      "start": "-PT3H",
      "width": 14,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${service_name}", "ClusterName", "${cluster_name}", { "color": "#d62728", "stat": "Average" }],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "${service_name}", "ClusterName", "${cluster_name}", { "yAxis": "right", "color": "#1f77b4", "stat": "Average" }]
        ],
        "region": "${aws_region}",
        "annotations": {
          "horizontal": [
            {
              "color": "#ff9896",
              "label": "100% CPU",
              "value": 100
            },
            {
              "color": "#9edae5",
              "label": "100% Memory",
              "value": 100,
              "yAxis": "right"
            }
          ]
        },
        "yAxis": {
          "left": {
            "min": 0
          },
          "right": {
            "min": 0
          }
        },
        "title": "${cluster_name} / ${service_name}",
        "period": 300
      }
    },
    %{ endfor ~}
  ]
}
