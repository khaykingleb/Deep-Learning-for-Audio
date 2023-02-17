resource "aws_key_pair" "this" {
  public_key      = chomp(tls_private_key.ssh.public_key_openssh)
  key_name_prefix = local.full_project_name

  tags = merge({ name = "DLA-SSH-Key" }, local.tags)
}

resource "aws_ebs_volume" "this" {
  availability_zone = local.availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = merge({ name = "DLA-EBS" }, local.tags)
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.this.id
  instance_id = aws_instance.this.id
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id       = aws_subnet.this.id
  security_groups = [aws_security_group.this.id]

  key_name = aws_key_pair.this.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  user_data = file(abspath("${path.cwd}/../../scripts/${var.user_data_script_name}.sh"))

  tags = merge({ name = "DLA-EC2" }, local.tags)
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  vpc      = true
}
