# 🛡️ SOC Monitoring Platform — Anomaly Detection for Microservices

> **Plateforme de Monitoring et Détection d'Anomalies pour une Application Microservices Vulnérable**

Une plateforme complète de surveillance SOC (Security Operations Center) déployée sur une architecture microservices, utilisant **Prometheus**, **Grafana**, **Alertmanager** et **OWASP Juice Shop**.

---

##  Table des Matières

- [Architecture](#-architecture)
- [Stack Technologique](#-stack-technologique)
- [Prérequis](#-prérequis)
- [Installation Rapide](#-installation-rapide)
- [Structure du Projet](#-structure-du-projet)
- [Accès aux Services](#-accès-aux-services)
- [Alertes Configurées](#-alertes-configurées)
- [Dashboards Grafana](#-dashboards-grafana)
- [Tests & Simulations](#-tests--simulations)
- [Configuration Slack](#-configuration-slack)
- [Compétences Développées](#-compétences-développées)

---

##  Architecture
<img width="1423" height="712" alt="Capture d&#39;écran 2026-02-01 001200" src="https://github.com/user-attachments/assets/23aeca29-a82f-4b10-a740-e4d8d6f4b81a" />
---

## 🛠️ Stack Technologique

| Composant | Rôle | Version |
|-----------|------|---------|
| **Docker** | Containerisation | 20.10+ |
| **Docker Compose** | Orchestration | v2+ |
| **OWASP Juice Shop** | Application cible (vulnérable) | Latest |
| **Prometheus** | Collecte & stockage des métriques | Latest |
| **Grafana** | Visualisation & dashboards | Latest |
| **Alertmanager** | Routage & gestion des alertes | Latest |
| **Node Exporter** | Métriques système (CPU, RAM, Disque) | Latest |
| **cAdvisor** | Métriques des conteneurs Docker | v0.47.0 |
| **Blackbox Exporter** | Vérification HTTP/ICMP des endpoints | Latest |

---

##  Prérequis

- **Docker** : version 20.10 ou supérieure
- **Docker Compose** : version 2+
- **RAM** : minimum 4 GB (8 GB recommandés)
- **Disque** : minimum 10 GB

---

##  Installation Rapide

```bash
# 1. Cloner le repository
git clone https://github.com/ahlaam04/soc-monitoring-platform.git
cd soc-monitoring-platform

# 2. Rendre les scripts exécutables
chmod +x scripts/*.sh

# 3. Démarrer la plateforme
./scripts/start.sh

# 4. Attendre 15 secondes puis accéder à Grafana
# http://localhost:3002 (admin/admin)
```

---

##  Structure du Projet

```
soc-monitoring-platform/
├── docker-compose.yml                          # Définition de tous les services          
├── .gitignore
├── .env.example                                # Les variables d'environment
├── prometheus/                                 # Configuration Prometheus
│   ├── prometheus.yml                          # Config    
│   └── blackbox.yml                            # Config Blackbox Exporter
│
├── alertmanager/                               # Configuration Alertmanager
│   └── alertmanager.yml                        # Routage multi-canaux Slack
│
├── grafana                                   # Configuration Grafana
├── scripts/                                    # Scripts d'automatisation   
    └── simulate-attacks.sh                     # Simulateur d'attaques                       
```

---
 

##  Accès aux Services

| Service | URL | Identifiants |
|---------|-----|--------------|
|  **Juice Shop** | http://localhost:3001 | — |
|  **Grafana** | http://localhost:3002 | admin / admin |
|  **Prometheus** | http://localhost:9090 | — |
|  **Alertmanager** | http://localhost:9093 | — |
|  **cAdvisor** | http://localhost:8080 | — |
|  **Node Exporter** | http://localhost:9100/metrics | — |

---

## 🚨 Alertes Configurées 

### Infrastructure 
| Alerte | Seuil | Sévérité |
|--------|-------|----------|
| HighCPUUsage | CPU > 80% × 2min | ⚠️ Warning |
| CriticalCPUUsage | CPU > 90% × 3min | 🔴 Critical |
| CriticalMemoryUsage | RAM > 90% × 2min | 🔴 Critical |

### Disponibilité
| Alerte | Condition | Sévérité |
|--------|-----------|----------|
| ServiceDown | up == 0 × 1min | 🔴 Critical |
| JuiceShopDown | Juice Shop down × 30s | 🔴 Critical |
| HTTPProbeFailed | Probe échoué × 1min | 🔴 Critical |

### Sécurité SOC 
| Alerte | Ce qu'elle détecte | Sévérité |
|--------|--------------------|----------|
| UnusualNetworkTraffic | Trafic réseau > 50MB/s | ⚠️ Warning |
| JuiceShopSlowResponse | Latence > 3s × 2min | ⚠️ Warning |


<img width="1885" height="932" alt="image" src="https://github.com/user-attachments/assets/03f497d0-3767-4153-a3fc-d3c95bfc8600" />

<img width="1918" height="745" alt="image" src="https://github.com/user-attachments/assets/d5968995-24d9-4f9d-8db8-12aebd91a6f5" />

---

## 📊 Dashboards Grafana

### 1. 📊 System Overview Dashboard
- CPU Usage (Gauge)
- Memory Usage (Gauge)
- Disk Usage (Bar Gauge)

<img width="1918" height="745" alt="image" src="https://github.com/user-attachments/assets/823bdc27-071c-4a1d-98cb-4dad1e18bfa8" />

---


### 2. 🛡️ Security SOC Dashboard
- Juice Shop Status (UP/DOWN)
- Services Distribution (Donut Chart)
- Network Traffic — Data Exfiltration Detection
- CPU Anomaly Detection (avec seuils visuels)

<img width="1915" height="742" alt="image" src="https://github.com/user-attachments/assets/b89b6757-c0b6-4576-8b63-f17c2b625d8d" />

---

##  Tests & Simulations

```bash
# Lancer le simulateur d'attaques
./scripts/simulate-attacks.sh
```

### Options disponibles :
| Option | Test | Alertes Déclenchées |
|--------|------|---------------------|
| 1 | Stress CPU | HighCPUUsage, CriticalCPUUsage |
| 2 | Saturation Mémoire | HighMemoryUsage, CriticalMemoryUsage |
| 3 | Simulation DoS | UnusualNetworkTraffic, ApplicationLayerDoS |
| 4 | Brute Force | SuspiciousNightActivity |
| 5 | SQL Injection | (Logs analysables) |
| 6 | Arrêt Service | ServiceDown, JuiceShopDown |
| 7 | **Attaque Combinée** | **Toutes les alertes simultanément** |

---

##  Configuration Slack

Pour recevoir les alertes sur Slack :

1. Créer un **Webhook Slack** : https://api.slack.com/messaging/webhooks
2. Copier l'URL du webhook
3. Modifier `alertmanager/alertmanager.yml` :
   - Remplacer `https://hooks.slack.com/services/VOTRE/WEBHOOK/URL` par votre URL
4. Redémarrer Alertmanager :
   ```bash
   docker-compose restart alertmanager
   ```
<img width="1918" height="741" alt="image" src="https://github.com/user-attachments/assets/dbccba6a-6f7b-44a3-9649-64c4f208987e" />

<img width="1918" height="816" alt="image" src="https://github.com/user-attachments/assets/b4351038-b509-49d4-b79c-3c340cd02a55" />

---
