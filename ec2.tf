

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_ssm_parameter" "cloud_agent" {

  name        = "jenkins"
  description = "Value for the aws cloudwatch agent on jenkins agents"
  type        = "String"
  tier        = "Standard"
  data_type   = "text"
  value       = file("./cloudwatch-config.json")
  tags        = {}
}

resource "aws_instance" "jenkinsinstance" {
  count         = 2
  ami           = "ami-002068ed284fb165b" #data.aws_ami.example.id TODO ami-002068ed284fb165b
  monitoring = true
  instance_type = var.instance-type
  # iam_instance_profile = "Jenkins_agents_admin_role"
  subnet_id              = aws_subnet.fleur-public-subnet[0].id
  vpc_security_group_ids = [aws_security_group.fleur-public-security-group.id]
  key_name               = var.keypair
  user_data = base64encode(
    templatefile("${path.cwd}/template.tpl",
      {
        vars = []
    })
  )
  root_block_device {

    volume_size = var.vol_size
  }
  # provisioner local-exec {
  #   command = templatefile("${path.cwd}/template.tpl",
  #     {
  #       vars = []
  #   })
  # }
  tags = {
    Name = var.jenkins-tags[count.index]
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      user_data,

    ]
  }
}


resource "aws_instance" "SonarQubesinstance" {
  ami                    = "ami-002068ed284fb165b" #data.aws_ami.example.id TODO
  instance_type          = var.instance-type
  subnet_id              = aws_subnet.fleur-public-subnet[0].id
  vpc_security_group_ids = [aws_security_group.fleur-public-security-group.id]
  key_name               = var.keypair
  user_data = base64encode(
    templatefile("${path.cwd}/sonar.tpl",
      {
        vars = []
    })
  )
  root_block_device {
    volume_size = var.vol_size
  }
  tags = {}
}


