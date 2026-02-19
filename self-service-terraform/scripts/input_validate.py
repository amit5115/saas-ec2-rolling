import yaml
import sys

with open("config/allowed_values.yaml") as f:
    allowed = yaml.safe_load(f)["allowed"]

def choose(label, options):
    print(f"\nSelect {label}:")
    for i, o in enumerate(options, 1):
        print(f"{i}) {o}")
    idx = int(input("Enter choice: ")) - 1
    return options[idx]

env = choose("environment", allowed["environments"])
vm_size = choose("VM size", allowed["vm_sizes"])

disk_size = int(input("\nEnter disk size (GB): "))
if disk_size > allowed["max_disk_size"]:
    print("❌ Disk size exceeds allowed limit")
    sys.exit(1)

print("\nInput validated")

print(f"ENV={env}")
print(f"VM_SIZE={vm_size}")
print(f"DISK_SIZE={disk_size}")
