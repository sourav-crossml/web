resource "aws_instance" "ec2-prod" {
    ami = "ami-0f19d220602031aed"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh.key_name
    vpc_security_group_ids = [aws_security_group.prov_fw.id]
    tags = {
      name = "blog"
    }
  
}

resource "aws_key_pair" "ssh" {
key_name=file("~/your_key_name.pem") ##please input path to your private key
public_key = "your public key"
}

resource "aws_security_group" "prov_fw" {
name = "blog"
ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "prov_null" {
  triggers = {
    public_ip = aws_instance.ec2-prod.public_ip
  }

connection {
type = "ssh"
host = aws_instance.ec2-blog.public_ip
private_key = file("~/your_key_name.pem") ##please input path to your private key
user = "ec2-user"
timeout = "1m"
}

  provisioner "remote-exec" {
    inline = ["sudo yum -y update", "sudo yum install -y httpd", "sudo service httpd start", "echo '<!doctype html><html><body><h1>CONGRATS!!..You have configured successfully your remote exec provisioner!</h1></body></html>' | sudo tee /var/www/html/index.html"]
  }

}