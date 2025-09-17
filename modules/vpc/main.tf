# aws_vpc.this
# Crea una Virtual Private Cloud (VPC) que es una red virtual dedicada a tu cuenta de AWS.
# Sirve como el “contenedor” de todos los recursos de red (subnets, gateways, etc.).
# Habilita soporte y hostnames DNS para permitir resolución interna de nombres y acceso a servicios AWS por nombre.
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

# aws_internet_gateway.this
# Crea un Internet Gateway, que es un componente que permite que los recursos dentro de la VPC (por ejemplo, instancias EC2 en subnets públicas) tengan acceso a Internet.
# El IGW se asocia a la VPC y es indispensable para la comunicación entrante/saliente entre la VPC y el exterior.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-igw"
  }
}

# aws_subnet.public
# Crea dos subnets públicas dentro de la VPC.
# Cada subnet representa un rango de direcciones IP dentro del bloque CIDR de la VPC, asociada a una zona de disponibilidad específica.
# Al habilitar map_public_ip_on_launch, las instancias lanzadas aquí recibirán una IP pública automáticamente, permitiendo acceso directo a/desde Internet (si la tabla de ruteo lo permite).
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true # Asigna IP pública automáticamente a las instancias
  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}

# aws_subnet.private
# Crea dos subnets privadas dentro de la VPC.
# Estas subnets no asignan IPs públicas automáticamente a las instancias lanzadas, y normalmente no tienen acceso directo a Internet.
# Son ideales para recursos internos (bases de datos, servidores backend, etc.).
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr) // Número de subnets privadas a crear
  vpc_id            = aws_vpc.this.id               // ID de la VPC donde se crearán las subnets
  cidr_block        = var.private_subnets_cidr[count.index] // Bloque CIDR específico para cada subnet privada
  availability_zone = element(var.azs, count.index) // Asigna una zona de disponibilidad basada en el índice
  map_public_ip_on_launch = false // No asigna IP pública automáticamente a las instancias
  tags = {
    Name = "${var.name}-private-${count.index + 1}" // Nombre amigable para la subnet
  }
}

# aws_route_table.public
# Crea una tabla de ruteo que define cómo el tráfico se dirige dentro de la VPC.
# Esta tabla será usada por las subnets públicas para asegurar que el tráfico destinado fuera de la VPC se dirija al Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-public-rt"
  }
}

# aws_route.public_internet_access
# Agrega una ruta en la tabla de ruteo pública para que todo el tráfico cuyo destino sea fuera de la VPC (0.0.0.0/0) se envíe al Internet Gateway.
# Es lo que realmente permite que las subnets públicas tengan acceso a Internet.
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # Todo el tráfico IPv4
  gateway_id             = aws_internet_gateway.this.id
}

# aws_route_table_association.public
# Asocia cada subnet pública a la tabla de ruteo pública.
# Esto vincula explícitamente la subnet con la ruta de salida a Internet (a través del IGW).
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ----------- BLOQUES PARA ACCESO A INTERNET DESDE SUBNETS PRIVADAS -----------

# Elastic IP para el NAT Gateway (necesaria para que el NAT tenga una IP pública)
resource "aws_eip" "nat" {
  tags = {
    Name = "${var.name}-nat-eip"
  }
}

# NAT Gateway en la primera subnet pública
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.name}-nat-gw"
  }
  depends_on = [aws_internet_gateway.this]
}

# Tabla de ruteo privada para las subnets privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-private-rt"
  }
}

# Ruta de salida a Internet en la tabla privada usando el NAT Gateway
resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Asociación de cada subnet privada con la tabla de ruteo privada
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}