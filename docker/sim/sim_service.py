import os
import time
from threading import Thread
from flask import Flask, jsonify, request, Response
from prometheus_client import CollectorRegistry, Gauge, generate_latest

app = Flask(__name__)

SERVICE = os.environ.get('SERVICE_TYPE', 'metrics')

registry = CollectorRegistry()
g_dns_q = Gauge('dns_queries_total', 'Simulated DNS queries', registry=registry)
g_dhcp_leases = Gauge('dhcp_leases_active', 'Simulated DHCP active leases', registry=registry)
g_radius_auth_success = Gauge('radius_auth_success_total', 'Simulated RADIUS successful auths', registry=registry)


def simulate_dns():
    while True:
        g_dns_q.inc(1)
        print('[dns-sim] Simulated DNS query')
        time.sleep(5)


def simulate_dhcp():
    leases = 2
    while True:
        leases = (leases % 10) + 1
        g_dhcp_leases.set(leases)
        print(f'[dhcp-sim] Active leases: {leases}')
        time.sleep(6)


def simulate_radius():
    success = 0
    while True:
        success += 1
        g_radius_auth_success.set(success)
        print(f'[radius-sim] Successful auths: {success}')
        time.sleep(7)


@app.route('/')
def index():
    return jsonify({
        'service': SERVICE,
        'message': f'Simulator running for {SERVICE}'
    })


@app.route('/metrics')
def metrics():
    if SERVICE == 'metrics':
        # expose aggregated metrics
        return Response(generate_latest(registry), mimetype='text/plain; version=0.0.4')
    else:
        # expose same metrics so Prometheus can scrape any service
        return Response(generate_latest(registry), mimetype='text/plain; version=0.0.4')


@app.route('/leases')
def leases():
    # simple read-only view into DHCP config file if mounted
    cfg_path = '/configs/kea-dhcp4.conf'
    if os.path.exists(cfg_path):
        try:
            with open(cfg_path, 'r') as f:
                data = f.read()
            return Response(data, mimetype='text/plain')
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    return jsonify({'leases': 'simulated', 'count': int(g_dhcp_leases._value.get()) if hasattr(g_dhcp_leases, '_value') else 1})


@app.route('/auth', methods=['POST', 'GET'])
def auth():
    user = request.args.get('user', 'test')
    # simple simulated auth
    ok = True
    if ok:
        return jsonify({'user': user, 'status': 'Access-Accept'})
    return jsonify({'user': user, 'status': 'Access-Reject'}), 401


def start_sim():
    if SERVICE == 'dhcp':
        t = Thread(target=simulate_dhcp, daemon=True)
        t.start()
    elif SERVICE == 'dns':
        t = Thread(target=simulate_dns, daemon=True)
        t.start()
    elif SERVICE == 'radius':
        t = Thread(target=simulate_radius, daemon=True)
        t.start()
    else:
        # metrics service will increment all metrics periodically
        t1 = Thread(target=simulate_dns, daemon=True)
        t2 = Thread(target=simulate_dhcp, daemon=True)
        t3 = Thread(target=simulate_radius, daemon=True)
        t1.start(); t2.start(); t3.start()


if __name__ == '__main__':
    print(f'Starting simulator for service: {SERVICE}')
    start_sim()
    app.run(host='0.0.0.0', port=8000)
