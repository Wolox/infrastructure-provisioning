# Permissions

## Add this policy to the billing bucket
```
{
    "Effect": "Allow",
    "Principal": {
        "AWS": "arn:aws:iam::627186226551:role/lambda-aws-billing"
    },
    "Action": "s3:GetObject",
    "Resource": [
        "arn:aws:s3:::my-billing-bucket",
        "arn:aws:s3:::my-billing-bucket/*"
    ]
}
```

## Run this to give your lambda function permissions to be executed from S3

aws lambda add-permission \
--function-name my-lambda-function \
--region us-east-1 \
--statement-id unique-id \
--action "lambda:InvokeFunction" \
--principal s3.amazonaws.com \
--source-arn arn:aws:s3:::my-billing-bucket \
--source-account account_id \
--profile profile

## Add this permission to your lambda function

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1496252952000",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::my-billing-bucket",
                "arn:aws:s3:::my-billing-bucket/*"
            ]
        }
    ]
}
```
