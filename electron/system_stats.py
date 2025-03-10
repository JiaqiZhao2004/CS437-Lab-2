import psutil
import subprocess


def get_cpu_temperature():
    try:
        output = subprocess.check_output("vcgencmd measure_temp", shell=True)
        return float(output.decode("utf-8").strip().replace("temp=", "").replace("'C", ""))
    except:
        return None

def get_cpu_usage():
    return psutil.cpu_percent(interval=1)

def get_memory_usage():
    return psutil.virtual_memory().percent

def get_network_stats():
    net = psutil.net_io_counters()
    return f"Sent: {net.bytes_sent / (1024 ** 2)} MB, Received: {net.bytes_recv / (1024 ** 2)} MB"