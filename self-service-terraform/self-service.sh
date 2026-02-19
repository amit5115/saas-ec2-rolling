#!/bin/bash
set -e

echo "Self-Service VM Provisioning"
echo "Please provide inputs when prompted"

# Run interactive Python with terminal input preserved
python3 scripts/input_validate.py </dev/tty | tee /tmp/self_service.out

ENV=$(grep ENV /tmp/self_service.out | cut -d= -f2)
VM_SIZE=$(grep VM_SIZE /tmp/self_service.out | cut -d= -f2)
DISK_SIZE=$(grep DISK_SIZE /tmp/self_service.out | cut -d= -f2)

echo ""
echo "   Selected values:"
echo "   Environment = $ENV"
echo "   VM Size     = $VM_SIZE"
echo "   Disk Size   = $DISK_SIZE GB"
echo ""

export ENVIRONMENT=$ENV


STATE_BUCKET="amitk30-terraform-state"
STATE_PREFIX="self-service/vm/${ENV}"

echo "🔐 Initializing backend (authoritative mode)"

terraform -chdir=terraform init -reconfigure \
  -backend-config="bucket=${STATE_BUCKET}" \
  -backend-config="prefix=${STATE_PREFIX}"



terraform -chdir=terraform plan \
  -var="project_id=$GOOGLE_PROJECT" \
  -var="region=us-central1" \
  -var="environment=$ENV" \
  -var="vm_size=$VM_SIZE" \
  -var="disk_size=$DISK_SIZE" \
  -var="config_file=../config/base_config.yaml" \
  -out=tfplan


terraform -chdir=terraform show -json tfplan > tfplan.json

python3 scripts/plan_summary.py

read -p "👉 Proceed with apply? (yes/no): " choice
[[ "$choice" != "yes" ]] && echo "Cancelled" && exit 1

terraform -chdir=terraform apply tfplan

export ENVIRONMENT=$ENV

python3 scripts/plan_summary.py
RC=$?

if [ $RC -eq 2 ]; then
  python3 scripts/send_approval_email.py "$ENV"
  echo "⏸️ Approval required. Email sent."
  echo "👉 Approve by creating: approvals/approve-$ENV.txt"
  exit 0
fi


