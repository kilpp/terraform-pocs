output "vm_ip" {
    description = "VM public IP"
    value = aws_instance.aws_vm.public_ip
  
}