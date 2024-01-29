package opa_cdk

import input 

# deny if to_port is not in the given range
deny_invalid_ports[deny] {                             
    ports := {"20", "21", "22", "23", "161", "3389"}
    input.Resources[_].Properties.SecurityGroupIngress[_].ToPort == p
    not contains(ports, p)
    deny := true
}


package main

default deny = false

deny {
 input.Type == "AWS::EC2::SecurityGroup"
 port := input.Properties.SecurityGroupIngress.CidrIpTlvMap[_].FromPort
 not (port == 20 or port == 21 or port == 22 or port == 23 or port == 161 or port == 3389)
}


package main

deny {
    input.Resources.Type == "AWS::EC2::SecurityGroup"
    not any_allowed_ports(input.Resources.Properties.SecurityGroupIngress)
}

any_allowed_ports([_]) {
    index := {20, 21, 22, 23, 161, 3389}
    count([_, _], input) >= 1
    input[_] == index[_]
}
