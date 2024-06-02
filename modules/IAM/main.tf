#------------------------------------------------------------------
#Policy for Control Machine to access other ec2 resorces
resource "aws_iam_role" "Control_role" {
  name = "Control_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "Control_role"
  }
}
# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.Control_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_instance_profile" "ec2_role_policy_profile" {
  name = "ec2_role_policy_profile"
  role = aws_iam_role.Control_role.name
}
#----------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}


# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_access_role_policy_attachment" {
  role       = aws_iam_role.s3_access_role.name
  #policy_arn = aws_iam_policy.s3_access_policy.arn
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create an instance profile for the IAM role
resource "aws_iam_instance_profile" "s3_instance_profile" {
  name = "s3_instance_profile"
  role = aws_iam_role.s3_access_role.name
}


#----------------------------------------------------------------------------------------------------------------
#Create IAM role for beanstalk to manage enviroment egs: scaleup,Create elb, cloudwatch
resource "aws_iam_role" "beanstalk_service_role" {
  name = "aws-elasticbeanstalk-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "beanstalk_service_role_policy1" {
  role       = aws_iam_role.beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}


resource "aws_iam_role_policy_attachment" "beanstalk_service_role_policy2" {
  role       = aws_iam_role.beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

#----------------------------------------------------------------------------------------------------------------
#Policy for beanstalk to access ec2 resorces
resource "aws_iam_role" "beanstalk_ec2_role" {
  name = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "aws-elasticbeanstalk-ec2-role"
  }
}


resource "aws_iam_role_policy_attachment" "beanstalk_ec2_service_role_policy2" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}


# Create an instance profile for the IAM role
resource "aws_iam_instance_profile" "beanstalk_ec2_service_role_profile" {
  name = "aws-elasticbeanstalk-ec2-role"
  role = aws_iam_role.beanstalk_ec2_role.name
}