import json
import sys
import os
from collections import Counter

ENV = os.environ.get("ENVIRONMENT")
APPROVAL_FILE = f"approvals/approve-{ENV}.txt"

with open("tfplan.json") as f:
    plan = json.load(f)

rows = []
counts = Counter()
destructive = False

for r in plan.get("resource_changes", []):
    addr = r["address"]
    actions = r["change"]["actions"]

    if actions == ["create"]:
        act = "CREATE"
    elif actions == ["update"]:
        act = "UPDATE"
        destructive = True
    elif "delete" in actions or "replace" in actions:
        act = "DELETE"
        destructive = True
    else:
        continue

    counts[act] += 1
    rows.append((act, addr))

print("\nTerraform Change Summary")
print("=" * 60)
print(f"{'ACTION':<10} | RESOURCE")
print("-" * 60)

for a, r in rows:
    print(f"{a:<10} | {r}")

print("-" * 60)
for k, v in counts.items():
    print(f"{k}: {v}")

if destructive:
    print("\n🚨 Destructive change detected")

    if os.path.exists(APPROVAL_FILE):
        print(f"✅ Approval found: {APPROVAL_FILE}")
    else:
        print(f"❌ Approval missing: {APPROVAL_FILE}")
        sys.exit(2)

print("\n✅ Safe to apply")
