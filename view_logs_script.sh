#!/bin/bash
# Script to view different types of audit logs

# Exit on any error
set -e

# Get current project ID
PROJECT_ID=$(gcloud config get-value project)
echo "Using Google Cloud Project: $PROJECT_ID"

echo -e "\n========================================"
echo "Cloud Audit Logs Viewer"
echo "========================================"

PS3="Select the type of logs to view: "
options=("Admin Activity Logs" "Data Access Logs" "System Event Logs" "Policy Denied Logs" "All Logs" "Custom Query" "Exit")

select opt in "${options[@]}"
do
    case $opt in
        "Admin Activity Logs")
            echo "Fetching Admin Activity logs (last 10 entries)..."
            gcloud logging read "logName=projects/$PROJECT_ID/logs/cloudaudit.googleapis.com%2Factivity" --limit=10
            ;;
        "Data Access Logs")
            echo "Fetching Data Access logs (last 10 entries)..."
            gcloud logging read "logName=projects/$PROJECT_ID/logs/cloudaudit.googleapis.com%2Fdata_access" --limit=10
            ;;
        "System Event Logs")
            echo "Fetching System Event logs (last 10 entries)..."
            gcloud logging read "logName=projects/$PROJECT_ID/logs/cloudaudit.googleapis.com%2Fsystem_event" --limit=10
            ;;
        "Policy Denied Logs")
            echo "Fetching Policy Denied logs (last 10 entries)..."
            gcloud logging read "logName=projects/$PROJECT_ID/logs/cloudaudit.googleapis.com%2Fpolicy" --limit=10
            ;;
        "All Logs")
            echo "Fetching all audit logs (last 10 entries)..."
            gcloud logging read "logName=projects/$PROJECT_ID/logs/cloudaudit.googleapis.com%2F*" --limit=10
            ;;
        "Custom Query")
            echo "Enter your custom query filter:"
            read -r custom_filter
            echo "Fetching logs with custom filter (last 10 entries)..."
            gcloud logging read "$custom_filter" --limit=10
            ;;
        "Exit")
            break
            ;;
        *) 
            echo "Invalid option $REPLY"
            ;;
    esac
    echo
    echo "Press Enter to continue..."
    read
    PS3="Select the type of logs to view: "
done

echo "Exiting log viewer"
