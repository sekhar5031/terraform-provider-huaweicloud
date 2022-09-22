A Virtual Private Cloud (VPC), within Huawei Singapore Region
4 different subnets within the same VPC across two different Availability Zone (AZs)
A route for internal and external (Internet) routing purposes.
A NAT Gateway (self-managed) should be accessible by all cloud instances to the Internet for system patching purposes.
4 different Elastic Cloud Service (ECS)
An Elastic Load Balancer (ELB) to accept HTTPS on port 443.
A Security Group (SG) to enable accessing Web and SSH traffic from outside.