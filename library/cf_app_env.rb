CloudFormation do
  Description("Template to create EB App+Env")
  AWSTemplateFormatVersion("2010-09-09")

  Resource("BeanstalkApplication") do
    Type("AWS::ElasticBeanstalk::Application")
    Property("ApplicationName", "BeanstalkApplication") 
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
                 "Value"      => "2"
               },
               {
                 "Namespace"  => "aws:autoscaling:asg",
                 "OptionName" => "MaxSize",
                 "Value"      => "6"
               },
               {
                 "Namespace"  => "aws:elasticbeanstalk:environment",
                 "OptionName" => "EnvironmentType",
                 "Value"      => "LoadBalanced"
               }
             ])
    Property("SolutionStackName", "64bit Amazon Linux running PHP 5.3")
  end

  Resource("BeanstalkEnvironment") do
    Type("AWS::ElasticBeanstalk::Environment")
    Property("ApplicationName", Ref("BeanstalkApplication"))
    Property("Description", "AWS Elastic Beanstalk Environment")
    Property("TemplateName", "DefaultConfiguration")
    Property("VersionLabel", "Initial Version")
  end
end
