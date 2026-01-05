# EKS

## Node Groups

### Remote Access

Note regarding ssh_key, please provide the ssh public key that you wish to use
as a variable "authorized_ssh_key".  One may be generated using ssh-keygen

1. Generate the key pair

```
ssh-keygen -M pem /path/my-key-pair.pem
```

1. Import the key pair
```
aws ec2 import-key-pair \
    --key-name my-key-pair \
    --public-key-material fileb://path/my-key-pair.pem.pub
```
1. Verify keypair and obtain arn
```
aws ec2 describe-key-pairs --key-names my-key-pair
```
1. And add the key pair name to terraform.tfvars
```
node_ssh_key_name = "my-key-pair"
```
1. Create a security group for EKS Nodes to allow port 22/tcp from.
```
aws ec2 create-security-group --group-name "mybastion-sshaccess"  --description "Node Group SSH access" --vpc-id "VPC of bastion host"
```
1. Add source IP of bastion host to From of ingress rule
``
aws ec2 authorize-security-group-ingress --group-id "sg-#############" --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{Description=\"Bastion Source IP\",CidrIp=10.42.16.105/32}]"
```
