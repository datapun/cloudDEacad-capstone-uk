#maybe one event rule is enough - can be attached to multiple functions
resource "aws_cloudwatch_event_rule" "daily_api" {
  name        = "${local.name_prefix}capture-api-data"
  description = "daily download of data via api"

  schedule_expression = "cron(0/5 * * * ? *)"
}
/*
resource "aws_cloudwatch_event_rule" "daily_hospitals_api" {
  name        = "${local.name_prefix}capture-api-hospitals-data"
  description = "daily download of hospitals data via api"

  schedule_expression = "cron(0/5 * * * ? *)"
}
*/
resource "aws_cloudwatch_event_target" "download_covid_data_every_day" {
  rule      = "${aws_cloudwatch_event_rule.daily_api.name}"
  target_id = "lambda_covid"
  arn       = "${aws_lambda_function.download_api_covid_lambda.arn}"
}

resource "aws_cloudwatch_event_target" "download_hospitals_data_every_day" {
  rule      = "${aws_cloudwatch_event_rule.daily_api.name}"
  target_id = "lambda_hosp"
  arn       = "${aws_lambda_function.download_api_hospitals_lambda.arn}"
}