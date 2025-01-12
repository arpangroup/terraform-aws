# Step1: Define the CRON expression
resource "aws_scheduler_schedule" "TF_example_schedule" {
  name        = "example_schedule"
  description = "Trigger Lambda function every day at 10:00 UTC"

  /* Recurring schedule :: CRON Explanation
  1. 10 → Minute (10th minute of the hour).
  2. 0 → Hour (0th hour, which is 12:00 AM UTC).
  3. * → Every day of the month.
  4. * → Every month.
  5. ? → No specific day of the week.
  6. * → Every year.
  IST = UTC + 5:30  ==> UTC = (IST - 5:30)*/
  #schedule_expression = "cron(0 10 * * ? *)"    # Every day at 10:00 UTC
  #schedule_expression = "cron(0 10 * * ? *)"    # Every day at 12:10 UTC
  #schedule_expression = "cron(35 17 * * ? *)"   # 11:05 PM IST (17:35 UTC) ; UTC+5:30
  #schedule_expression = "cron(40 18 * * ? *)"   # 12:10 AM IST (06:40 UTC) ; UTC+5:30
  #schedule_expression = "cron(20 5 ? * SUN *)"  # 10:50 AM IST ( 10:50 AM IST - 5hr 30min  ==> 5:20 AM UTC)
  #schedule_expression = "cron(50 5 ? * SUN *)"  # 11:20 AM IST ( 11:20 AM IST - 5hr 30 min ==> 5:50 AM UTC)


  # one-time schedule (12:15 PM IST on January 12, 2025)
  #schedule_expression = "at(2025-01-12T06:45:00)" # (06:45 + 5:30) ==> 11:75 ==> 12:15 PM
  schedule_expression = "at(2025-01-12T13:48:00)" #IST
  schedule_expression_timezone = "Asia/Kolkata"   # Specify the time zone (IST)

  # Add flexible_time_window block
  flexible_time_window {
    mode = "OFF" # Use "OFF" for no flexibility, or "FLEXIBLE" for a time window
    #maximum_window_in_minutes = 2 # Allow a 2-minute window for execution if mode = OFF
  }

  target {
    arn = aws_lambda_function.TF_LAMBDA_EXAMPLE.arn
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn

    input = jsonencode({
      key1 = "value1"
      key2 = "value2"
    })
  }
}


# Step2: Define the IAM Role for EventBridge Scheduler (using a managed policy)
resource "aws_iam_role" "eventbridge_scheduler_role" {
  name = "tf_eventbridge_scheduler_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

}

# Step3.1: Define the IAM Policy
resource "aws_iam_policy" "eventbridge_scheduler_policy" {
  name        = "tf_eventbridge_scheduler_policy"
  description = "Policy for EventBridge Scheduler to invoke Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.TF_LAMBDA_EXAMPLE.arn
      }
    ]
  })
}

# Step3.2: Attach the Policy
resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_policy_attachment" {
  role       = aws_iam_role.eventbridge_scheduler_role.name
  policy_arn = aws_iam_policy.eventbridge_scheduler_policy.arn
}