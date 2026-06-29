# Proyecto Final — Tres Pipelines en Azure

Asignación final del curso de Tópicos en Azure. Implementa tres pipelines CI/CD encadenados que aprovisionan infraestructura, construyen una imagen Docker y despliegan un contenedor en Azure.

---

## Arquitectura

```
GitHub Actions
│
├── Pipeline 1: Infrastructure (IaC)
│   └── Terraform → Azure VNet + Subnet + ACR + ACI
│
├── Pipeline 2: Build & Publish
│   └── Docker build (con tests) → ACR
│
└── Pipeline 3: Deployment
    └── ACR → ACI → Validación HTTP
```

**Servicios Azure utilizados:**
- **Azure Virtual Network (VNet)** — red privada `10.0.0.0/16`
- **Azure Subnet** — subred para ACI `10.0.1.0/24`
- **Azure Container Registry (ACR)** — repositorio privado de imágenes Docker
- **Azure Container Instance (ACI)** — contenedor en ejecución con IP pública

---

## Estructura del Repositorio

```
finalproject/
├── .github/workflows/
│   ├── 1-infra.yml       # Pipeline 1: Infraestructura con Terraform
│   ├── 2-build.yml       # Pipeline 2: Build y publicación de imagen
│   └── 3-deploy.yml      # Pipeline 3: Despliegue a ACI
├── app/
│   ├── src/index.js      # API Express con rutas /, /health, /version
│   ├── tests/app.test.js # Tests Jest + supertest
│   └── package.json
├── terraform/
│   ├── main.tf           # Recursos Azure
│   ├── variables.tf      # Variables de entrada
│   ├── outputs.tf        # Outputs (ACR URL, ACI IP)
│   └── backend.tf        # Estado remoto en Azure Storage
├── Dockerfile            # Build multi-stage (tests incluidos)
└── README.md
```

---

## Configuración Inicial (Prerequisitos)

> **¿Por qué hay pasos manuales si usamos Terraform?**
> Dos problemas de bootstrap impiden que Terraform lo haga todo:
> 1. **Service Principal**: son las credenciales que Terraform usa para autenticarse en Azure. No puede crearse a sí mismo.
> 2. **Storage Account para tfstate**: Terraform necesita este backend para guardar su estado *antes* de poder ejecutarse. El Resource Group y todos los demás recursos sí los crea Terraform automáticamente.

### 1. Crear Service Principal (manual — una sola vez)

```bash
# Crear SP con acceso a la suscripción completa
az ad sp create-for-rbac \
  --name sp-finalproject \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --sdk-auth
```

Guardar el JSON completo — se usará como `AZURE_CREDENTIALS`.

### 2. Crear Storage Account para estado Terraform (manual — una sola vez)

```bash
# Resource Group temporal solo para el backend de Terraform
az group create --name rg-tfstate --location eastus

az storage account create \
  --name stfinalprojecttf \
  --resource-group rg-tfstate \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name stfinalprojecttf
```

### 3. Secrets de GitHub

En el repositorio: **Settings → Secrets and variables → Actions**

| Secret | Valor |
|--------|-------|
| `AZURE_CREDENTIALS` | JSON completo del Service Principal |
| `AZURE_SUBSCRIPTION_ID` | ID de la suscripción Azure |
| `AZURE_TENANT_ID` | Tenant ID de Azure AD |
| `AZURE_CLIENT_ID` | Client ID del Service Principal |
| `AZURE_CLIENT_SECRET` | Client Secret del Service Principal |

### 4. Todo lo demás lo crea Terraform (Pipeline 1)

- Resource Group `rg-finalproject-dev`
- Virtual Network + Subnet
- Azure Container Registry
- Azure Container Instance

---

## Pipelines

### Pipeline 1 — Infrastructure (IaC)

**Archivo:** `.github/workflows/1-infra.yml`  
**Trigger:** Push a archivos en `terraform/` o ejecución manual  
**Herramienta:** Terraform 1.8.4 con proveedor AzureRM

**Pasos:**
1. `terraform init` — inicializar con backend remoto en Azure Storage
2. `terraform validate` — validar sintaxis HCL
3. `terraform plan` — previsualizar cambios
4. `terraform apply` — aplicar infraestructura

**Recursos creados:**
- VNet `vnet-finalproject`
- Subnet `subnet-aci` con delegación a ACI
- ACR `acrfinalproject` (Basic, admin habilitado)
- Network Profile para ACI
- ACI `aci-finalproject` con IP pública

### Pipeline 2 — Build & Publish

**Archivo:** `.github/workflows/2-build.yml`  
**Trigger:** Completación exitosa de Pipeline 1, o push a `app/` o `Dockerfile`

**Pasos:**
1. Generar tag con los primeros 7 caracteres del SHA del commit
2. Login en Azure y en ACR
3. `docker build` — el Dockerfile multi-stage ejecuta los tests en stage `builder`
4. `docker push` — publica con tag SHA y `latest`
5. Guardar tag como artefacto para el Pipeline 3

### Pipeline 3 — Deployment

**Archivo:** `.github/workflows/3-deploy.yml`  
**Trigger:** Completación exitosa de Pipeline 2, o ejecución manual con tag específico

**Pasos:**
1. Descargar artefacto con el tag de imagen exacto
2. `az container create` — crear o actualizar ACI con la nueva imagen
3. Obtener IP pública del contenedor
4. Health check: 10 intentos × 15 segundos a `GET /health`
5. Mostrar URL de acceso

---

## Aplicación

API REST mínima en Node.js 20 + Express:

| Ruta | Descripción |
|------|-------------|
| `GET /` | Status general y versión |
| `GET /health` | Estado de salud y uptime |
| `GET /version` | Versión y entorno |

---

## Encadenamiento de Pipelines

```
Push a main (terraform/)
        │
        ▼
  Pipeline 1 (Infra)
        │ workflow_run trigger
        ▼
  Pipeline 2 (Build) ──── image_tag.txt ───► artifact
        │ workflow_run trigger                    │
        ▼                                         │
  Pipeline 3 (Deploy) ◄── download artifact ──────┘
        │
        ▼
    ACI running ✓
```

El tag exacto de imagen viaja de Pipeline 2 a Pipeline 3 como GitHub Actions Artifact, evitando condiciones de carrera con el tag `latest`.
