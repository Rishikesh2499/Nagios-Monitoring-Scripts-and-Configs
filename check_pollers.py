import re
import sys

# File containing poller data
file_path = ""

# Availability threshold
threshold = 0.95

def check_poller(file_path, poller_id=None):
    try:
        with open(file_path, "r") as file:
            content = file.read()

        # Regular expression to extract poller data
        pattern = r"sPoller(\d+)Text\s+=\s+sFirstChunk\s+\+\s+'(\d+)'\s+\+\s+sSecondChunk\s+\+\s+'(.*?)'\s+\+\s+sThirdChunk\s+\+\s+'([\d\.]+)'\s+\+\s+sFourthChunk;"
        matches = re.findall(pattern, content, re.DOTALL)

        if not matches:
            print("CRITICAL: No poller data found.")
            return 2  # Nagios CRITICAL status

        for match in matches:
            current_poller_id, _, poller_name, availability = match
            availability = float(availability)

            if poller_id and current_poller_id != poller_id:
                continue

            status = "Online" if availability > threshold else "Offline"
            if status == "Offline":
                print(f"CRITICAL: Poller {current_poller_id} ({poller_name}) is offline (Availability: {availability:.3f})")
                return 2  # Nagios CRITICAL status

            print(f"OK: Poller {current_poller_id} ({poller_name}) is online (Availability: {availability:.3f})")
            return 0  # Nagios OK status

        if poller_id:
            print(f"CRITICAL: Poller {poller_id} not found.")
            return 2  # Nagios CRITICAL status

    except Exception as e:
        print(f"CRITICAL: Error reading poller data - {e}")
        return 2  # Nagios CRITICAL status

if __name__ == "__main__":
    poller_id = sys.argv[1] if len(sys.argv) > 1 else None
    sys.exit(check_poller(file_path, poller_id))
