# Critical Scanning - Sistema de Monitoreo Inteligente en AWS

## Descripción General

**Critical Scanning** es una solución completa de infraestructura como código (IaC) diseñada para implementar un sistema de monitoreo inteligente y automatizado en AWS. El proyecto utiliza Terraform para desplegar una arquitectura cloud que integra servicios de computación, redes seguras, gestión de identidades y monitoreo avanzado.

La solución está diseñada para proporcionar visibilidad completa sobre el estado de las instancias EC2, con capacidades de alertamiento inteligente que permiten respuestas proactivas ante anomalías o problemas de rendimiento.

## Arquitectura del Sistema

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS Cloud                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                  │  │
│  │                                                       │  │
│  │  ┌──────────────────┐    ┌──────────────────┐         │  │
│  │  │  Public Subnet   │    │  Private Subnet  │         │  │
│  │  │  (10.0.1.0/24)   │    │  (10.0.2.0/24)   │         │  │
│  │  │                  │    │                  │         │  │
│  │  │ ┌──────────────┐ │    │ ┌──────────────┐ │         │  │
│  │  │ │ NAT Gateway  │ │    │ │ EC2 Instance │ │         │  │
│  │  │ └──────────────┘ │    │ │  + Docker    │ │         │  │
│  │  │        ▲         │    │ └──────┬───────┘ │         │  │
│  │  │        │         │    │        │         │         │  │
│  │  └────────┼─────────┘    └────────┼─────────┘         │  │
│  │           │                       │                   │  │
│  │  ┌────────┴─────────┐             │                   │  │
│  │  │ Internet Gateway │             │                   │  │
│  │  └──────────────────┘             │                   │  │
│  └───────────────────────────────────┼───────────────────┘  │
│                                      │                      │
│  ┌───────────────────────────────────▼───────────────────┐  │
│  │              CloudWatch Monitoring                    │  │
│  │  • CPU Utilization    • Network I/O                   │  │
│  │  • Memory Usage       • Disk Performance              │  │
│  │  • Custom Metrics     • System Health                 │  │
│  └───────────────────────┬───────────────────────────────┘  │
│                          │                                  │
│  ┌───────────────────────▼───────────────────────────────┐  │
│  │              CloudWatch Alarms                        │  │
│  │  • Threshold-based triggers                           │  │
│  │  • Multi-metric evaluation                            │  │
│  │  • Automatic escalation                               │  │
│  └───────────────────────┬───────────────────────────────┘  │
│                          │                                  │
│  ┌───────────────────────▼───────────────────────────────┐  │
│  │         AWS Lambda Function                           │  │ 
│  │  • Event-driven execution                             │  │
│  │  • LLM-powered analysis                               │  │
│  │  • Intelligent diagnostics                            │  │
│  └───────────────────────┬───────────────────────────────┘  │
│                          │                                  │ 
└──────────────────────────┼──────────────────────────────────┘
                           │
                  ┌────────▼──────────┐
                  │  Slack Workspace  │
                  │  • Notifications  │
                  │  • AI Insights    │
                  │  • Actionable     │
                  │    Recommendations│
                  └───────────────────┘
