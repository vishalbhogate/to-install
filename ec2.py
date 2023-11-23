import boto3
import time

# Create a session using your AWS credentials
session = boto3.Session(
    aws_access_key_id='YOUR_ACCESS_KEY',
    aws_secret_access_key='YOUR_SECRET_KEY',
    region_name='us-west-2'  # or your preferred region
)

# Create a client for SSM
ssm = session.client('ssm')

# Define the command to get the OS version
command = 'cat /etc/system-release'

# Get the list of all instances
ec2 = session.resource('ec2')
instances = ec2.instances.all()

# Run the command on each instance
for instance in instances:
    response = ssm.send_command(
        InstanceIds=[instance.id],
        DocumentName="AWS-RunShellScript",
        Parameters={'commands': [command]},
    )

    command_id = response['Command']['CommandId']

    # Wait for the command to execute
    time.sleep(1)

    # Get the command output
    output = ssm.get_command_invocation(
        CommandId=command_id,
        InstanceId=instance.id,
    )

    if 'Amazon Linux release 2' in output['StandardOutputContent']:
        print(f'Instance {instance.id} is running Amazon Linux 2')
    elif 'Amazon Linux AMI release 2018.03' in output['StandardOutputContent']:
        print(f'Instance {instance.id} is running Amazon Linux 1')
