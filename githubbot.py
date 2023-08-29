import json
import boto3
import os
from collections import namedtuple

def m(n, d):
    return namedtuple(n, d.keys())(*d.values())
    

class MatchEvent:
    def __init__(self, overrides={}):
        vars={**os.environ, **overrides}
        self.aws = m("aws",{
            "sqs" : boto3.Session('sqs',region_name='ap-southeast-2')
        })

    def supress(self,event):

        if event["action"] == "created":
            messageBody = json.dumps(event)
            queueUrl = vars.queueUrl

            self.aws.sqs.send_message(
                QueueUrl=queueUrl,
                MessageBody=messageBody
            )
            

    def filterEvent(self, event):
        self.suppress(event)
    