```

### Flujo de Monitoreo Inteligente

1. **Recolección de Métricas**: CloudWatch recopila métricas en tiempo real de las instancias EC2
2. **Evaluación de Umbrales**: Las alarmas de CloudWatch evalúan continuamente las métricas contra umbrales predefinidos
3. **Activación de Eventos**: Cuando se detecta una anomalía, la alarma se activa
4. **Procesamiento Inteligente**: Lambda ejecuta un análisis utilizando un modelo de lenguaje (LLM) en Python
5. **Diagnóstico Automatizado**: El LLM analiza el contexto y genera hipótesis sobre la causa raíz
6. **Notificación Proactiva**: Se envía una alerta a Slack con análisis detallado y recomendaciones

## Módulos de Infraestructura

### 1. Módulo de Networking

Implementa una arquitectura de red segura y escalable:

- **VPC Dedicada**: Red virtual aislada (10.0.0.0/16)
- **Subnet Pública** (10.0.1.0/24):
  - Internet Gateway para conectividad externa
  - NAT Gateway para acceso saliente de recursos privados
  - Route Table configurada para tráfico público

- **Subnet Privada** (10.0.2.0/24):
  - Aloja las instancias EC2 de producción
  - Acceso a internet solo vía NAT Gateway
  - Aislamiento de seguridad para recursos críticos

**Archivos clave**:
- `modules/NETWORKING/vpc.tf` - Definición de VPC
- `modules/NETWORKING/public_subnets.tf` - Configuración de subnet pública
- `modules/NETWORKING/private_subnets.tf` - Configuración de subnet privada

### 2. Módulo de EC2

Gestiona las instancias de computación con configuración automatizada:

**Características**:
- **Instancia**: t2.micro con CPU credits ilimitados
- **AMI**: Ubuntu optimizada para AWS (ami-0f5fcdfbd140e4ab7)
- **Network Interface**: ENI dedicada con IP privada fija (10.0.2.10)
- **Bootstrapping**: Instalación automática de Docker mediante user_data
- **Monitoreo**: CloudWatch Agent integrado para métricas detalladas

**Configuración de Docker**:
El script `docker_base_installation.sh` configura:
- Usuario y grupo dedicado (`dockeruser`, `dockergrp`)
- Instalación completa de Docker Engine
- Docker Compose plugin
- Configuración de systemd para inicio automático

**Archivos clave**:
- `modules/EC2/ec2.tf` - Configuración de instancia
- `modules/EC2/docker_base_installation.sh` - Script de inicialización

### 3. Módulo de IAM

Implementa el principio de privilegio mínimo con políticas de seguridad robustas:

**Roles y Políticas**:

1. **Usuario de Testing**:
   - Usuario IAM: `testing-user-terraform`
   - Política MFA obligatoria (denegar todas las acciones sin MFA)
   - Acceso completo a EC2 con autenticación multifactor

2. **Rol de EC2**:
   - `ec2-ssm-role`: Rol asumible por instancias EC2
   - **AmazonSSMManagedInstanceCore**: Acceso a Systems Manager para gestión remota
   - **CloudWatchAgentServerPolicy**: Permiso para enviar métricas y logs a CloudWatch

3. **Instance Profile**:
   - `ec2-ssm-profile`: Asocia el rol a las instancias EC2

**Características de Seguridad**:
- Autenticación multifactor obligatoria
- Gestión remota segura vía AWS Systems Manager (sin necesidad de SSH)
- Publicación de métricas custom a CloudWatch
- Rotación automática de credenciales temporales

**Archivos clave**:
- `modules/IAM/Iam.tf` - Políticas y roles

## Sistema de Monitoreo y Alertas

### CloudWatch Integration

El sistema utiliza CloudWatch para monitoreo continuo:

**Métricas Monitoreadas**:
- Utilización de CPU
- Uso de memoria
- I/O de disco
- Tráfico de red
- Métricas custom de aplicaciones Docker

**CloudWatch Alarms**:
Las alarmas están configuradas para detectar:
- Picos de CPU sostenidos (>80% por 5 minutos)
- Agotamiento de memoria (>90%)
- Latencia de red elevada
- Errores de aplicación

### Lambda Function - Análisis Inteligente

**Tecnología**: Python con integración de LLM

**Funcionalidad**:
Cuando se activa una alarma de CloudWatch:

1. **Captura de Contexto**:
   - Recibe el evento de CloudWatch con detalles de la métrica
   - Obtiene datos históricos para análisis de tendencias
   - Recopila logs recientes de la instancia

2. **Análisis con LLM**:
   - Procesa el contexto utilizando un modelo de lenguaje
   - Genera hipótesis sobre la causa raíz del problema
   - Identifica patrones conocidos de fallos

3. **Generación de Recomendaciones**:
   - Sugiere acciones correctivas inmediatas
   - Proporciona comandos específicos cuando sea aplicable
   - Prioriza soluciones por impacto y facilidad de implementación

### Notificaciones en Slack

**Formato de Alertas**:
Las notificaciones incluyen:

```
ALERTA: Alto Uso de CPU en ec2_dev_instance

Métricas:
• CPU: 87.3%
• Duración: 6 minutos
• Umbral: 80%

Análisis AI:
"El pico de CPU puede estar relacionado con un proceso en contenedor
Docker. Basado en el patrón temporal, es probable que sea un job
programado que inició a las 14:00 UTC."

Recomendaciones:
1. Revisar contenedores activos: docker ps --format "{{.Names}}: {{.CPUPerc}}"
2. Verificar jobs de cron en los contenedores
3. Considerar escalar verticalmente si es recurrente

Acciones:
• Ver métricas en CloudWatch
• Conectar vía SSM Session Manager
```

## Prerequisitos

### Software Requerido

- **Terraform** >= 1.5.0
- **AWS CLI** >= 2.0
- **Cuenta de AWS** con permisos administrativos

### Configuración AWS

1. Configurar credenciales:
```bash
aws configure
```

2. Verificar acceso:
```bash
aws sts get-caller-identity
```

## Guía de Despliegue

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd Critical_Scanning
```

