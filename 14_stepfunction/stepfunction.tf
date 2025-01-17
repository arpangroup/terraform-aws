# Read the JSON definition file
# Templatefile Function: The templatefile function reads the JSON file and replaces placeholders with actual values (e.g., Lambda ARNs)
# Local Variable: he local.step_function_definition variable stores the processed JSON definition.
locals {
  step_function_definition = templatefile("step_function_definition.json", {
    validate_order_lambda_arn     = aws_lambda_function.validate_order.arn
    process_payment_lambda_arn    = aws_lambda_function.process_payment.arn
    prepare_shipment_lambda_arn   = aws_lambda_function.prepare_shipment.arn
    notify_customer_lambda_arn    = aws_lambda_function.notify_customer.arn
    handle_error_lambda_arn       = aws_lambda_function.handle_error.arn
  })
}


# Step Function Definition
resource "aws_sfn_state_machine" "order_processing" {
  name     = "OrderProcessingWorkflow"
  role_arn = aws_iam_role.step_function_role.arn
  definition = local.step_function_definition

  /*definition = <<EOF
  {
    "Comment": "Order Processing Workflow",
    "StartAt": "ValidateOrder",
    "States": {
      "ValidateOrder": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.validate_order.arn}",
        "Next": "ProcessPayment",
        "Catch": [
          {
            "ErrorEquals": ["States.ALL"],
            "Next": "HandleError"
          }
        ]
      },
      "ProcessPayment": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.process_payment.arn}",
        "Next": "PrepareShipment",
        "Catch": [
          {
            "ErrorEquals": ["States.ALL"],
            "Next": "HandleError"
          }
        ]
      },
      "PrepareShipment": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.prepare_shipment.arn}",
        "Next": "NotifyCustomer",
        "Catch": [
          {
            "ErrorEquals": ["States.ALL"],
            "Next": "HandleError"
          }
        ]
      },
      "NotifyCustomer": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.notify_customer.arn}",
        "End": true,
        "Catch": [
          {
            "ErrorEquals": ["States.ALL"],
            "Next": "HandleError"
          }
        ]
      },
      "HandleError": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.handle_error.arn}",
        "End": true
      }
    }
  }
  EOF*/
}


# IAM Role for Step Function
resource "aws_iam_role" "step_function_role" {
  name = "StepFunctionExecutionRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Step Function
resource "aws_iam_policy" "step_function_policy" {
  name        = "StepFunctionPolicy"
  description = "Policy for Step Function to invoke Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "sns:Publish",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}