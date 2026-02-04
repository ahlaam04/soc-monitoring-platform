# LES DASHBOARDS GRAFANA

###  Connexion et base

1. Ouvre Grafana
   :  [http://localhost:3000](http://localhost:3000)
2. Login admin
3.  *Configuration → Data Sources*
4. Ajoute **Prometheus manuellement**

   * Type : Prometheus
   * URL : `http://prometheus:9090`
   * Save & Test
  ---

##  Dashboard 1 — “Security SOC Dashboard - Anomaly Detection”

### Créer le dashboard

1. Create → Dashboard*
2. *Add new panel*

#### Panel — Juice Shop Status

* **Type** : Stat
* **Query** :

```promql
up{job="juice-shop"}
```

* Mapping :

  * 0 → DOWN (rouge)
  * 1 → UP (vert)
* **Titre** : `Juice Shop Status`

####  Panel — CPU Usage Over Time (Anomaly)

* **Type** : Time series
* **Query** :

```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

* Threshold :

  * > 80 % → rouge
* **Titre** :
  `CPU Usage Over Time - Anomaly Detection`

---

####  Panel — Network Traffic (Exfiltration)

* **Type** : Time series
* **Queries** :

```promql
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

* **Titre** :
  `Network Traffic - Data Exfiltration Detection`

---
####  Panel — Services Status Distribution

* **Type** : piechart
* **Queries** :

```promql
up
```

* **Titre** :
  `Services Status Distribution`


##  Dashboard 2 — “System Overview - SOC Monitoring”

### 🔹 CPU Usage (Gauge)

```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### 🔹 Memory Usage (Gauge)

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### 🔹 Disk Space Available (Gauge)

```promql
(node_filesystem_avail_bytes{mountpoint="/",fstype!="tmpfs"} / node_filesystem_size_bytes{mountpoint="/"}) * 100
```
---
# LES ALERTES Grafana

Dans Grafana (http://localhost:3001)

**Alerting** → **Alert rules** → **New alert rule**

## ServiceDown
```
Query A: up
Condition: IS BELOW 1
For: 1m

Labels:
severity: critical
category: availability
tier: application
```

## JuiceShopDown
```
Query A: up{job="juice-shop"}
Condition: IS BELOW 1
For: 30s

Labels:
severity: critical
category: availability
tier: application
app: juice-shop
```
## HighHTTPLatency
```
Query A: probe_http_duration_seconds{job="blackbox-http"}
Condition: IS ABOVE 2
For: 3m

Labels:
severity: warning
category: performance
tier: application

```

## HTTPProbeFailed
```
Query A: probe_success{job="blackbox-http"}
Condition: IS BELOW 1
For: 2m

Labels:
severity: critical
category: availability
tier: monitoring
```

## CriticalCPUUsage
```
Query A: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
Condition: IS ABOVE 90
For: 3m

Labels:
severity: critical
category: performance
tier: infrastructure
```
## CriticalMemoryUsage
```
Query A: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
Condition: IS ABOVE 90
For: 2m

Labels:
severity: critical
category: performance
tier: infrastructure
```
## HighCPUUsage
```
Query A: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
Condition: IS ABOVE 75
For: 5m

Labels:
severity: warning
category: performance
tier: infrastructure
```

## JuiceShopSlowResponse
```
Query A: probe_http_duration_seconds{job="blackbox-http", instance=~".*juice-shop.*"}
Condition: IS ABOVE 3
For: 2m

Labels:
severity: warning
category: security
tier: application
attack_type: potential_dos
```

## UnusualNetworkTraffic
```
Query A: rate(node_network_transmit_bytes_total[5m])
Condition: IS ABOVE 100000000
For: 2m

Labels:
severity: warning
category: security
tier: infrastructure
team: soc
attack_type: potential_data_exfiltration
```
