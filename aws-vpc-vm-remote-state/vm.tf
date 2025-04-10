# ssh-keygen -f aws-vm-key    
resource "aws_key_pair" "vm_key" {
    key_name = "aws-vm-key"
    public_key = file("./aws-vm-key.pub")
}

resource "aws_instance" "aws_vm" {
  ami                     = "ami-0d1ddd83282187d18"
  instance_type           = "t2.micro"
  key_name = aws_key_pair.vm_key.key_name
  subnet_id = data.terraform_remote_state.vpc_remote_state.outputs.subnet_id
  vpc_security_group_ids = data.terraform_remote_state.vpc_remote_state.outputs.vpc_security_group_ids
  associate_public_ip_address = true

  tags = {
    Name = "vm-terraform"
  }
}