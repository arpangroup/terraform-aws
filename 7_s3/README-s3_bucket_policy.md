# S3 Bucket Policy


## How can I restrict access to my S3 bucket for all users who have general S3 bucket access, while ensuring that I, as the owner, retain full control over it? [YouTube](https://www.youtube.com/watch?v=DiWWPo2Qoso&list=PLdpzxOOAlwvLNOxX0RfndiYSt1Le9azze&t=2578s)
To restrict access to your S3 bucket for all users who have general S3 bucket access while retaining full control as the owner, you can use a combination of **Bucket Policy** and **Block Public** Access settings. Here's how you can achieve this:

**Use a Bucket Policy to Restrict Access**
````json
{
  "Version": "2012-10-17",
  "Id": "RestrictBucketToIAMUsersOnly",
  "Statement": [
    {
      "Sid": "AllowOwnerOnlyAccess",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::your-bucket-name/*",
        "arn:aws:s3:::your-bucket-name"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalArn": "arn:aws:iam::AWS_ACCOUNT_ID:root"
        }
      }
    }
  ]
}
````


### Another example of S3 Bucket policy
````json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::example-bucket/*"
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::example-bucket/*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalAccount": "123456789012"
        }
      }
    }
  ]
}
````