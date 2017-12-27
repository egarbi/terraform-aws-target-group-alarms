variable "tg_name" {
  description = "The Target Groups' Name for which you need to add alerts"
}

variable "lb_arn" {
  description = "The ALB's ARN associated with all TGs (need to be the same)"
}

variable "sns_arn" {
  description = "SNS associated with the email, slack, push service paging your Team"
}

data "aws_lb_target_group" "main" {
  name = "${var.tg_name}"
}

data "aws_lb" "main" {
  arn = "${var.lb_arn}"
}

variable "time_response_thresholds" {
  default = {
    period              = "60" //Seconds
    statistic           = "Average"
    threshold           = "30" //Seconds
 }
}

variable "500s_thresholds" {
  default = {
    period              = "60" //Seconds
    statistic           = "Average"
    threshold           = "1" //Seconds
 }
}

resource "aws_cloudwatch_metric_alarm" "target-response-time" {
  alarm_name          = "${var.tg_name}-Response-Time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "${lookup(var.time_response_thresholds, "period")}"
  statistic           = "${lookup(var.time_response_thresholds, "statistic")}"
  threshold           = "${lookup(var.time_response_thresholds, "threshold")}"

  dimensions {
    LoadBalancer = "${data.aws_lb.main.arn_suffix}"
    TargetGroup  = "${data.aws_lb_target_group.main.arn_suffix}"
  }

  alarm_description  = "Trigger an alert when response time in ${var.tg_name} goes high"
  alarm_actions      = ["${var.sns_arn}"]
  ok_actions         = ["${var.sns_arn}"]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target-healthy-count" {
  alarm_name          = "${var.tg_name}-Healthy-Count"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"

  dimensions {
    LoadBalancer = "${data.aws_lb.main.arn_suffix}"
    TargetGroup  = "${data.aws_lb_target_group.main.arn_suffix}"
  }

  alarm_description  = "Trigger an alert when ${var.tg_name} has 1 or more unhealthy hosts"
  alarm_actions      = ["${var.sns_arn}"]
  ok_actions         = ["${var.sns_arn}"]
  treat_missing_data = "Breaching"
}

resource "aws_cloudwatch_metric_alarm" "target-500" {
  alarm_name          = "${replace(var.tg_name,"/(targetgroup/)|(/\\w+$)/","")}-HTTP-5XX"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "${lookup(var.500s_thresholds, "period")}"
  statistic           = "${lookup(var.500s_thresholds, "statistic")}"
  threshold           = "${lookup(var.500s_thresholds, "threshold")}"

  dimensions {
    LoadBalancer = "${data.aws_lb.main.arn_suffix}"
    TargetGroup  = "${data.aws_lb_target_group.main.arn_suffix}"
  }

  alarm_description  = "Trigger an alert when 5XX's in ${var.tg_name} goes high"
  alarm_actions      = ["${var.sns_arn}"]
  ok_actions         = ["${var.sns_arn}"]
  treat_missing_data = "notBreaching"
}
