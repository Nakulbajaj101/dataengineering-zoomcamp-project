data "template_file" "startup" {
 template = file("prefect-agent.sh")
}

resource "aws_instance" "compute_instance" {
    ami = "ami-0a695f0d95cefc163"
    instance_type = var.instance_type
    security_groups = [ "default" ]
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.id
    tags = {
      "Name" = "prefect-agent"
    }
    key_name = aws_key_pair.compute_instance_key_pair.key_name
    user_data = data.template_file.startup.rendered
}


resource "tls_private_key" "compute_instance_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "compute_instance_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.compute_instance_private_key.public_key_openssh
}


resource "aws_ebs_volume" "compute_volume" {
    availability_zone = aws_instance.compute_instance.availability_zone
    size = 30
    type = "gp2"
}

resource "aws_volume_attachment" "ebs_attach" {
    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.compute_volume.id
    instance_id = aws_instance.compute_instance.id
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:us-east-2:135015496169:secret:prefect-api-key-pYaB71"
      },
      {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:List*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_policy_attachment" "ssm_policy" {
  name       = "ssm-policy-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


