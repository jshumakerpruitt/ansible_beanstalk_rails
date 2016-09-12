CloudFormation do
  Description("Template to create EB App+Env")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("SolutionStackName") do
    Description("Solution Stack Name")
    Type("String")
  end

  Parameter('KeyName') do
    Description("EC2 Key Name for SSH Access")
    Type('AWS::EC2::KeyPair::KeyName')
  end

  Parameter('EnvironmentName') do
    Description("Environment name e.g. rails-staging")
    Type('String')
  end

  Parameter('ApplicationName') do
    Description("Application name e.g. my-app")
    Type('String')
  end

  Parameter('ASGMin') do
    Description("Min number of instances in ASG")
    Type('Number')
  end

  Parameter('ASGMax') do
    Description("Max number of instances in ASG")
    Type('Number')
  end

  Resource("BeanstalkApplication") do
    Type("AWS::ElasticBeanstalk::Application")
    Property("ApplicationName", Ref("ApplicationName"))
    Property("Description", "EB application")
  end

  Resource("BeanstalkConfigurationTemplate") do
    Type("AWS::ElasticBeanstalk::ConfigurationTemplate")
    Property("ApplicationName", Ref("BeanstalkApplication"))
    Property("Description", "AWS ElasticBeanstalk Configuration Template")
    Property("OptionSettings", [
               {
                 "Namespace"  => "aws:autoscaling:asg",
                 "OptionName" => "MinSize",
                 "Value"      => Ref("ASGMin")
               },
               {
                 "Namespace"  => "aws:autoscaling:asg",
                 "OptionName" => "MaxSize",
                 "Value"      => Ref("ASGMax")
               },
               {
                 "Namespace"  => "aws:autoscaling:launchconfiguration",
                 "OptionName" => "EC2KeyName",
                 "Value"      => Ref("KeyName")
               },
               {
                 "Namespace"  => "aws:elasticbeanstalk:environment",
                 "OptionName" => "EnvironmentType",
                 "Value"      => "LoadBalanced"
               },
               {
                 "Namespace"  => "aws:elb:loadbalancer",
                 "OptionName" => "CrossZone",
                 "Value"      => "true"
               },
               {
                 "Namespace"  => "aws:elasticbeanstalk:environment",
                 "OptionName" => "LoadBalancerType",
                 "Value"      => "application"
               }
             ])
    Property("SolutionStackName", Ref("SolutionStackName"))
  end

  Resource("BeanstalkEnvironment") do
    Type("AWS::ElasticBeanstalk::Environment")
    Property("ApplicationName", Ref("BeanstalkApplication"))
    Property("Description", "AWS Elastic Beanstalk Environment")
    Property("EnvironmentName", Ref("EnvironmentName") )
    Property("TemplateName", "DefaultConfiguration")
    Property("Tier", {
               "Name" => "WebServer",
               "Type" => "Standard"
               })
  end
end
