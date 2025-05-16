import json
import boto3
import os
import datetime
# Clients
ses = boto3.client('ses')
sts = boto3.client('sts')
# Account list
ACCOUNTS = {
    "590183957203": "management",
    "976193220746": "data",
    "381492150796": "infra",
    "730335386746": "iva",
    "381492049355": "logs",
    "730335639457": "opr",
    "975050075035": "network",
    "034362069573": "pqs",
    "390402578610": "prod",
    "430118816674": "subordinateca"
}
ses_sender_email = os.getenv('SES_SENDER_EMAIL', "").split(",")
ses_recipient_email = os.getenv('SES_SENDER_EMAIL',"").split(",")
current_time = datetime.datetime.utcnow()
# Assuming role Terragrunter in all accounts.
def assume_role(account_id):
    role_arn = f"arn:aws:iam::{account_id}:role/terragrunter"
    response = sts.assume_role(RoleArn=role_arn, RoleSessionName="IAMCompliancecheck")
    credentials = response['Credentials']
    return  boto3.Session(
                        aws_access_key_id=credentials['AccessKeyId'],
                        aws_secret_access_key=credentials['SecretAccessKey'],
                        aws_session_token=credentials['SessionToken'])
# Getting Access Key age using Iam client.
def get_access_key_age(iam_client, username):
    try:
        response = iam_client.list_access_keys(UserName=username)
        if not response['AccessKeyMetadata']:
            return None
        from datetime import datetime, timezone
        now = datetime.now(timezone.utc)
        oldest_key = response['AccessKeyMetadata'][0]['CreateDate']
        key_age_days = (now - oldest_key).days
        return key_age_days
    except Exception as e:
        return None
# Getting UserPassword Age using Iam Client.
def get_password_age(iam_client, username):
    try:
        response = iam_client.get_user(UserName=username)
        if "PasswordLastUsed" in response['User']:
            password_age_days = (current_time - response['User']['PasswordLastUsed'].replace(tzinfo=None)).days
            return password_age_days
        return "N/A"
    except Exception as e:
        return None
# Filters for security hub
def fetch_findings(securityhub_client):
    FILTERS = {
       "ProductName": [{"Value": "Security Hub", "Comparison": "EQUALS"}],
       "ResourceType": [{"Value": "AwsIamUser", "Comparison": "EQUALS"}],
       "RecordState": [{"Value": "ACTIVE", "Comparison": "EQUALS"}],
       "Title": [{"Value": "IAM users' access keys should be rotated every 90 days or less", "Comparison": "EQUALS"}]
    }
    try:
        return securityhub_client.get_findings(Filters=FILTERS, MaxResults=100).get('Findings', [])
    except Exception as e:
        print(f"error fetchings")
        return[]
# HTML Table format   
def generate_html_report(compliant_users, non_compliant_users):                      
    html_body = f"""
      <html>
      <body>
          <h2>IAM User Compliance Report Alerts </h2>
      """
    if compliant_users and non_compliant_users:
        html_body += "<p><strong>Report From All Accounts:</strong></p>"
    elif compliant_users:
        html_body += "<p><strong>Report From All Accounts:</strong></p>"
    elif non_compliant_users:
        html_body += "<p><strong>Report From All Accounts:</strong></p>"
    else:
        html_body += "<p><strong>No IAM USERS Found.</strong></p>"

    if compliant_users:
        html_body += """
        <html>
        <body>
           
            <!-- Message outside the box (above the tables) -->
            <p><strong>Access Keys for users are less than 90 days and User Password Age less than 90 days.</strong></p> 
            <table border='1' cellspacing='0' cellpadding='5'>
                <tr>
                    <th style="background-color: #cce5ff;">Account Name</th>
                    <th style="background-color: #cce5ff;">Account ID</th>
                    <th style="background-color: #cce5ff;">IAM User</th>
                    <th style="background-color: #cce5ff;">AgeDays</th>
                    <th style="background-color: #cce5ff;">Compliance Status</th>
                    <th style="background-color: #cce5ff;">User Password Age</th>
                </tr>
        """
        for user in compliant_users:
            html_body += f"""
            <tr>
                <td>{user['AccountName']}</td>
                <td>{user['AccountId']}</td>
                <td>{user['Username']}</td>
                <td>{user['AgeDays']}</td>
                <td style="background-color: #d4edda;">{user['ComplianceStatus']}</td>
                <td>{user['PasswordAgeDays']}</td>
            </tr>
            """
        html_body += "</table><br><br></body></html>"
    if non_compliant_users:
        html_body += f"""
          <html>
          <body>
              <p><strong>Access Keys for users are more than 90 days and User Password Age more than 90 days.</strong></p>  
              <table border='1' cellspacing='0' cellpadding='5'>
                  <tr>
                      <th style="background-color: #ffecb3;">Account Name</th>
                      <th style="background-color: #ffecb3;">Account ID</th>
                      <th style="background-color: #ffecb3;">IAM User</th>
                      <th style="background-color: #ffecb3;">AgeDays</th>
                      <th style="background-color: #ffecb3;">Compliance Status</th>
                      <th style="background-color: #ffecb3;">User Password Age</th>
                  </tr>
          """            
        for user in non_compliant_users:
            html_body += f"""            
            <tr>
                <td>{user['AccountName']}</td>
                <td>{user['AccountId']}</td>
                <td>{user['Username']}</td>
                <td>{user['AgeDays']}</td>
                <td style="background-color: #f8d7da;">{user['ComplianceStatus']}</td>
                <td>{user['PasswordAgeDays']}</td>
            </tr>
            """
        html_body += "</table><br><br></body></html>"
 
    return html_body
