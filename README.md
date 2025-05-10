# Log Analytics on Google Cloud

This repository demonstrates how to use Cloud Logging on Google Cloud Platform (GCP) to gain insights into applications running on Google Kubernetes Engine (GKE).

## Overview

Cloud Logging is a fully managed service that allows you to store, search, analyze, monitor, and alert on logging data and events from Google Cloud. This project shows how to effectively use log analytics to understand application behavior and performance.

## What You'll Learn

- How to use Cloud Logging effectively to gain insights about applications running on Google Kubernetes Engine (GKE)
- How to build and run effective queries using log analytics
- How to manage log buckets and configure log sinks
- How to analyze various aspects of application performance using SQL queries

## Demo Application

This project uses the [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) microservices demo application deployed to a GKE cluster. This demo app consists of multiple microservices and dependencies.

![Online Boutique Architecture](images/microservices-diagram.png)

## Prerequisites

- Google Cloud Platform account
- GKE cluster provisioned in europe-west1-b zone
- Basic familiarity with Kubernetes and SQL

## Setup Instructions

### 1. Set up the GKE Cluster

```bash
# Set the compute zone
gcloud config set compute/zone europe-west1-b

# Verify cluster status
gcloud container clusters list

# Get cluster credentials
gcloud container clusters get-credentials day2-ops --region europe-west1

# Verify nodes are ready
kubectl get nodes
```

### 2. Deploy the Application

```bash
# Clone the repository
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git

# Navigate to the directory
cd microservices-demo

# Deploy the application
kubectl apply -f release/kubernetes-manifests.yaml

# Verify pods are running
kubectl get pods

# Get the external IP of the application
export EXTERNAL_IP=$(kubectl get service frontend-external -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo $EXTERNAL_IP

# Confirm the app is running
curl -o /dev/null -s -w "%{http_code}\n" http://${EXTERNAL_IP}
```

### 3. Manage Log Buckets

#### Option 1: Upgrade an Existing Bucket

1. Navigate to **Observability > Logging > Logs storage**
2. Click **UPGRADE** for an existing bucket (e.g., the Default bucket)
3. Confirm the upgrade
4. Wait for the upgrade to complete
5. Open the `_AllLogs` view

#### Option 2: Create a New Log Bucket

1. Navigate to **Logging > Logs storage**
2. Click **CREATE LOG BUCKET**
3. Provide a name (e.g., `day2ops-log`)
4. Check both:
   - Upgrade to use Log Analytics
   - Create a new BigQuery dataset that links to this bucket
5. Add a dataset name (e.g., `day2ops_log`)
6. Click **Create bucket**

### 4. Write to the New Log Bucket

1. Navigate to **Logging > Logs Explorer**
2. Enable **Show query** and run:
   ```
   resource.type="k8s_container"
   ```
3. Click **Actions > Create sink**
4. Provide a name (e.g., `day2ops-sink`)
5. Select **Logging bucket** as the sink service
6. Select your new log bucket
7. The resource type query should be automatically included in the filter
8. Create the sink

### 5. Read from the New Log Bucket

1. In Logs Explorer, select your new log bucket from **Project logs > Log view**
2. Click **APPLY**
3. Observe that only Kubernetes Container logs are now shown

## Log Analysis Examples

Navigate to the **Log Analytics** page to run SQL queries against your logs.

### Find the Most Recent Errors

```sql
SELECT
 TIMESTAMP,
 JSON_VALUE(resource.labels.container_name) AS container,
 json_payload
FROM
 `PROJECT_ID.global.day2ops-log._AllLogs`
WHERE
 severity="ERROR"
 AND json_payload IS NOT NULL
ORDER BY
 1 DESC
LIMIT
 50
```

### Find Min, Max, and Average Latency

```sql
SELECT
hour,
MIN(took_ms) AS min,
MAX(took_ms) AS max,
AVG(took_ms) AS avg
FROM (
SELECT
  FORMAT_TIMESTAMP("%H", timestamp) AS hour,
  CAST( JSON_VALUE(json_payload,
      '$."http.resp.took_ms"') AS INT64 ) AS took_ms
FROM
  `PROJECT_ID.global.day2ops-log._AllLogs`
WHERE
  timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND json_payload IS NOT NULL
  AND SEARCH(labels,
    "frontend")
  AND JSON_VALUE(json_payload.message) = "request complete"
ORDER BY
  took_ms DESC,
  timestamp ASC )
GROUP BY
1
ORDER BY
1
```

### Count Product Page Visits

```sql
SELECT
count(*)
FROM
`PROJECT_ID.global.day2ops-log._AllLogs`
WHERE
text_payload like "GET %/product/L9ECAV7KIM %"
AND
timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
```

### Count Checkout Sessions

```sql
SELECT
 JSON_VALUE(json_payload.session),
 COUNT(*)
FROM
 `PROJECT_ID.global.day2ops-log._AllLogs`
WHERE
 JSON_VALUE(json_payload['http.req.method']) = "POST"
 AND JSON_VALUE(json_payload['http.req.path']) = "/cart/checkout"
 AND timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
GROUP BY
 JSON_VALUE(json_payload.session)
```

## Screenshots

- [GKE Cluster Setup](images/gke-cluster.png)
- [Application Deployment](images/application-deployment.png)
- [Log Analytics Interface](images/log-analytics.png)

## Additional Resources

- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Microservices Demo Repository](https://github.com/GoogleCloudPlatform/microservices-demo)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
