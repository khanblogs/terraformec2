provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA2GMHYTV4OJLOM754"
  secret_key = "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"
}

#creating security group, allow ssh and http
resource  "aws_security_group" "tello-tf" {
	  name = "tello-tf"
	  description = "allowing ssh and http traffic"

  	 ingress {
		 from_port = 22
		 to_port = 22
		 protocol = "tcp"
		 cidr_blocks = ["0.0.0.0/0"]
	}

         ingress {
		 from_port = 80
		 to_port = 80
		 protocol = "tcp"
		 cidr_blocks = ["0.0.0.0/0"]
	}

         egress {
   		from_port = 0
 		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]

         }

}

#security group ends now

#creating aws db instance



resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "wordpress"
  username               = "admin"
  password               = "redhat"
  parameter_group_name   = "default.mysql5.7"
  #vpc_security_group_ids = [aws_security_group.mysql.id]
  #db_subnet_group_name   = aws_db_subnet_group.mysql.name
  skip_final_snapshot    = true
}
#check the configuration inside the ec2

#creating aws ec2 instance

resource "aws_instance" "bhao" {
  ami  = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.tello-tf.name}"]
  key_name = "tf"
  user_data = <<-EOF
	 #! /bin/bash
	sudo yum install httpd -y 
	sudo systemctl start httpd
	sudo systemctl enable httpd
	sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
 	sudo yum install -y httpd mariadb-server
        sudo systemctl is-enabled httpd
	sudo systemctl start mariadb
	sudo systemctl enable mariadb
	firewall-cmd --permanent --zone=public --add-service=http
        firewall-cmd --permanent --zone=public --add-service=https
        firewall-cmd --reload
	curl https://wordpress.org/latest.tar.gz --output wordpress.tar.gz
	tar xf wordpress.tar.gz
	#cp -r wordpress /var/www/html
	#chown -R apache:apache /var/www/html/wordpress
	#chcon -t httpd_sys_rw_content_t /var/www/html/wordpress -R
	systemctl start php-fpm.service
	systemctl enable php-fpm.service
	#mysql -u root -p
	#CREATE USER 'admin'@'localhost' IDENTIFIED BY 'redhat';
	#CREATE DATABASE `wordpress`;
	#GRANT ALL PRIVILEGES ON `wordpress`.* TO "admin"@"localhost";
	#FLUSH PRIVILEGES;
	#exit
        cp -r wordpress/* /var/www/html/
	cp /wordpress/wp-config-sample.php /wordpress/wp-config.php
	sudo chown -R apache /var/www
	sudo chgrp -R apache /var/www
	sudo chmod 2775 /var/www
	find /var/www -type d -exec sudo chmod 2775 {} \;
	sudo systemctl enable httpd && sudo systemctl enable mariadb
	sudo systemctl restart mariadb
	sudo systemctl restart httpd
	sudo systemctl enable httpd	
	sudo systemctl enable mariadb


  EOF

  tags = {
    Name = "Bhao"
  }


} 

#vim /wordpress/config.php and put the same deatils configured with the sql and recheck the created sql db
#createdbyshahrukh
#launching ec2 with apache,wp,mysql installed using with terraform..