# List users using Iam Client
def list_users(iam_client):
    users = []
    paginator = iam_client.get_paginator('list_users')
    for page in paginator.paginate():
        users.extend(page['Users'])
    return users
# Main function
def lambda_handler(event, context):
    compliant_users = []
    non_compliant_users = []  
    for account_id, account_name in ACCOUNTS.items():
        session = assume_role(account_id)
        iam_client = session.client('iam')
        securityhub = session.client('securityhub')
        findings = fetch_findings(securityhub)
        # Fetching User details from Security Hub
        if findings:         
            for finding in findings:
                for resource in finding.get('Resources', []):
                    if resource.get('Type') == 'AwsIamUser':
                        username = resource.get('Details', {}).get('AwsIamUser', {}).get('UserName')
                        compliance_status = finding.get('Compliance', {}).get('Status', 'UNKNOWN')
                        validate_user_id = finding.get('AwsAccountId')
                        key_age_days = get_access_key_age(iam_client, username)
                        password_age_days = get_password_age(iam_client, username)
                        if account_id == validate_user_id:
                            user_data = {
                                    "Username": username,
                                    "AgeDays": key_age_days if key_age_days is not None else "No Access keys Found",
                                    "ComplianceStatus": compliance_status,
                                    "AccountId": account_id,
                                    "PasswordAgeDays": password_age_days if password_age_days is not None else "User Password Age not found",
                                    "AccountName": account_name
                            }
                            if compliance_status != "PASSED":
                                non_compliant_users.append(user_data)
                            else:
                                compliant_users.append(user_data)
        else:
            # Fetch if no security hub findings found.
            sts_client = session.client('sts')
            validate_user_id = sts_client.get_caller_identity()['Account']
            for user in list_users(iam_client):
                username = user['UserName']
                key_age_days = get_access_key_age(iam_client, username)
                password_age_days = get_password_age(iam_client, username)
                
                if (key_age_days is None and password_age_days is not None and password_age_days >= 90) or \
                         (key_age_days is not None and key_age_days >= 90) or \
                         (password_age_days is not None and password_age_days >= 90):
                    compliance_status = "FAILED"
                else:
                    compliance_status = "PASSED"
                if account_id == validate_user_id:
                    user_data = {
                            "Username": username,
                            "AgeDays": key_age_days if key_age_days is not None else "No Access Keys Found",
                            "ComplianceStatus": compliance_status,
                            "AccountId": account_id,
                            "PasswordAgeDays": password_age_days if password_age_days is not None else "User Password Age not found",
                            "AccountName": account_name
                    }
                    if compliance_status != "PASSED":
                        non_compliant_users.append(user_data)
                    else:
                        compliant_users.append(user_data)              
    html_body = generate_html_report(compliant_users, non_compliant_users)
    subject = "IAM Users Compliance Report Access Key Rotation & User Password Age"
    # Send Email via SES
    ses.send_email(
        Source=ses_sender_email,
        Destination={"ToAddresses": [ses_recipient_email]},
        Message={
            "Subject": {"Data": subject},
            "Body": {"Html": {"Data": html_body}}
        }
    )                                       

    return {"message": "IAM User compliance check completed."}