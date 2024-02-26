"""An AWS Python Pulumi program"""

from os import environ
import pulumi_awsx as awsx
import pulumi_aws as aws
import pulumi

pu_vpc = awsx.ec2.Vpc("pu-vpc",
    cidr_block="10.63.0.0/16",
    instance_tenancy="default",
    number_of_availability_zones=1,
    nat_gateways=awsx.ec2.NatGatewayConfigurationArgs(
        strategy=awsx.ec2.NatGatewayStrategy.NONE,
    ),
    subnet_strategy='AUTO',
    subnet_specs=[
        awsx.ec2.SubnetSpecArgs(
            name="subnet",
            type=awsx.ec2.SubnetType.PUBLIC,
            cidr_mask=24,
            tags={
                "Name": "pu-vpc",
                "Author": "Ernest",
                "Purpose": "IAC-demo"
            }
        )
    ],
    tags={
        "Name": "pu-vpc",
        "Author": "Ernest",
        "Purpose": "IAC-demo"
    }
)

pu_sg1 = aws.ec2.SecurityGroup("pu-sg1",
    description="Allow inbound ssh and http traffic",
    vpc_id=pu_vpc.vpc_id,
    tags={
        "Name": "pu-sg1",
        "Author": "Ernest",
        "Purpose": "IAC-demo"
    }
)

pu_sg1_in_ssh = aws.vpc.SecurityGroupIngressRule("pu-sg1-in-ssh",
    security_group_id=pu_sg1.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=22,
    to_port=22,
    ip_protocol="tcp"
)

pu_sg1_in_http = aws.vpc.SecurityGroupIngressRule("pu-sg1-in-http",
    security_group_id=pu_sg1.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=80,
    to_port=80,
    ip_protocol="tcp"
)

pu_sg1_out_all = aws.vpc.SecurityGroupEgressRule("pu-sg1-out-all",
    security_group_id=pu_sg1.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=0,
    to_port=0,
    ip_protocol="-1"
)

pu_instance1_nic = aws.ec2.NetworkInterface("pu-instance1-nic",
    subnet_id=pu_vpc.public_subnet_ids[0],
    security_groups=[pu_sg1.id]
)

file = open(environ.get('HOME') + "/.ssh/id_ed25519.pub", "r", encoding="utf-8")
public_key = file.read()
file.close()

pu_keypair = aws.ec2.KeyPair("pu-keypair",
    public_key=public_key,
    tags={
        "Name": "pu-keypair",
        "Author": "Ernest",
        "Purpose": "IAC-demo"
    }
)

pu_instance1 = aws.ec2.Instance("pu-instance1",
    ami="ami-089c89a80285075f7",
    instance_type="t2.micro",
    network_interfaces=[
        aws.ec2.InstanceNetworkInterfaceArgs(
            network_interface_id=pu_instance1_nic.id,
            device_index=0,
        ),
    ],
    key_name=pu_keypair.key_name,
    user_data="""#!/bin/bash
sudo yum install -y docker
sudo systemctl enable docker --now
sudo docker run -d --name godutch -p 80:8080 -e LOVE=clogs pa3hcm/godutch:0.1""",
    tags={
        "Name": "pu-instance1",
        "Author": "Ernest",
        "Purpose": "IAC-demo"
    }
)

pu_eip1 = aws.ec2.Eip("pu-eip1",
    instance=pu_instance1.id,
    domain="vpc",
    tags={
        "Name": "pu-eip1",
        "Author": "Ernest",
        "Purpose": "IAC-demo"
    }
)

pulumi.export("public_ip", pu_eip1.public_ip)
