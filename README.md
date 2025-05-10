# Google Cloud Audit Logs

This repository contains documentation and code for a hands-on project with Google Cloud Audit Logs, demonstrating how to enable, generate, and view audit logs in Google Cloud Platform.

## Project Overview

The project explores Google Cloud Audit Logs which maintain multiple audit logs for projects, folders, and organizations to track who did what, when, and where within a Google Cloud environment.

## Objectives

In this project, I:
- Enabled data access logs on Cloud Storage
- Generated admin and data access activity
- Viewed and analyzed different types of audit logs

## Video

https://youtu.be/jit_lWJuHlM


## Implementation Steps

### 1. Enabling Data Access Logs on Cloud Storage

Data access logs on Cloud Storage were enabled to track operations that read or write user-provided data, as well as metadata and configuration information:

1. Navigated to **IAM & Admin > Audit Logs** in the Google Cloud console
2. Located and selected Google Cloud Storage
3. Enabled the following log types:
   - Admin Read: Records operations that read metadata or configuration information
   - Data Read: Records operations that read user-provided data
   - Data Write: Records operations that write user-provided data

### 2. Generating Admin and Data Access Activity

Created various resources to generate audit logs:

1. Created a Cloud Storage bucket with the same name as the project:
```bash
gcloud storage buckets create gs://$DEVSHELL_PROJECT_ID
```

2. Created and uploaded a simple text file to the bucket:
```bash
echo "Hello World!" > sample.txt
gcloud storage cp sample.txt gs://$DEVSHELL_PROJECT_ID
```

3. Created a new auto-mode network and virtual machine:
```bash
gcloud compute networks create mynetwork --subnet-mode=auto

gcloud compute instances create default-us-vm \
  --zone=us-central1-a --network=mynetwork \
  --machine-type=e2-medium
```

4. Deleted the storage bucket to generate deletion logs:
```bash
gcloud storage rm -r gs://$DEVSHELL_PROJECT_ID
```

### 3. Viewing Audit Logs

#### Using Google Cloud Console

1. Navigated to **Observability > Logging > Logs Explorer**
2. Viewed Admin Activity logs:
   - Filtered to Cloud Audit logs
   - Further filtered to GCS Bucket entries
   - Examined log entries for the bucket deletion event
   - Examined authentication information showing which user performed actions

#### Using Cloud SDK

Viewed data access logs via command line:
```bash
gcloud logging read \
"logName=projects/$DEVSHELL_PROJECT_ID/logs/cloudaudit.googleapis.com%2Fdata_access"
```

## Key Learnings

- Google Cloud Audit Logs provide transparency into who performed what actions in your cloud resources
- Admin Activity logs are always enabled and record configuration changes
- Data Access logs must be explicitly enabled and can track read/write operations on data
- Logs can be viewed through both the Google Cloud Console and CLI tools
- Log entries contain detailed information including timestamps, users, resources, and specific operations

## Resources

- [Google Cloud Audit Logs Documentation](https://cloud.google.com/logging/docs/audit)
- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [gcloud logging command reference](https://cloud.google.com/sdk/gcloud/reference/logging)
