ssm_client = session.client('ssm')

response = ssm_client.describe_instance_information(
   InstanceInformationFilterList=[
       {
           'key': 'InstanceIds',
           'valueSet': [
               'INSTANCE_ID',
           ]
       },
   ]
)

if response['InstanceInformationList']:
   print("SSM is enabled for the instance.")
else:
   print("SSM is not enabled for the instance.")
