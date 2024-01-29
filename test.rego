package wiz

import future.keywords.in

to_arr(str) = arr {
	is_string(str)
	arr = [str]
}

to_arr(str) = arr {
	is_array(str)
	arr = str
}

obj_to_arr(obj) = [{k: v} | some k, v in obj]

#check if an ec2 sg has inline egress configured
inlineEgressCheck(resource) {
	sgInlineEgress = to_arr(object.get(resource.Properties, "SecurityGroupEgress", []))
	count(sgInlineEgress) > 0
}

#check if an ec2 sg has egress resources configured assiciating with that ec2 sg
egressResourceCheck(resourceName, sgeResources) {
	sgeResource := sgeResources[_]
	groupId = object.get(sgeResource[_].Properties, "GroupId", "")
	print(groupId)
	groupId == sprintf("!GetAtt %v.GroupId", [resourceName])
} else {
	sgeResource := sgeResources[_]
	groupId = obj_to_arr(object.get(sgeResource[_].Properties, "GroupId", {"": ""}))
	{"Fn::GetAtt": [resourceName, "GroupId"]} in groupId
}

#check if an management port use as ingress destination port
invalidPortIngressInlineCheck(resource){
	sgInlineIngress = to_arr(object.get(resource.Properties, "SecurityGroupIngress", []))
	count(sgInlineIngress) > 0
	ports = {"20", "21", "22", "23", "161", "3389"}
	sg := resource[_]
	rule := sg.Properties.SecurityGroupIngress[_]
	ports[rule.ToPort]
}

#if no any types of egress configured, the sg will be an invalid sg
#invalidSecurityGroupCheck(sgResource, resourceName, sgeResources, sgiResources) {
#	not inlineEgressCheck(sgResource)
#	not egressResourceCheck(resourceName, sgeResources)
#}

invalidSecurityGroupCheck(sgResource, resourceName, sgeResources, sgiResources) {
	not invalidPortIngressInlineCheck(sgResource)
	#not invalidPortIngressResourceCheck(resourceName, sgiResources)
}

#output invlaid sg results
WizPolicy[finalResult] {
	docs := input
	resources := docs.Resources

	invalidSecurityGroup := [resourceName |
		sgResources := [{resourceName: resource} |
			some resourceName, resource in resources
			resource.Type == "AWS::EC2::SecurityGroup"
		]

		sgeResources := [{resourceName: resource} |
			some resourceName, resource in resources
			resource.Type == "AWS::EC2::SecurityGroupEgress"
		]

		sgiResources := [{resourceName: resource} |
			some resourceName, resource in resources
			resource.Type == "AWS::EC2::SecurityGroupIngress"
		]

		sgResource := sgResources[_][resourceName]

		invalidSecurityGroupCheck(sgResource, resourceName, sgeResources, sgiResources)
	]

	count(invalidSecurityGroup) > 0

	rst := {result |
		rcsName := invalidSecurityGroup[_]

		result := {
			"documentId": docs.AWSTemplateFormatVersion,
			"resourceName": sprintf("%v", [rcsName]),
			"issueType": "IncorrectValue",
			"searchKey": sprintf("%s", [rcsName]),
			"keyExpectedValue": sprintf("To qualify for PR auto-approval, please add egress on this Security Group: %v", [rcsName]),
			"keyActualValue": sprintf("Unrecognised Security Groups detected in these Resources: %v", [invalidSecurityGroup]),
			"invalidSecurityGroup": sprintf("These Security Groups have no egress configured so that the PR cannot be auto-approved: %v", [invalidSecurityGroup]),
		}
	}

	finalResult := rst[_]
}
