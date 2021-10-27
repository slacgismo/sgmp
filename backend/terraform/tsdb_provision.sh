#!/bin/bash

# Run Consul client
export AWS_ACCESS_KEY_ID="${aws_access_key_id}"
export AWS_SECRET_ACCESS_KEY="${aws_secret_access_key}"
mkdir -p /home/consul/.aws
cat <<EOT >> /home/consul/.aws/credentials
[default]
aws_access_key_id = ${aws_access_key_id}
aws_secret_access_key = ${aws_secret_access_key}
EOT
chown -R consul:consul /home/consul
chmod 600 /home/consul/.aws/credentials
/opt/consul/bin/run-consul --client --cluster-tag-key consul-servers --cluster-tag-value auto-join

# Purge data
rm -rf /var/lib/postgresql/13/main/*

# Adjust PostgreSQL parameters
timescaledb-tune -yes

# Fix missing directories
mkdir /var/run/postgresql/13-main.pg_stat_tmp
chown postgres:postgres /var/run/postgresql/13-main.pg_stat_tmp

# Run Patroni
cat > /etc/patroni.yml <<EOF
scope: tsdb
namespace: /sgmp-tsdb/
name: $(curl http://169.254.169.254/latest/meta-data/instance-id)

restapi:
  listen: 127.0.0.1:8008
  connect_address: 127.0.0.1:8008

consul:
  host: 127.0.0.1
  register_service: true

bootstrap:
  dcs:
    ttl: 30
    retry_timeout: 10
    postgresql:
      use_pg_rewind: true
      use_slots: true
      parameters:
        wal_level: hot_standby
        wal_keep_segments: 8
        wal_log_hints: 'on'
        max_wal_senders: 5
        max_replication_slots: 5
        hot_standby: 'on'
        tcp_keepalives_idle: 900
        tcp_keepalives_interval: 100
        track_functions: all
        checkpoint_completion_target: 0.9
        autovacuum_max_workers: 5
        autovacuum_vacuum_scale_factor: 0.05
        autovacuum_analyze_scale_factor: 0.02
      recovery_conf:
        recovery_target_timeline: latest
        standby_mode: on

  # some desired options for 'initdb'
  initdb:  # Note: It needs to be a list (some options need values, others are switches)
  - encoding: UTF8
  - data-checksums

  pg_hba:  # Add following lines to pg_hba.conf after running 'initdb'
  - host replication replicator 127.0.0.1/32 md5
  - host replication replicator ${cidr} md5
  - host all all 0.0.0.0/0 md5

postgresql:
  listen: 0.0.0.0:5432
  connect_address: $(curl http://169.254.169.254/latest/meta-data/local-ipv4):5432
  data_dir: /var/lib/postgresql/13/main
  bin_dir: /usr/lib/postgresql/13/bin
  custom_conf: /etc/postgresql/13/main/postgresql.conf
  pgpass: /tmp/pgpass0
  parameters:
    logging_collector: 'off'
    log_destination: 'stderr'
  create_replica_methods:
  - basebackup
  authentication:
    replication:
      username: replicator
      password: ${replicator_password}
    superuser:
      username: postgres
      password: ${postgres_password}
    rewind:  # Has no effect on postgres 10 and lower
      username: rewind_user
      password: ${rewind_password}
  pg_hba:
  - host replication replicator 127.0.0.1/32 md5
  - host replication replicator ${cidr} md5
  - host all all 0.0.0.0/0 md5

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
EOF

cat > /etc/systemd/system/patroni.service <<EOF
[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Type=simple

User=postgres
Group=postgres

# Read in configuration file if it exists, otherwise proceed
EnvironmentFile=-/etc/patroni_env.conf

# Start the patroni process
ExecStart=/usr/local/bin/patroni /etc/patroni.yml

# Send HUP to reload from patroni.yml
ExecReload=/bin/kill -s HUP $MAINPID

# only kill the patroni process, not it's children, so it will gracefully stop postgres
KillMode=process

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=30

# Do not restart the service if it crashes, we want to manually inspect database on failure
Restart=no

[Install]
WantedBy=multi-user.target
EOF

systemctl enable patroni
systemctl start patroni