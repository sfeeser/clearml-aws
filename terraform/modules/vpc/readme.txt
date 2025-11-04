                                           ┌──────────────────────────────────┐                                        
                                           │ AWS EIP (Fixed IP)               │                                        
                                           │ resource "aws_eip" "nat"         │                                        
                                           └──────────────────────────────────┘                                        
    ┌───────────────────────────┐                           |                                                          
    │  Other Amazon Services    │          ┌──────────────────────────────────┐                                        
    │                           │          │ NAT Gateway (Outbound Router)    │                                        
    └───────────────────────────┘          │ resource "aws_nat_gateway" "nat" │                                        
      ▲                                    │ allocation_id = aws_eip.nat.id   │                                        
      │                                    └──────────────────────────────────┘                                        
      │                                                    ▲                                                           
      │                                                    │                                                           
┌─────┼────────────────────────────────────────────────────┼──────────────────────┐                                    
│     │                  VPC (CIDR: 10.0.0.0/16)           │                      │                                    
│     │                  resource "aws_vpc" "main"         │                      │                                    
│     │                  AZ-A                              │                      │                                    
│     │                                                    │                      │                                    
│ ┌───┴─────────────────────────────────────┐              │                      │                                    
│ │ Internet Gateway (IGW)                  │              │                      │                                    
│ │ resource─"aws_internet_gateway" "igw"   │              │                      │                                    
│ │ vpc_id = aws_vpc.main.id                │              │                      │                                    
│ └──▲──────────────────────────────────────┘              │                      │                                    
│    │                                                     │                      │                                    
│    │                                                     │                      │                                    
│ ┌──┴───────────────────────────────┐    ┌────────────────┴────────────────────┐ │                                    
│ │ Public Subnet (VLAN 1)           │    │ Private Subnet (VLAN 2)             │ │                                    
│ │ CIDR: 10.0.1.0/24                │    │ CIDR: 10.0.2.0/24                   │ │                                    
│ │ vpc_id = aws_vpc.main.id         │    │ vpc_id = aws_vpc.main.id            │ │                                    
│ │ resource "aws_subnet" "public_a  │    │ resource "aws_subnet" "private_a"   │ │                                    
│ │                                " │    │                                     │ │                                    
│ │ - IGW route                      │    │ - NAT Gateway Route (Outbound)      │ │                                    
│ │ - Load Balancers                 │    │ - EKS Worker Nodes (Secure)         │ │                                    
│ │ - NAT Gateway                    │    │ - ClearML Pods (Application ID)     │ │                                    
│ └──────────────────────────────────┘    └─────────────────────────────────────┘ │                                    
│    ▲                                                                       ▲    │                                    
│    │                                                                       │    │                                    
│    │                                                                       │    │                                    
│    │                                                                       │    │                                    
│    │    ┌─────────────────────────────────────────────────────────────┐    │    │                                    
│    │    │                                                             │    │    │                                    
│    │    │           Public Route Table                                │    │    │                                    
│    │    │           resource "aws_route_table" "public"               │    │    │                                    
│    │    │                                                             │    │    │                                    
│    │    │                                                             │    │    │                                    
│    │    │                                                             │    │    │                                    
│    └─── │  # Route table for Public Subnets                           │    │    │                                    
│         │  resource "aws_route_table" "public" {                      │    │    │                                    
│         │    vpc_id = aws_vpc.main.id                                 │    │    │                                    
│         │    route {                                                  │    │    │                                    
│         │      cidr_block = "0.0.0.0/0"                               │    │    │                                    
│         │      gateway_id = aws_internet_gateway.igw.id               │    │    │                                    
│         │    }                                                        │    │    │                                    
│         │  }                                                          │    │    │                                    
│         │  resource "aws_route_table_association" "public" {          │    │    │                                    
│         │    subnet_id      = aws_subnet.public_a.id                  │    │    │                                   ─
│         │    route_table_id = aws_route_table.public.id               │    │    │                                    
│         │  }                                                          │    │    │                                    
│         │                                                             │    │    │                                    
│         │    ──────────────────────────────────────────────           │    │    │                                    
│         │    ──────────────────────────────────────────────           │    │    │                                    
│         │                                                             │    │    │                                    
│         │  # Route table for Private Subnets (traffic goes via NAT)   │────┘    │                                    
│         │  resource "aws_route_table" "private" {                     │         │                                    
│         │    vpc_id = aws_vpc.main.id                                 │         │                                    
│         │    route {                                                  │         │                                    
│         │      cidr_block     = "0.0.0.0/0"                           │         │                                    
│         │      nat_gateway_id = aws_nat_gateway.nat.id                │         │                                    
│         │    }                                                        │         │                                    
│         │  }                                                          │         │                                    
│         │  resource "aws_route_table_association" "private" {         │         │                                    
│         │    subnet_id      = aws_subnet.private_a.id                 │         │                                    
│         │    route_table_id = aws_route_table.private.id              │         │                                    
│         │  }                                                          │         │                                    
│         │                                                             │         │                                    
│         └─────────────────────────────────────────────────────────────┘         │                                    
│                                                                                 │                                    
└─────────────────────────────────────────────────────────────────────────────────┘                                    
