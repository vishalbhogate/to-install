package opa_cdk

import input 

# deny if to_port is not in the given range
deny_invalid_ports[deny] {                             
    ports := {"20", "21", "22", "23", "161", "3389"}
    input.Resources[_].Properties.SecurityGroupIngress[_].ToPort == p
    not contains(ports, p)
    deny := true
}
