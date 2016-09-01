CloudFormation {
  Parameter 'KeyName' do
    Type 'AWS::EC2::KeyPair::KeyName'
    ConstraintDescription 'Must be a valid keyname'
  end

  Output 'KeyName' do
    Description 'EC2 Keyname to Access Bastion Host'
    Value Ref('KeyName')
  end

  #vpc
  EC2_VPC 'VPC' do
    EnableDnsSupport "true"
    EnableDnsHostnames "true"
    CidrBlock "10.0.0.0/16"
  end

  Output 'VPC' do
    Description 'VPC id'
    Value Ref('VPC')
  end

  #vpc routing
  EC2_RouteTable "PublicRouteTable" do
    VpcId Ref("VPC")
    DependsOn 'VPC'
  end

  EC2_InternetGateway "InternetGateway" do
    DependsOn ['VPC', 'PublicRouteTable']
  end

  EC2_VPCGatewayAttachment 'VPCGatewayAttachment' do
    InternetGatewayId Ref("InternetGateway")
    VpcId Ref('VPC')
    DependsOn ['VPC', 'InternetGateway']
  end

  EC2_Route "PublicRoute" do
    DestinationCidrBlock "0.0.0.0/0"
    RouteTableId Ref("PublicRouteTable")
    GatewayId Ref("InternetGateway")
    DependsOn ["VPCGatewayAttachment",
               "InternetGateway",
               "PublicRouteTable"]
  end

  Resource("SecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("VpcId", Ref("VPC"))
    Property("GroupDescription", "App Server Security Group")
    Property("SecurityGroupIngress",
             [{
                IpProtocol: "tcp",
                FromPort: "22",
                ToPort: "22",
                CidrIp: "10.0.0.0/16"
              },{
                IpProtocol: "tcp",
                FromPort: "5432",
                ToPort: "5432",
                CidrIp: "10.0.0.0/16"
              },{
                IpProtocol: "tcp",
                FromPort: "80",
                ToPort: "80",
                CidrIp: "10.0.0.0/16"
              },{
                IpProtocol: "tcp",
                FromPort: "6379",
                ToPort: "6379",
                CidrIp: "10.0.0.0/16"
              }])
  end

  Output 'SecurityGroupId' do
    Description 'Main VPC Security Group id'
    Value Ref('SecurityGroup')
  end

  #private subnet 1b
  #ec2 instances go here
  EC2_Subnet "PrivateSubnet1b" do
    AvailabilityZone 'us-east-1b'
    VpcId Ref("VPC")
    CidrBlock "10.0.0.0/24"
  end

  Output 'PrivateSubnet1b' do
    Description 'Private EC2 Instance Subnet 1'
    Value Ref('PrivateSubnet1b')
  end

  EC2_RouteTable "PrivateRouteTable1b" do
    VpcId Ref("VPC")
  end

  EC2_SubnetRouteTableAssociation "PrivateSubnetRouteTableAssociation1b" do
    RouteTableId Ref("PrivateRouteTable1b")
    SubnetId Ref("PrivateSubnet1b")
  end

  EC2_Route "PrivateRoute1b" do
    DestinationCidrBlock "0.0.0.0/0"
    RouteTableId Ref("PrivateRouteTable1b")
    NatGatewayId Ref("NatGateway1b")
    DependsOn ["NatGateway1b",
               "PrivateRouteTable1b"]
  end


  #public subnet 1b
  #load balancers and NAT go here
  EC2_Subnet "PublicSubnet1b" do
    AvailabilityZone 'us-east-1b'
    VpcId Ref("VPC")
    CidrBlock "10.0.1.0/24"
  end

  Output 'PublicSubnet1b' do
    Description 'Public ELB Subnet 1'
    Value Ref('PublicSubnet1b')
  end

  EC2_EIP 'NatEip1b' do
    Domain 'VPC'
  end

  EC2_NatGateway 'NatGateway1b' do
    AllocationId FnGetAtt('NatEip1b', 'AllocationId')
    SubnetId Ref("PublicSubnet1b")
  end

  EC2_SubnetRouteTableAssociation "PublicSubnetRouteTableAssociation1b" do
    RouteTableId Ref("PublicRouteTable")
    SubnetId Ref("PublicSubnet1b")
  end

  #private subnet 1c
  #ec2 instances go here
  EC2_Subnet "PrivateSubnet1c" do
    AvailabilityZone 'us-east-1c'
    VpcId Ref("VPC")
    CidrBlock "10.0.2.0/24"
  end

  Output 'PrivateSubnet1c' do
    Description 'Private EC2 Instance Subnet 2'
    Value Ref('PrivateSubnet1c')
  end

  EC2_RouteTable "PrivateRouteTable1c" do
    VpcId Ref("VPC")
  end

  EC2_SubnetRouteTableAssociation "PrivateSubnetRouteTableAssociation1c" do
    RouteTableId Ref("PrivateRouteTable1c")
    SubnetId Ref("PrivateSubnet1c")
  end

  EC2_Route "PrivateRoute1c" do
    DestinationCidrBlock "0.0.0.0/0"
    RouteTableId Ref("PrivateRouteTable1c")
    NatGatewayId Ref("NatGateway1c")
    DependsOn ["NatGateway1c",
               "PrivateRouteTable1c"]
  end

  #public subnet 1c
  #load balancers and NAT go here
  EC2_Subnet "PublicSubnet1c" do
    AvailabilityZone 'us-east-1c'
    VpcId Ref("VPC")
    CidrBlock "10.0.3.0/24"
  end

  Output 'PublicSubnet1c' do
    Description 'Public EC2 Instance Subnet 2'
    Value Ref('PublicSubnet1c')
  end

  EC2_EIP 'NatEip1c' do
    Domain 'VPC'
  end

  EC2_NatGateway 'NatGateway1c' do
    AllocationId FnGetAtt('NatEip1c', 'AllocationId')
    SubnetId Ref("PublicSubnet1c")
  end

  EC2_SubnetRouteTableAssociation "PublicSubnetRouteTableAssociation1c" do
    RouteTableId Ref("PublicRouteTable")
    SubnetId Ref("PublicSubnet1c")
  end

  #bastion host
  EC2_EIP 'BastionHostEIP' do
    Domain 'VPC'
  end

  Output 'BastionHostEIP' do
    Description 'Bastion Host IP Address'
    Value Ref('BastionHostEIP')
  end

  EC2_Instance 'BastionHost' do
    SubnetId Ref('PublicSubnet1b')
    SecurityGroupIds [Ref("BastionSecurityGroup")]
    KeyName Ref('KeyName')
    ImageId "ami-6869aa05"
    InstanceType 't2.micro'
  end

  EC2_EIPAssociation 'BastionHostEIPAssociation' do
    AllocationId FnGetAtt('BastionHostEIP', 'AllocationId')
    InstanceId Ref('BastionHost')
    DependsOn ['BastionHostEIP', 'BastionHost']
  end

  EC2_SecurityGroup "BastionSecurityGroup" do
    VpcId Ref("VPC")
    GroupDescription "Allow SSH traffic to bastion host"
    SecurityGroupIngress IpProtocol: "tcp",
                         FromPort: "22",
                         ToPort: "22",
                         CidrIp: "0.0.0.0/0"

    SecurityGroupEgress IpProtocol: "tcp",
                        FromPort: "22",
                        ToPort: "22",
                        CidrIp: "0.0.0.0/0"
  end
}
