variable "billing_alarm_threshold" {}

resource "aws_cloudwatch_metric_alarm" "billing" {
    alarm_name = "billing-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "EstimatedCharges"
    namespace = "AWS/Billing"
    period = "21600"
    statistic = "Maximum"
    threshold = "${var.billing_alarm_threshold}"
    alarm_description = "This metric monitors estimated charges"
    insufficient_data_actions = []
}
