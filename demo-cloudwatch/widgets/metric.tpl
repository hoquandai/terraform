{
  type   = "metric"
  width  = 18
  height = 6
  properties = {
    view    = "${view}"
    stacked = false
    metrics = ${metrics}
    region = ${region},
    annotations = {
      horizontal = [
        {
          color = "#ff9896",
          label = "100% CPU",
          value = 100
        },
        {
          color = "#9edae5",
          label = "100% Memory",
          value = 100,
          yAxis = "right"
        },
      ]
    }
    yAxis = {
      left = {
        min = 0
      }
      right = {
        min = 0
      }
    }
    title  = "${cluster_name} / ${service_name}"
    period = 300
  }
}