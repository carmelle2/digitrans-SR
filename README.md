# DIGITRANS-CM - Système d'Information Agroalimentaire

MVP Spring Boot multi-modules pour AGROCAM S.A. - Projet universitaire cloud.

## Architecture

4 microservices indépendants :
- **erp-service** (port 8081) - Gestion RH et approvisionnements
- **crm-service** (port 8082) - Gestion relation client
- **supply-chain-service** (port 8083) - Suivi marchandises avec cache Redis
- **bi-service** (port 8084) - Tableaux de bord analytiques

## Stack Technique

- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- Spring Security + JWT
- PostgreSQL (4 bases de données)
- Redis (cache)
- Swagger/OpenAPI 3
- Docker & Docker Compose

## Prérequis

- JDK 17
- Maven 3.8+
- Docker & Docker Compose

## Build du projet

```bash
# À la racine du projet
mvn clean package -DskipTests
```

## Lancement avec Docker

```bash
# Build et démarrage de tous les services
docker-compose up --build

# En arrière-plan
docker-compose up -d --build

# Arrêt
docker-compose down
```

## Lancement en local (sans Docker)

### 1. Démarrer PostgreSQL et Redis localement

```bash
# PostgreSQL sur ports 5432, 5433, 5434
# Redis sur port 6379
```

### 2. Lancer chaque service

```bash
# Terminal 1 - ERP Service
cd erp-service
mvn spring-boot:run

# Terminal 2 - CRM Service
cd crm-service
mvn spring-boot:run

# Terminal 3 - Supply Chain Service
cd supply-chain-service
mvn spring-boot:run

# Terminal 4 - BI Service
cd bi-service
mvn spring-boot:run
```

## Endpoints API

### Authentification (tous les services)

```bash
POST http://localhost:808X/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password"
}

# Réponse
{
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### ERP Service (8081)

```bash
# Employees
GET    http://localhost:8081/api/employees
POST   http://localhost:8081/api/employees
GET    http://localhost:8081/api/employees/{id}

# Suppliers
GET    http://localhost:8081/api/suppliers
POST   http://localhost:8081/api/suppliers
```

### CRM Service (8082)

```bash
# Customers
GET    http://localhost:8082/api/customers
POST   http://localhost:8082/api/customers

# Orders
GET    http://localhost:8082/api/orders
POST   http://localhost:8082/api/orders
GET    http://localhost:8082/api/orders/{customerId}
```

### Supply Chain Service (8083)

```bash
# Products (avec cache Redis - TTL 5 min)
GET    http://localhost:8083/api/products
POST   http://localhost:8083/api/products

# Shipments
GET    http://localhost:8083/api/shipments
POST   http://localhost:8083/api/shipments
PUT    http://localhost:8083/api/shipments/{id}/status
```

### BI Service (8084)

```bash
# Dashboard
GET    http://localhost:8084/api/dashboard/summary
GET    http://localhost:8084/api/dashboard/orders-by-city
```

## Utilisation avec JWT

Tous les endpoints (sauf `/api/auth/login`) nécessitent un token JWT :

```bash
# 1. Obtenir un token
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# 2. Utiliser le token
curl -X GET http://localhost:8081/api/employees \
  -H "Authorization: Bearer <votre-token>"
```

## Documentation Swagger

Accessible sur chaque service :
- ERP: http://localhost:8081/swagger-ui.html
- CRM: http://localhost:8082/swagger-ui.html
- Supply Chain: http://localhost:8083/swagger-ui.html
- BI: http://localhost:8084/swagger-ui.html

## Exemples de données

### Créer un employé

```bash
POST http://localhost:8081/api/employees
Authorization: Bearer <token>
Content-Type: application/json

{
  "nom": "Nkomo",
  "prenom": "Jean",
  "role": "Manager",
  "departement": "Production"
}
```

### Créer un client

```bash
POST http://localhost:8082/api/customers
Authorization: Bearer <token>
Content-Type: application/json

{
  "nom": "Restaurant SavoirManger Douala",
  "email": "douala@savoirmanger.cm",
  "ville": "Douala"
}
```

### Créer une commande

```bash
POST http://localhost:8082/api/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "customerId": 1,
  "montant": 150000,
  "statut": "EN_COURS",
  "date": "2024-01-15T10:30:00"
}
```

### Créer un produit

```bash
POST http://localhost:8083/api/products
Authorization: Bearer <token>
Content-Type: application/json

{
  "nom": "Bananes Plantain",
  "categorie": "Fruits",
  "quantite": 500
}
```

### Créer un envoi

```bash
POST http://localhost:8083/api/shipments
Authorization: Bearer <token>
Content-Type: application/json

{
  "productId": 1,
  "origine": "Plantation Bafoussam",
  "destination": "Entrepôt Douala",
  "statut": "EN_TRANSIT",
  "date": "2024-01-15T08:00:00"
}
```

### Mettre à jour le statut d'un envoi

```bash
PUT http://localhost:8083/api/shipments/1/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "LIVRE"
}
```

### Obtenir le résumé du dashboard

```bash
GET http://localhost:8084/api/dashboard/summary
Authorization: Bearer <token>

# Réponse
{
  "totalEmployees": 10,
  "totalCustomers": 5,
  "totalOrders": 15,
  "totalShipments": 8
}
```

### Obtenir les commandes par ville

```bash
GET http://localhost:8084/api/dashboard/orders-by-city
Authorization: Bearer <token>

# Réponse
{
  "ordersByCity": {
    "Douala": 8,
    "Yaoundé": 5,
    "Bafoussam": 2
  }
}
```

## Cache Redis

Le service supply-chain utilise Redis pour mettre en cache la liste des produits :
- Clé de cache : `products::all`
- TTL : 5 minutes (300 secondes)
- Annotation : `@Cacheable(value = "products", key = "'all'")`

## Base de données

Chaque service a sa propre base PostgreSQL :
- `erp_db` (port 5432)
- `crm_db` (port 5433)
- `supplychain_db` (port 5434)

Les tables sont créées automatiquement avec `spring.jpa.hibernate.ddl-auto=update`.

## Sécurité

- JWT avec secret partagé entre tous les services
- Expiration : 24 heures (86400000 ms)
- Endpoints publics : `/api/auth/**`, `/swagger-ui/**`, `/api-docs/**`
- Tous les autres endpoints nécessitent authentification

## Auteur

Projet universitaire DIGITRANS-CM pour AGROCAM S.A.
