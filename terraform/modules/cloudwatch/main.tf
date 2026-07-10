resource "aws_cloudwatch_dashboard" "capstone_dashboard" {
  dashboard_name = "capstone-dashboard"

  dashboard_body = jsonencode({
    widgets = [

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "ALB Request Count"
          region  = "ap-south-1"
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              var.ALB_arn_suffix
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "Target Response Time"
          region  = "ap-south-1"
          view    = "timeSeries"
          stat    = "Average"
          period  = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              var.ALB_arn_suffix
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "ALB Target 5XX Errors"
          region  = "ap-south-1"
          view    = "timeSeries"
          stat    = "Sum"
          period  = 60

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "LoadBalancer",
              var.ALB_arn_suffix
            ]
          ]
        }
      },

      {
  type   = "metric"
  x      = 12
  y      = 6
  width  = 12
  height = 6

  properties = {
    title  = "Healthy Hosts (Blue vs Green)"
    region = "ap-south-1"
    view   = "timeSeries"
    stat   = "Average"
    period = 60

    metrics = [
      [
        "AWS/ApplicationELB",
        "HealthyHostCount",
        "TargetGroup",
        var.target_group_arn_suffix,
        "LoadBalancer",
        var.ALB_arn_suffix,
        {
          label = "Blue"
        }
      ],
      [
        ".",
        ".",
        "TargetGroup",
        var.green_target_group_arn_suffix,
        "LoadBalancer",
        ".",
        {
          label = "Green"
        }
      ]
    ]
  }
},

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title   = "ECS CPU Utilization"
          region  = "ap-south-1"
          view    = "timeSeries"
          stat    = "Average"
          period  = 300

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              var.cluster_name,
              "ServiceName",
              var.service_name
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title   = "ECS Memory Utilization"
          region  = "ap-south-1"
          view    = "timeSeries"
          stat    = "Average"
          period  = 300

          metrics = [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              var.cluster_name,
              "ServiceName",
              var.service_name
            ]
          ]
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name = "alb_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  threshold = 5

  namespace = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic = "Sum"
  period = 60

  dimensions = {
    LoadBalancer = var.ALB_arn_suffix
  }
  treat_missing_data = "notBreaching"
}