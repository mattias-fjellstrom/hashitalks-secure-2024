data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "boundary-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}

resource "null_resource" "build" {
  provisioner "local-exec" {
    command     = "./build.sh"
    working_dir = "src"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "src/bootstrap"
  output_path = "lambda.zip"

  depends_on = [
    null_resource.build,
  ]
}

resource "aws_lambda_function" "boundary" {
  function_name    = "on-call-alarms"
  description      = "Assign or revoke the on-call role for the on-call user in Boundary"
  role             = aws_iam_role.lambda.arn
  handler          = "bootstrap"
  runtime          = "provided.al2023"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  architectures    = ["arm64"]

  environment {
    variables = {
      BOUNDARY_ADDR             = var.hcp_boundary_cluster_url
      BOUNDARY_USERNAME         = boundary_account_password.lambda.login_name
      BOUNDARY_PASSWORD         = boundary_account_password.lambda.password
      BOUNDARY_AUTH_METHOD_ID   = data.boundary_auth_method.password.id
      BOUNDARY_ON_CALL_ROLE_ID  = boundary_role.oncall.id
      BOUNDARY_ON_CALL_GROUP_ID = azuread_group.oncall.object_id
    }
  }
}

resource "aws_lambda_permission" "name" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.boundary.function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
}

resource "aws_cloudwatch_metric_alarm" "trigger" {
  alarm_name      = "ec2-cpu-alarm"
  actions_enabled = true

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  dimensions = {
    "InstanceId" = aws_instance.private_target.id
  }

  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 50
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  period              = 60
  treat_missing_data  = "notBreaching"

  # trigger the Boundary lambda function for all state changes
  ok_actions                = [aws_lambda_function.boundary.arn]
  alarm_actions             = [aws_lambda_function.boundary.arn]
  insufficient_data_actions = [aws_lambda_function.boundary.arn]
}

