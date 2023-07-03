import json
import boto3
#connects to QS via boto3 connection
quicksight = boto3.client('quicksight')
account_number = ''
namespace = 'default'
return_message = []

#registers a new user within AWS enviorment 
def register_user(User_email, qs_role, IAM_role, return_message):
    try:
        response = quicksight.register_user(
            IdentityType='IAM',
            Email=User_email,
            UserRole=qs_role,
            IamArn=f'arn:aws:iam::{account_number}:role/{IAM_role}',
            SessionName=User_email,
            AwsAccountId=account_number,
            Namespace=namespace)
        return_message.append('user succesfully created')
    except:
        return_message.append('user creation has failed')
        print("user already exists attempting adding them to another group")
    

 #deletes user from AWS enviorment           
def delete_user (user_name, return_message):
    try:
        response = quicksight.delete_user(
            Username=user_name,
            AwsAccountId=account_number,
            Namespace=namespace)
        return_message.append('user succesfully deleted')
    except:
        return_message.append('user deletion has failed')

#adds an existing user to a QS group
def add_user_to_group(user_name, group_name, return_message):
    try:
        response = quicksight.create_group_membership(
            MemberName=user_name,
            GroupName=group_name,
            AwsAccountId=account_number,
            Namespace=namespace)
        return_message.append('user successfully added to group')
    except:
        return_message.append('user failed to be moved into another group')
        
 #removes an existing member from a QS Group       
def remove_user_membership(user_name, group_name, return_message):
    try:
        response = quicksight.delete_group_membership(
            MemberName=user_name,
            GroupName=group_name,
            AwsAccountId=account_number,
            Namespace=namespace)
        return_message.append('user successfully removed from group')
    except:
        return_message.append('user failed to be removed from group')
#main function 

def lambda_handler(event, context):
    qs_role = event['qs_role']
    IAM_role = event['IAM_role']
    User_email = event['User_email']
    user_name = str(IAM_role+'/'+User_email)
    group_name = event['group_name']
    action = event['action']
    if action == 'create':
        register_user(User_email, qs_role, IAM_role, return_message)
        add_user_to_group(user_name, group_name, return_message)
    elif action == 'delete':
        delete_user(user_name, return_message)
        print('user deletion has worked')
    return return_message
