# Grupo IAM para EC2
resource "aws_iam_group" "ec2_admin_group" {
  name = "EC2AdminGroup"
}

# Anexar políticas ao grupo
resource "aws_iam_group_policy_attachment" "ec2_full_access" {
  group      = aws_iam_group.ec2_admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "vpc_full_access" {
  group      = aws_iam_group.ec2_admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_group_policy_attachment" "ec2_instance_connect" {
  group      = aws_iam_group.ec2_admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceConnect"
}

# Usuário IAM
resource "aws_iam_user" "ec2_user" {
  name = "ec2-user"
}

resource "aws_iam_user_group_membership" "ec2_user_membership" {
  user = aws_iam_user.ec2_user.name
  groups = [aws_iam_group.ec2_admin_group.name]
}

resource "aws_iam_access_key" "ec2_user_key" {
  user = aws_iam_user.ec2_user.name
}

# VPC
resource "aws_vpc" "wordpress_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "wordpress_subnet" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true  # Garante IP público
  availability_zone = var.availability_zone

  tags = {
    Name = "Wordpress-Subnet"
  }
}

resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "Wordpress-Internet-Gateway"
  }
}

resource "aws_route_table" "wordpress_route_table" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }

  tags = {
    Name = "Wordpress-Route-Table"
  }
}

resource "aws_route_table_association" "wordpress_route_table_assoc" {
  subnet_id      = aws_subnet.wordpress_subnet.id
  route_table_id = aws_route_table.wordpress_route_table.id
}

# Grupo de Segurança
resource "aws_security_group" "wordpress_sg" {
  vpc_id = aws_vpc.wordpress_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# Instância EC2 com WordPress e Apache
resource "aws_instance" "wordpress_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.wordpress_subnet.id
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  associate_public_ip_address = true  # Garante que a instância tenha um IP público

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 mysql-server php libapache2-mod-php php-mysql -y

              # Iniciando serviços
              systemctl start apache2
              systemctl enable apache2
              systemctl start mysql
              systemctl enable mysql

              # Criando banco de dados WordPress
              mysql -e "CREATE DATABASE wordpress;"
              mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';"
              mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';"
              mysql -e "FLUSH PRIVILEGES;"

              # Instalando o WordPress
              wget https://wordpress.org/latest.tar.gz
              tar -xvzf latest.tar.gz
              mv wordpress /var/www/html/wordpress

              # Configurando o WordPress
              cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
              sed -i "s/database_name_here/wordpress/" /var/www/html/wordpress/wp-config.php
              sed -i "s/username_here/wp_user/" /var/www/html/wordpress/wp-config.php
              sed -i "s/password_here/wp_password/" /var/www/html/wordpress/wp-config.php

              # Página personalizada
              mkdir -p /var/www/html/politicas
              echo '<!DOCTYPE html>
              <html lang="pt-BR">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Políticas para Mulheres - S.O.S Vitória</title>
                  <style>
                      body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f4f4f4; }
                      header { background-color: #e91e63; color: #fff; padding: 20px; text-align: center; }
                      section { margin: 20px; padding: 20px; background-color: #fff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); }
                      h1, h2, h3 { color: #333; }
                      p { margin: 10px 0; }
                      footer { text-align: center; padding: 20px; background-color: #333; color: #fff; margin-top: 20px; }
                  </style>
              </head>
              <body>
                  <header>
                      <h1>Políticas para Mulheres - S.O.S Vitória</h1>
                  </header>
                  <section>
                      <h2>Introdução</h2>
                      <p>As políticas públicas voltadas para a proteção e segurança das mulheres são fundamentais para garantir seus direitos e combater a violência de gênero. Infelizmente, os casos de violência contra mulheres continuam sendo uma realidade alarmante no Brasil e no mundo.</p>
                  </section>
                  <section>
                      <h2>Casos de Violência contra Mulheres</h2>
                      <p>Um dos casos mais trágicos que ganhou repercussão nacional foi o caso Vitória, em que uma mulher foi brutalmente assassinada em uma situação de violência doméstica. Casos como esse reforçam a urgência de políticas eficazes e medidas preventivas.</p>
                  </section>
                  <section>
                      <h2>O Aplicativo S.O.S Vitória</h2>
                      <p>O aplicativo S.O.S Vitória surge como uma solução inovadora e acessível para proporcionar mais segurança às mulheres em situação de risco. A ideia central é permitir que a polícia receba a localização da vítima e monitore em tempo real, oferecendo uma resposta rápida e eficiente.</p>
                      <h3>Funcionalidades do App</h3>
                      <ul>
                          <li>Botão de Pânico: Acionamento rápido e discreto em situações de perigo.</li>
                          <li>Envio de Localização: Envio automático da localização da vítima para a polícia.</li>
                          <li>Monitoramento em Tempo Real: Acompanhamento contínuo da localização.</li>
                          <li>Contato com Redes de Apoio: Acesso rápido a contatos de emergência e centros de apoio.</li>
                          <li>Histórico de Chamadas de Emergência: Registro das ocorrências para acompanhamento.</li>
                      </ul>
                  </section>
                  <footer>
                      <p>&copy; 2025 S.O.S Vitória - Todos os direitos reservados.</p>
                  </footer>
              </body>
              </html>' > /var/www/html/politicas/index.html

              # Permissões
              chown -R www-data:www-data /var/www/html
              chmod -R 755 /var/www/html

              # Reiniciando Apache
              systemctl restart apache2
              EOF

  tags = {
    Name = "Wordpress-VM"
  }
}
