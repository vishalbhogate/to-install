package main

default deny = false

deny {
 input.Type == "AWS::EC2::SecurityGroup"
 port := input.Properties.SecurityGroupIngress.CidrIpTlvMap[_].FromPort
 not (port == 20 or port == 21 or port == 22 or port == 23 or port == 161 or port == 3389)
}
