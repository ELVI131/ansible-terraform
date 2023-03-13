# Update Ansible inventory
resource "local_file" "ansible_host" {
    depends_on = [
      aws_instance.k8s
    ]
    content     = "ansible!"
    filename    = "inventory"
}

# Run Ansible playbook
resource "null_resource" "null1" {
    depends_on = [
      local_file.ansible_host
    ]
 
  provisioner "local-exec" {
    command = "ansible-playbook playbook.yml"
    }
}

