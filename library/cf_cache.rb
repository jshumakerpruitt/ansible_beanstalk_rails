CloudFormation do
  Description("")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("AppServerSecurityGroup") do
    Description("Id of App Server SecurityGroup")
  end

  Parameter("PrivateSubnet1") do
    Description("Privates subnet in which to launch cluster")
  end

  Parameter("PrivateSubnet2") do
    Description("Privates subnet in which to launch cluster")
  end

  Parameter("ClusterNodeType") do
    Description("")
    Type("String")
    Default("cache.t1.micro")
    AllowedValues([
                    "cache.t1.micro",
                    "cache.m1.small",
                    "cache.m1.medium",
                    "cache.m1.large",
                    "cache.m1.xlarge",
                    "cache.m2.xlarge",
                    "cache.m2.2xlarge",
                    "cache.m2.4xlarge",
                    "cache.m3.xlarge",
                    "cache.m3.2xlarge",
                    "cache.c1.xlarge"

                  ])
    ConstraintDescription("must select a valid Cache Node type.")
  end

  Resource("CacheSubnetGroup") do
    Type("AWS::ElastiCache::SubnetGroup")
    Property("Description","Subnets in which to launch cluster")
    Property("SubnetIds", [Ref("PrivateSubnet1"), Ref("PrivateSubnet2")] )
  end

=begin
  Resource("RedisClusterSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("Description", "Allow access from app servers to cluster")
    Property("VpcId", Ref("VpcId"))
    Property("SecurityGroupIngress",
             [{
                IpProtocol: "tcp",
                FromPort: "22",
                ToPort: "22",
                SourceSecurityGroupId: "0.0.0.0/0"
              }])
  end
=end

  Resource("RedisCluster") do
    Type("AWS::ElastiCache::CacheCluster")
    Property("CacheSubnetGroupName", Ref("CacheSubnetGroup"))
    Property("CacheNodeType", Ref("ClusterNodeType"))
    Property("VpcSecurityGroupIds", [ Ref("AppServerSecurityGroup") ])
    Property("Engine", "redis")
    Property("NumCacheNodes", "1")
  end

end
