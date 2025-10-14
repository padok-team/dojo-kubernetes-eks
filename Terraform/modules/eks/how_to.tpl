- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

🚀 Here are the steps to connect to your EKS cluster using SSM


1️⃣  Update your kube config

AWS_PROFILE=${env} aws eks update-kubeconfig --region ${region} --name ${cluster_name}


2️⃣  Override the HTTPS port to go through the SSM tunnel

kubectl config set clusters.${cluster_arn}.server https://${cluster_endpoint}:10443


3️⃣  Update your local host file to go through the SSM tunnel to connect your EKS

sudo bash -c "echo 127.0.0.1 ${cluster_endpoint} >> /etc/hosts"


4️⃣  Start your SSM tunnel

AWS_PROFILE=${env} aws ssm start-session --region ${region} --target $(AWS_PROFILE=${env} aws ec2 describe-instances --region ${region} --filters 'Name=tag:Name,Values=bastion-ssm-*' 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[InstanceId]' --output text) --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["${cluster_endpoint}"],"portNumber":["443"], "localPortNumber":["10443"]}'


5️⃣  Query your cluster \o/

kubectl get pods -A
