
resource "aws_sfn_state_machine" "state_machine" {
  name     = "processor-state-machine"
  role_arn = aws_iam_role.lambda_execution_role.arn

  definition = <<JSON
{
  "Comment": "A description of my state machine",
  "StartAt": "Processor",
  "States": {
    "Processor": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.processor_lambda.arn}",
      "Retry": [
        {
          "ErrorEquals": ["States.ALL"],
          "IntervalSeconds": 2,
          "MaxAttempts": 3,
          "BackoffRate": 2.0
        }
      ],
      "Next": "Writer"
    },
    "Writer": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.writer_lambda.arn}",
      "End": true
    }
  }
}
JSON
}
