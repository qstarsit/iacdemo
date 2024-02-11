#!/bin/bash

# Install crossplane using Helm
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace

# Check installation
kubectl get pods -n crossplane
kubectl api-resources | grep crossplane

# AWS configuration
kubectl apply -f aws-provider-s3.yaml

# Create aws-secret before you continue, see:
# https://docs.crossplane.io/latest/getting-started/provider-aws/#create-a-kubernetes-secret-for-aws

# Add aws-secret to provider
kubectl apply -f provider-config.yaml
