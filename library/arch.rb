CloudFormation {
  Parameter 'KeyName' do
    Type 'AWS::EC2::KeyPair::KeyName'
    ConstraintDescription 'Must be a valid keyname'
  end

  Parameter 'AvailabilityZoneA' do
    Description 'Must be a valid Availability Zone'
    Type 'String'
  end

  Parameter 'AvailabilityZoneB' do
    Description 'Must be a valid Availability Zone'
    Type 'String'
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

  #private subnet A
  #ec2 instances go here
  EC2_Subnet "PrivateSubnetA" do
    AvailabilityZone Ref('AvailabilityZoneA')
    VpcId Ref("VPC")
    CidrBlock "10.0.0.0/24"
  end

  Output 'PrivateSubnetA' do
    Description 'Private EC2 Instance Subnet 1'
    Value Ref('PrivateSubnetA')
  end

  EC2_RouteTable "PrivateRouteTableA" do
    VpcId Ref("VPC")
  end

  EC2_SubnetRouteTableAssociation "PrivateSubnetRouteTableAssociationA" do
    RouteTableId Ref("PrivateRouteTableA")
    SubnetId Ref("PrivateSubnetA")
  end

  EC2_Route "PrivateRouteA" do
    DestinationCidrBlock "0.0.0.0/0"
    RouteTableId Ref("PrivateRouteTableA")
    NatGatewayId Ref("NatGatewayA")
    DependsOn ["NatGatewayA",
               "PrivateRouteTableA"]
  end


  #public subnet A
  #load balancers and NAT go here
  EC2_Subnet "PublicSubnetA" do
    AvailabilityZone Ref('AvailabilityZoneA')
    VpcId Ref("VPC")
    CidrBlock "10.0.1.0/24"
  end

  Output 'PublicSubnetA' do
    Description 'Public ELB Subnet 1'
    Value Ref('PublicSubnetA')
  end

  EC2_EIP 'NatEipA' do
    Domain 'VPC'
  end

  EC2_NatGateway 'NatGatewayA' do
    AllocationId FnGetAtt('NatEipA', 'AllocationId')
    SubnetId Ref("PublicSubnetA")
  end

  EC2_SubnetRouteTableAssociation "PublicSubnetRouteTableAssociationA" do
    RouteTableId Ref("PublicRouteTable")
    SubnetId Ref("PublicSubnetA")
  end

  #private subnet B
  #ec2 instances go here
  EC2_Subnet "PrivateSubnetB" do
    AvailabilityZone Ref('AvailabilityZoneB')
    VpcId Ref("VPC")
    CidrBlock "10.0.2.0/24"
  end

  Output 'PrivateSubnetB' do
    Description 'Private EC2 Instance Subnet 2'
    Value Ref('PrivateSubnetB')
  end

  EC2_RouteTable "PrivateRouteTableB" do
    VpcId Ref("VPC")
  end

  EC2_SubnetRouteTableAssociation "PrivateSubnetRouteTableAssociationB" do
    RouteTableId Ref("PrivateRouteTableB")
    SubnetId Ref("PrivateSubnetB")
  end

  EC2_Route "PrivateRouteB" do
    DestinationCidrBlock "0.0.0.0/0"
    RouteTableId Ref("PrivateRouteTableB")
    NatGatewayId Ref("NatGatewayB")
    DependsOn ["NatGatewayB",
               "PrivateRouteTableB"]
  end

  #public subnet B
  #load balancers and NAT go here
  EC2_Subnet "PublicSubnetB" do
    AvailabilityZone Ref('AvailabilityZoneB')
    VpcId Ref("VPC")
    CidrBlock "10.0.3.0/24"
  end

  Output 'PublicSubnetB' do
    Description 'Public EC2 Instance Subnet 2'
    Value Ref('PublicSubnetB')
  end

  EC2_EIP 'NatEipB' do
    Domain 'VPC'
  end

  EC2_NatGateway 'NatGatewayB' do
    AllocationId FnGetAtt('NatEipB', 'AllocationId')
    SubnetId Ref("PublicSubnetB")
  end

  EC2_SubnetRouteTableAssociation "PublicSubnetRouteTableAssociationB" do
    RouteTableId Ref("PublicRouteTable")
    SubnetId Ref("PublicSubnetB")
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
    SubnetId Ref('PublicSubnetA')
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
