provider "aws"{
  Region = "eu-west-2"
}

resource "aws_security_group" "instance" {
  name = "terraform-security-groups"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami = "ami-0a669382ea0feb73a"
  instance_type = "t2.micro"
  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum -y install docker
	          sudo systemctl enable docker
                  sudo systemctl start docker
                  docker pull httpd
		  docker run -itd --name myapacheserver -p 80:80 httpd
		  docker run -itd --name myapacheserverbackup -p 8080:80 httpd                  
                  #yum -y install httpd
                  #echo "<p> Hello Capgemini! </p>" >> /var/www/html/index.html
                  #sudo systemctl enable httpd
                  #sudo systemctl start httpd
                  EOF
  associate_public_ip_address = "true"
  key_name = "demokey"
  vpc_security_group_ids = [aws_security_group.instance.id]
}