### 2. Configurar Variables

Editar `Terraform/variable_values.auto.tfvars`:

```hcl
region = "us-east-2"  # Ajustar según necesidad
```

### 3. Inicializar Terraform

```bash
cd Terraform
terraform init
```

Este comando:
- Descarga los providers necesarios (AWS)
- Inicializa el backend
- Configura módulos

### 4. Planificar el Despliegue

```bash
terraform plan
```

Revisar los recursos que se crearán:
- 1 VPC
- 2 Subnets (pública y privada)
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Elastic IP
- 1 Instancia EC2
- 3 Roles/Políticas IAM
- Tablas de rutas y asociaciones

### 5. Aplicar la Infraestructura

```bash
terraform apply
```

Confirmar con `yes` cuando se solicite.

**Tiempo estimado**: 3-5 minutos

### 6. Verificar el Despliegue

```bash
# Verificar instancia EC2
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=ec2_dev_instance" \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PrivateIpAddress]'

# Conectar vía SSM (sin necesidad de SSH)
aws ssm start-session --target <instance-id>

# Verificar Docker en la instancia
docker --version
docker ps
```

### 7. Configurar Monitoreo (Post-Despliegue)

Una vez desplegada la infraestructura base, el sistema de monitoreo inteligente se integra automáticamente:

1. **CloudWatch Alarms**: Configuradas para las métricas clave
2. **Lambda Function**: Desplegada y conectada a las alarmas
3. **Slack Webhook**: Integrado para notificaciones en tiempo real

## Estructura del Proyecto

```
Critical_Scanning/
├── README.md                          # Documentación principal
├── Terraform/
│   ├── main.tf                        # Orquestación de módulos
│   ├── providers.tf                   # Configuración de AWS provider
│   ├── variables.tf                   # Variables globales
│   ├── variable_values.auto.tfvars    # Valores de variables
│   │
│   └── modules/
│       ├── NETWORKING/
│       │   ├── vpc.tf                 # VPC principal
│       │   ├── public_subnets.tf      # Subnet pública + IGW
│       │   ├── private_subnets.tf     # Subnet privada + NAT
│       │   └── outputs.tf             # Outputs del módulo
│       │
│       ├── EC2/
│       │   ├── ec2.tf                 # Instancia y ENI
│       │   ├── variables.tf           # Variables del módulo
│       │   └── docker_base_installation.sh  # Bootstrapping
│       │
│       └── IAM/
│           ├── Iam.tf                 # Roles, políticas y users
│           └── outputs.tf             # Instance profile
```

## Gestión del Proyecto

### Comandos Útiles

**Ver estado actual**:
```bash
terraform show
```

**Actualizar infraestructura**:
```bash
terraform plan
terraform apply
```

**Destruir recursos**:
```bash
terraform destroy
```

**Formatear código**:
```bash
terraform fmt -recursive
```

**Validar configuración**:
```bash
terraform validate
```

### Conectividad a la Instancia

**Opción 1: AWS Systems Manager (Recomendado)**
```bash
# Listar instancias disponibles
aws ssm describe-instance-information

# Iniciar sesión interactiva
aws ssm start-session --target i-xxxxxxxxxxxxx

# Ejecutar comando remoto
aws ssm send-command \
  --instance-ids i-xxxxxxxxxxxxx \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["docker ps"]'
```

**Opción 2: SSH (Requiere configuración adicional de Security Group)**
```bash
ssh -i key.pem ubuntu@<instance-private-ip>
```

## Características de Seguridad

### Arquitectura de Red Segura

1. **Aislamiento de Capas**:
   - Instancias de producción en subnet privada
   - Sin acceso directo desde internet
   - NAT Gateway para actualizaciones de paquetes

2. **Segmentación**:
   - VPC dedicada aislada de otros recursos
   - Route tables específicas por subnet
   - Control granular de tráfico

### Gestión de Identidades

1. **Autenticación Multifactor**:
   - MFA obligatorio para usuario de testing
   - Bloqueo completo sin MFA activo

2. **Privilegio Mínimo**:
   - Roles específicos por función
   - Políticas AWS managed para consistencia
   - Instance profile con permisos limitados

3. **Seguridad Sin Credenciales**:
   - SSM Session Manager (sin claves SSH)
   - Rotación automática de credenciales temporales
   - Logs de auditoría completos

