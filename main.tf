resource "aws_security_group" "devsecops_monitoring_tools_sg" {
  name        = "DevSecOps-Monitoring-Tools-SG"
  description = "Open 22,443,80,9100,9090,3000"


  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 443, 9100, 9090, 3000] : {
      description      = "DevSecOps Monitoring Tools SG"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "devsecops_monitoring_tools-sg"
    Env  = "dev"
  }
}

data "template_file" "prometheus_grafana" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    grafana = file("${path.module}/grafana.sh")
    prometheus = file("${path.module}/prometheus.sh")
  }
}

resource "aws_instance" "prometheus_grafana" {
  ami                    = "ami-04f167a56786e4b09" # Ubuntu 20.04
  instance_type          = "t2.micro"
  key_name               = "VM-KP"
  vpc_security_group_ids = [aws_security_group.devsecops_monitoring_tools_sg.id]
  user_data     = data.template_file.prometheus_grafana.rendered
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "Prometheus-Grafana"
    Env  = "dev"
  }

}

data "template_file" "node_exporter" {
  template = file("${path.module}/Node-Exporter/user_data.tpl")

  vars = {
    node_exporter = file("${path.module}/Node-Exporter/node_exporter.sh")
    start_node_exporter = file("${path.module}/Node-Exporter/start_node_exporter.sh")  

  }
}

resource "aws_instance" "node_exporter" {
  ami                    = "ami-04f167a56786e4b09" # Ubuntu 20.04
  instance_type          = "t2.micro"
  key_name               = "VM-KP"
  vpc_security_group_ids = [aws_security_group.devsecops_monitoring_tools_sg.id]
  user_data     = data.template_file.node_exporter.rendered
  
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "Node-Exporter-Server"
    Env  = "dev"
  }

}