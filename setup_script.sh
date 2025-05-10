#!/bin/bash
# Script to set up Google Cloud Audit Logs lab

# Exit on any error
set -e

echo "========================================"
echo "Cloud Audit Logs Lab Setup"
echo "========================================"

# Check if logged in to gcloud
echo "Verifying gcloud authentication..."
gcloud auth list || { echo "ERROR: Not authenticated to gcloud. Please run 'gcloud auth login'"; exit 1; }

# Get current project ID
PROJECT_ID=$(gcloud config get-value project)
echo "Using Google Cloud Project: $PROJECT_ID"

echo -e "\n[Task 1] Enabling Data Access Logs on Cloud Storage"
echo "NOTE: This needs to be done manually in Google Cloud Console:"
echo "1. Navigate to IAM & Admin > Audit Logs"
echo "2. Find Google Cloud Storage and check the box next to it"
echo "3. Enable 'Admin Read', 'Data Read', and 'Data Write'"
echo "4. Click Save"

read -p "Press Enter after completing Task 1 in the console..."

echo -e "\n[Task 2] Generating admin and data access activity"

echo "Creating Cloud Storage bucket..."
gcloud storage buckets create gs://$PROJECT_ID || echo "Bucket creation failed, may already exist"

echo "Listing buckets to verify creation..."
gcloud storage ls

echo "Creating and uploading sample file..."
echo "Hello World!" > sample.txt
gcloud storage cp sample.txt gs://$PROJECT_ID

echo "Verifying file upload..."
gcloud storage ls gs://$PROJECT_ID

echo "Creating network 'mynetwork'..."
gcloud compute networks create mynetwork --subnet-mode=auto || echo "Network creation failed, may already exist"

echo "Creating VM instance..."
gcloud compute instances create default-us-vm \
  --zone=us-central1-a \
  --network=mynetwork \
  --machine-type=e2-medium || echo "VM creation failed"

echo "Deleting storage bucket..."
gcloud storage rm -r gs://$PROJECT_ID || echo "Bucket deletion failed"

echo -e "\n[Task 3] View the audit logs"
echo "NOTE: Logs can be viewed in two ways:"
echo "1. In Google Cloud Console: Navigate to Observability > Logging"
echo "2. Using gcloud CLI (sample command shown below):"
echo

echo "gcloud logging read \"logName=projects/$PROJECT_ID/logs/cloudaudit.googleapis.com%2Fdata_access\""

echo -e "\n========================================"
echo "Setup Complete!"
echo "========================================"
