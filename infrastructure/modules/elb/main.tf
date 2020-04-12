resource "aws_elastic_beanstalk_application" "lsccraffler" {
  name        = "lsccraffler"
  description = "Raffler for LSCC events"
}

output "beanstalk_application" {
  value = "${aws_elastic_beanstalk_application.lsccraffler.name}"
}

resource "aws_iam_instance_profile" "beanstalk_service" {
  name = "${var.environment}-beanstalk-service-user"
  role = "${aws_iam_role.beanstalk_service.name}"
}

resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "${var.environment}-beanstalk-ec2-user"
  role = "${aws_iam_role.beanstalk_ec2.name}"
}

resource "aws_iam_role" "beanstalk_service" {
  name = "${var.environment}-beanstalk-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
  name = "${var.environment}-beanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_writer" {
  name        = "${var.environment}-s3_writer_policy"
  description = "Policy to write s3"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "beanstalk_ec2_s3" {
  role      = "${aws_iam_role.beanstalk_ec2.id}"
  policy_arn = "${aws_iam_policy.s3_writer.arn}"
}

resource "aws_iam_role_policy_attachment" "beanstalk_service" {
  role      = "${aws_iam_role.beanstalk_service.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "beanstalk_service_health" {
  role      = "${aws_iam_role.beanstalk_service.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "beanstalk_ec2_worker" {
  role      = "${aws_iam_role.beanstalk_ec2.id}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "beanstalk_ec2_web" {
  role      = "${aws_iam_role.beanstalk_ec2.id}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "beanstalk_ec2_container" {
  role      = "${aws_iam_role.beanstalk_ec2.id}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}


resource "aws_elastic_beanstalk_environment" "lsccraffler" {
  name                   = "lsccraffler-${var.environment}"
  application            = aws_aws_elastic_beanstalk_application.lsccraffler.name
  solution_stack_name    = "64bit Amazon Linux 2018.03 v2.14.3 running Docker 18.09.9-ce"
  wait_for_ready_timeout = "20m"
  depends_on = [
    "aws_iam_role.beanstalk_service",
    "aws_iam_instance_profile.beanstalk_service",
    "aws_iam_role_policy_attachment.beanstalk_service",
    "aws_iam_role_policy_attachment.beanstalk_service_health",
    "aws_iam_role.beanstalk_ec2",
    "aws_iam_instance_profile.beanstalk_ec2",
    "aws_iam_role_policy_attachment.beanstalk_ec2_s3",
    "aws_iam_role_policy_attachment.beanstalk_ec2_web",
    "aws_iam_role_policy_attachment.beanstalk_ec2_worker",
    "aws_iam_role_policy_attachment.beanstalk_ec2_container"
  ]

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.default.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.primary_private.id},${aws_subnet.secondary_private.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${aws_subnet.primary_public.id},${aws_subnet.secondary_public.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instance_type}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = "tcp, 22, 22,${var.ip_prefix}${var.vpc_cidr}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.max_nodes}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.min_nodes}"
  }

  setting {
    # Allows 600 seconds between each autoscaling action
    namespace = "aws:autoscaling:asg"
    name      = "Cooldown"
    value     = "600"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_location}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name ="ConfigDocument"
    value = "${file("cloudwatchmetrics.json")}"
  }

  setting {
    # High threshold for taking down servers for debugging purposes
    namespace = "aws:elb:healthcheck"
    name      = "Interval"
    value     = "300"
  }

  setting {
    # High threshold for taking down servers for debugging purposes
    namespace = "aws:elb:healthcheck"
    name      = "UnhealthyThreshold"
    value     = "10"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name = "HealthStreamingEnabled"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name = "RetentionInDays"
    value = "${var.retention_policy}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "StreamLogs"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "RetentionInDays"
    value = "${var.retention_policy}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ssh_key}"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "${var.rolling_update}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "80"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "IdleTimeout"
    value     = "1800"
  }

  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "false"
  }
  
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = "${var.certificate_arn}"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_role.beanstalk_service.name}"
  }
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.beanstalk_ec2.name}"
  }
}

output "lsccraffler_cname" {
  value = "${aws_elastic_beanstalk_environment.lsccraffler.cname}"
}

output "lsccraffler_load_balancers" {
  value = "${aws_elastic_beanstalk_environment.lsccraffler.load_balancers}"
}
