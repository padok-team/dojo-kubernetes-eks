import boto3
import datetime

from botocore.config import Config

my_config = Config(
    region_name = 'eu-west-3',
)

def lambda_handler(event, context):
    
    end_period   = int(datetime.datetime.now().timestamp())
    start_period = end_period - 604800 - 3600 # 604800 = number of second in a week
    end_period   = end_period * 1000
    start_period = start_period * 1000
    
    client     = boto3.client("sts")
    account_id = client.get_caller_identity()["Account"]
    
    client = boto3.client("guardduty",region_name="eu-west-3")

    response = client.list_detectors()

    if len(response["DetectorIds"]) == 0:
        print("[-] Error no detector found in this account")
        exit(1)
    elif len(response["DetectorIds"]) != 1:
        print("[-] Error more than one detector found in this account")
        exit(1)

    detector_id = response["DetectorIds"][0]

    response = client.list_findings(
        DetectorId = detector_id,
        FindingCriteria = {
            'Criterion': {
                'updatedAt': {
                    'GreaterThanOrEqual': start_period
                }
            }
        },
        SortCriteria={
            'AttributeName': 'updatedAt',
            'OrderBy': 'DESC'
        },
        MaxResults = 50
    )

    next_token = response["NextToken"]
    finding_ids = response["FindingIds"]

    while (next_token):
        response = client.list_findings(
            DetectorId = detector_id,
            FindingCriteria = {
                'Criterion': {
                    'updatedAt': {
                        'GreaterThanOrEqual': start_period
                    }
                }
            },
            SortCriteria={
                'AttributeName': 'updatedAt',
                'OrderBy': 'DESC'
            },
            MaxResults = 50,
            NextToken = next_token
        )

        next_token = response["NextToken"]
        finding_ids += response["FindingIds"]

    if not finding_ids:
        exit(1)

    findings_details = []

    for i in range(0, len(finding_ids), 50):
        response = client.get_findings(
            DetectorId   = detector_id,
            FindingIds   = finding_ids[i:i+50],
            SortCriteria = {
                'AttributeName': 'updatedAt',
                'OrderBy': 'DESC'
            }
        )
        
        findings_details += response["Findings"]


    message_body = """
    AWS weekly report

    Guard Duty alerts :
    """

    for finding in findings_details:
        if finding["Severity"] <= 3:
            severity = "low"
        elif finding["Severity"] <= 6:
            severity = "medium"
        else:
            severity = "HIGH"

        message_body += """
    AWS {} has a severity {} GuardDuty finding type {} in the {} region."
    Finding Description: {}
    https://console.aws.amazon.com/guardduty/home?region={}#/findings?search=id%3D{}

    """.format(
        finding["AccountId"],
        severity,
        finding["Type"],
        finding["Region"],
        finding["Description"],
        finding["Region"],
        finding["Id"],
    )

    client = boto3.client("sns", region_name="eu-west-3")
    response = client.publish(
        TopicArn = "arn:aws:sns:eu-west-3:{}:guard-duty-exporter".format(account_id),
        Message  = message_body,
        Subject  = "Guard Duty Weekly reports",
    )
