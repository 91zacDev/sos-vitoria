variable "aws_region" {
  description = "Região da AWS"
  default     = "us-east-2"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da chave SSH para acessar a instância"
  type        = string
}

variable "availability_zone" {
  description = "Zona de disponibilidade onde a instância será criada"
  default     = "us-east-2a"
}

variable "ami_id" {
  description = "ID da imagem AMI usada para criar a instância"
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
}