### Monitoreo de Seguridad

- **CloudWatch Logs**: Registro de todas las acciones
- **CloudTrail**: Auditoría de llamadas API
- **VPC Flow Logs**: Análisis de tráfico de red

## Consideraciones de Producción

### Escalabilidad

Para entornos de producción, considerar:

1. **Auto Scaling Groups**:
   - Escalado automático basado en métricas
   - Distribución multi-AZ
   - Integración con Application Load Balancer

2. **RDS para Persistencia**:
   - Bases de datos managed
   - Backups automáticos
   - Multi-AZ para alta disponibilidad

3. **S3 para Almacenamiento**:
   - Logs centralizados
   - Backups de configuraciones
   - Versionado de objetos

### Alta Disponibilidad

1. **Multi-AZ Deployment**:
```hcl
# Ejemplo de configuración
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
```

2. **Health Checks**:
   - CloudWatch Alarms para detección de fallos
   - Auto-recovery de instancias
   - Notificaciones automáticas

### Optimización de Costos

1. **Recursos Actuales**:
   - EC2 t2.micro: ~$8.50/mes
   - NAT Gateway: ~$32/mes
   - CloudWatch: Capa gratuita
   - **Total estimado**: ~$40-50/mes

2. **Optimizaciones Posibles**:
   - Reserved Instances (hasta 72% de ahorro)
   - Spot Instances para cargas no críticas
   - VPC Endpoints para eliminar NAT Gateway
   - S3 lifecycle policies

## Monitoreo y Observabilidad

### Métricas Clave

**Nivel de Infraestructura**:
- Salud de instancias EC2
- Utilización de NAT Gateway
- Flujo de tráfico de red

**Nivel de Aplicación**:
- Estado de contenedores Docker
- Uso de recursos por contenedor
- Logs de aplicación

**Nivel de Costos**:
- AWS Cost Explorer
- Budgets y alertas de gasto

### Dashboards

CloudWatch Dashboards recomendados:

1. **Infrastructure Overview**:
   - Estado general de la VPC
   - Métricas de EC2 consolidadas
   - Alertas activas

2. **Application Performance**:
   - Métricas de Docker
   - Logs de aplicaciones
   - Trazas de errores

3. **Security & Compliance**:
   - Intentos de acceso
   - Eventos de IAM
   - Cambios de configuración

## Troubleshooting

### Problemas Comunes

**1. Instancia EC2 no aparece en SSM**
```bash
# Verificar rol IAM
aws ec2 describe-instances --instance-ids i-xxxxx \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'

# Revisar logs de SSM agent
sudo journalctl -u amazon-ssm-agent
```

**2. Docker no se instaló correctamente**
```bash
# Ver logs de user_data
sudo cat /var/log/cloud-init-output.log

# Re-ejecutar script manualmente
sudo bash /var/lib/cloud/instance/scripts/part-001
```

**3. No hay conectividad a internet desde subnet privada**
```bash
# Verificar NAT Gateway
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-xxxxx"

# Revisar route table
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-xxxxx"
```

**4. Alarmas de CloudWatch no se activan**
```bash
# Verificar estado de alarma
aws cloudwatch describe-alarms --alarm-names <alarm-name>

# Revisar métricas recientes
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxx \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average
```

## Roadmap Futuro

### Mejoras Planificadas

- [ ] Implementación de CI/CD con GitHub Actions
- [ ] Terraform Cloud para state management remoto
- [ ] Integración con Prometheus/Grafana
- [ ] Implementación de WAF para protección web
- [ ] Secrets management con AWS Secrets Manager
- [ ] Backup automático con AWS Backup
- [ ] Disaster recovery plan automatizado
- [ ] Compliance monitoring (CIS, PCI-DSS)

## Contribución

Para contribuir al proyecto:

1. Fork el repositorio
2. Crear una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit los cambios (`git commit -m 'feat: agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abrir un Pull Request

### Estándares de Código

- Seguir convenciones de Terraform
- Documentar variables y outputs
- Incluir ejemplos de uso
- Validar con `terraform validate` y `terraform fmt`

## Licencia

Este proyecto está bajo la licencia MIT.

## Contacto y Soporte

Para preguntas, sugerencias o reportar problemas:

- Abrir un issue en el repositorio
- Email: [tu-email@ejemplo.com]
- Documentación adicional: [wiki del proyecto]

---

**Última actualización**: Enero 2026
**Versión**: 1.0.0
**Mantenido por**: [Tu Nombre/Organización]
