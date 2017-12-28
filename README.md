AWS Target Group Alarms Terraform module
========================

Terraform module which add basic CloudWatch alarms for Target Group associated to ECS services.

An alarm will be triggered if:

* No healthy ECS tasks are registered with the Target Group.
* if response code 5XX coming from the TG are greater than or equal to the configured threshold.
* if response time value is greater than the configured threshold.

> Note: Thresholds other than defaultis can be overwriten passing variabled as shown below.


Usage
-----

```hcl
module "ecs_services_alarms" {
  source = "git::https://github.com/egarbi/terraform-aws-target-group-alarms?ref=0.0.1"

  tg_name         = "${var.name}-${terraform.env}"
  lb_arn          = "${data.terraform_remote_state.vpc.alb_arn}"
  sns_arn         = "${data.aws_sns_topic.main.arn}"
  // These 2 variables are optional, shown as an example with defaults values
  time_response_thresholds = { 
    period = "60" 
    statistic = "Average" 
    threshold = "30" 
  } 
  5XXs_thresholds = {
    period = "60"
    statistic = "Average"
    threshold = "1"
  }
}
```
