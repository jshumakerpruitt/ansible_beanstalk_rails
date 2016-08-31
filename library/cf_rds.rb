CloudFormation do
  Description("AWS CloudFormation Sample Template VPC_RDS_DB_Instance: Sample template showing how to create an RDS DBInstance in an existing Virtual Private Cloud (VPC). **WARNING** This template creates an Amazon Relational Database Service database instance. You will be billed for the AWS resources used if you create a stack from this template.")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("VPCId") do
    Description("VPCId of your existing Virtual Private Cloud (VPC)")
    Type("String")
  end

  Parameter "AppServerSecurityGroupId" do
    Description "App server security group id"
    Type "String"
  end

  Parameter("Subnets") do
    Description("The list of SubnetIds, for at least two Availability Zones in the region in your Virtual Private Cloud (VPC)")
    Type("CommaDelimitedList")
  end

  Parameter("DBName") do
    Description("The database name")
    Type("String")
    Default("MyDatabase")
    AllowedPattern("[a-zA-Z][a-zA-Z0-9]*")
    MaxLength(64)
    MinLength(1)
    ConstraintDescription("must begin with a letter and contain only alphanumeric characters.")
  end

  Parameter("DBUsername") do
    Description("The database admin account username")
    Type("String")
    Default("admin")
    AllowedPattern("[a-zA-Z][a-zA-Z0-9]*")
    NoEcho(true)
    MaxLength(16)
    MinLength(1)
    ConstraintDescription("must begin with a letter and contain only alphanumeric characters.")
  end

  Parameter("DBPassword") do
    Description("The database admin account password")
    Type("String")
    Default("password")
    AllowedPattern("[a-zA-Z0-9]*")
    NoEcho(true)
    MaxLength(41)
    MinLength(8)
    ConstraintDescription("must contain only alphanumeric characters.")
  end

  Parameter("Engine") do
    Description("DB Engine")
    Type("String")
    Default("postgres")
    AllowedValues([
                    "MySQL",
                    "aurora",
                    "mariadb",
                    "oracle-ee",
                    "oracle-se",
                    "oracle-se1",
                    "postgres",
                    "sqlserver-ee",
                    "sqlserver-ex",
                    "sqlserver-se",
                    "sqlserver-web"
                  ])
  end

  Parameter("EngineVersion") do
    Description("Engine Version")
    Type("String")
    Default("9.5.2")
  end

  Parameter("DBClass") do
    Description("Database instance class")
    Type("String")
    Default("db.t2.micro")
    AllowedValues([
                    "db.m1.large",
                    "db.m1.medium",
                    "db.m1.small",
                    "db.m1.xlarge",
                    "db.m2.2xlarge",
                    "db.m2.4xlarge",
                    "db.m2.xlarge",
                    "db.m3.2xlarge",
                    "db.m3.large",
                    "db.m3.medium",
                    "db.m3.xlarge",
                    "db.m4.10xlarge",
                    "db.m4.2xlarge",
                    "db.m4.4xlarge",
                    "db.m4.large",
                    "db.m4.xlarge",
                    "db.r3.2xlarge",
                    "db.r3.4xlarge",
                    "db.r3.8xlarge",
                    "db.r3.large",
                    "db.r3.xlarge",
                    "db.t1.micro",
                    "db.t2.large",
                    "db.t2.medium",
                    "db.t2.micro",
                    "db.t2.small"
                  ])
    ConstraintDescription("must select a valid database instance type.")
  end

  Parameter("DBAllocatedStorage") do
    Description("The size of the database (Gb)")
    Type("Number")
    Default("5")
    MaxValue(1024)
    MinValue(5)
    ConstraintDescription("must be between 5 and 1024Gb.")
  end

  Resource("MyDBSubnetGroup") do
    Type("AWS::RDS::DBSubnetGroup")
    Property("DBSubnetGroupDescription", "Subnets available for the RDS DB Instance")
    Property("SubnetIds", Ref("Subnets"))
  end

  EC2_SecurityGroup "DBSecurityGroup" do
    GroupDescription "Security group for RDS DB Instance."
    VpcId Ref("VPCId")
    SecurityGroupIngress IpProtocol: "tcp",
                         FromPort: "5432",
                         ToPort: "5432",
                         SourceSecurityGroupId: Ref("AppServerSecurityGroupId")

    SecurityGroupEgress IpProtocol: "tcp",
                        FromPort: "5432",
                        ToPort: "5432",
                        CidrIp: "0.0.0.0/0"
  end

  Resource("MyDB") do
    Type("AWS::RDS::DBInstance")
    Property("DBName", Ref("DBName"))
    Property("AllocatedStorage", Ref("DBAllocatedStorage"))
    Property("DBInstanceClass", Ref("DBClass"))
    Property("Engine", Ref("Engine"))
    Property("EngineVersion", Ref("EngineVersion"))
    Property("MasterUsername", Ref("DBUsername"))
    Property("MasterUserPassword", Ref("DBPassword"))
    Property("DBSubnetGroupName", Ref("MyDBSubnetGroup"))
    Property("MultiAZ", "false")
    Property("VPCSecurityGroups", [
               Ref("DBSecurityGroup")
             ])
  end

  Output("DBPortNumber") do
    Description("PortNumber")
    Value(FnGetAtt("MyDB", "Endpoint.Address"))
  end

  Output("DBUsername") do
    Description("DBUsername")
    Value(Ref("DBUsername"))
  end

  Output("DBPassword") do
    Description("DBPassword")
    Value(Ref("DBPassword"))
  end
end
