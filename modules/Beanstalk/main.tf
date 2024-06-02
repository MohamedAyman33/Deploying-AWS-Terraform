#Create Beanstalk Application 
resource "aws_elastic_beanstalk_application" "WTI" {
  name        = "WTI"
  description = "WTI_ON_BEANSTALK"
}


#----------------------------------------------------------------------------------------------------------------------------
#Upload source code in beanstalk
resource "aws_elastic_beanstalk_application_version" "WTI_VERSION" {
  name        = "v1"
  application = aws_elastic_beanstalk_application.WTI.name
  description = "Version 1 of the WTI application"
  bucket = var.S3_id
  key =  var.WTI_SourceCode
  depends_on = [var.aws_s3_bucket_public_access_block]
}

#----------------------------------------------------------------------------------------------------------------------------



#Create Beanstalk Enviroment
resource "aws_elastic_beanstalk_environment" "WTI_ENV" {
  name                = "WTI-ENV"
  application         = aws_elastic_beanstalk_application.WTI.name
  # solution_stack_name = "64bit Amazon Linux 2 v3.7.2 running Corretto 8"
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.2 running Docker"  
  version_label = aws_elastic_beanstalk_application_version.WTI_VERSION.name
  depends_on = [ var.pc2_ec2 ]


#-----------------------------------------------------------------------------------------------------------
 # VPC configuration
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc-id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private-subnets)
  }



  # Add Application Load balancer settings
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application" # Using an application load balancer
  }

  # Public subnets for load balancer
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public-subnets)
  }

   # Enable stickiness on the target group
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled"
    value     = "true"
  }

  # Configure the application to listen on port 80
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "80"
  }


  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessType"
    value     = "lb_cookie"  # Use load balancer-generated cookie
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessLBCookieDuration"
    value     = "259200"  # Stickiness duration in seconds (1 day)
  }
  
 #----------------------------------------------------------------------------------------------------------------------------

  # Add Auto-scaling settings
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }
# Add Auto-scaling settings
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }
#----------------------------------------------------------------------------------------------------------------------------

  # Add Instance settings
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.xlarge" # Set the instance type to t3.xlarge
  }

  #Disable Public ip address
  #  setting {
  #   namespace = "aws:autoscaling:launchconfiguration"
  #   name      = "AssociatePublicIpAddress"
  #   value     = "false"
  # }

#Add ssh keys 
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "acpc-2024-internal"  # Replace with your actual key pair name
  }
  #Add Instance Profile
   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  # Scaling policy to scale up when CPU exceeds 70% for 3 minutes
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "CPUUtilization"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "Average"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Percent"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "70"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "EvaluationPeriods"
    value     = "3" # 3 consecutive periods
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "BreachDuration"
    value     = "180" # 3 minutes (3 * 60 seconds)
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold" # Not needed for scale up
    value     = "0"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Period"
    value     = "1"
  }
}




#----------------------------------------------------------------------------------------------------------------------------
